import RxCocoa
import RxSwift

// TODO: Improve handling around initial page.
// Will need some form of state to know if we have fetched the initial page.
// Will also need to determine what to do if fetching initial page and told to fetch separate page.
// ? Use initial page size in both directions? This is the easiest.

// TODO: For initial page, should it be okay to fetch next / prev page while fetching initial page?

public final class ConnectionController<F> where F: ConnectionFetcher {

    // MARK: Dependencies

    private let paginationStateTracker = PaginationStateTracker<F>()
    private let pageStorer = PageStorer<F>()
    private let pageFetcherFactory: PageFetcherFactory<F, PageStorer<F>>
    private let pageFetcherCoordinator: PageFetcherCoordinator<F>

    private var initialLoadDisposable: Disposable
    private var headNextPageDisposable: Disposable
    private var tailNextPageDisposable: Disposable
    private let disposeBag = DisposeBag()

    // MARK: Initialization

    public init(fetcher: F, initialPageSize: Int = 2, paginationPageSize: Int = 4) {
        // Instantiate dependencies:
        self.pageFetcherFactory = PageFetcherFactory(
            fetcher: fetcher,
            pageProvider: self.pageStorer,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )
        self.pageFetcherCoordinator = PageFetcherCoordinator(
            initialPageFetcher: self.pageFetcherFactory.fetcher(for: .tail, isInitial: true),
            headPageFetcher: self.pageFetcherFactory.fetcher(for: .head, isInitial: false),
            tailPageFetcher: self.pageFetcherFactory.fetcher(for: .tail, isInitial: false)
        )
        self.initialLoadDisposable = Disposables.create()
        self.headNextPageDisposable = Disposables.create()
        self.tailNextPageDisposable = Disposables.create()

        // Update disposables:
        self.initialLoadDisposable = self.observeInitialLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .initial), end: .tail)
        self.headNextPageDisposable = self.observeNextPageLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .head), end: .head)
        self.tailNextPageDisposable = self.observeNextPageLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .tail), end: .tail)
    }
}

// MARK: Private

extension ConnectionController {
    private func observeInitialLoad(fetcher: Observable<PageFetcherState<F>>, end: End) -> Disposable {
        let disposable = fetcher
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self,
                    case .completed(let edges, let pageInfo) = state else
                {
                    return
                }

                // Reset to the refreshed state:
                self.pageStorer.reset(to: edges, from: end)
                self.paginationStateTracker.reset(to: pageInfo, from: end)

                // Replace next page fetchers to wipe out in-flight requests:
                self.pageFetcherCoordinator.replace(fetcher: .head, with: self.pageFetcherFactory.fetcher(for: .head, isInitial: false))
                self.pageFetcherCoordinator.replace(fetcher: .tail, with: self.pageFetcherFactory.fetcher(for: .tail, isInitial: false))
            })

        // Dispose on dealloc with bag:
        disposable.disposed(by: self.disposeBag)
        return disposable
    }

    private func observeNextPageLoad(fetcher: Observable<PageFetcherState<F>>, end: End) -> Disposable {
        let disposable = fetcher
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self,
                    case .completed(let edges, let pageInfo) = state else
                {
                    return
                }

                // Ingest the new state:
                self.pageStorer.ingest(edges: edges, from: end)
                self.paginationStateTracker.ingest(pageInfo: pageInfo, from: end)
            })

        // Dispose on dealloc with bag:
        disposable.disposed(by: self.disposeBag)
        return disposable
    }
}

// MARK: Mutations

extension ConnectionController {
    /**
     Fetch the initial page of data from the given end.
     The request will use the initial page size.

     If / when this fetch completes, the connection will be reset to include just the initial page.
     It could be used initially and then again for refreshing the connection.
     */
    public func loadInitialPage(from end: End) {
        let state = self.pageFetcherCoordinator.state(for: .initial)
        if !self.pageFetcherCoordinator.state(for: .initial).canLoadPage {
            return assertionFailure("Can't load initial page from this state")
        }

        // Replace the fetcher:
        let initialPageFetcher = self.pageFetcherFactory.fetcher(for: end, isInitial: true)
        self.pageFetcherCoordinator.replace(fetcher: .initial, with: initialPageFetcher)

        // Replace the initial load observable because the end may have changed:
        let stateObservable = self.pageFetcherCoordinator.stateObservable(for: .initial)
        self.initialLoadDisposable = self.observeInitialLoad(fetcher: stateObservable, end: end)

        // Load the initial page:
        self.pageFetcherCoordinator.loadPage(from: .initial)
    }

    /**
     Triggers the receiver to begin fetching the head or the tail based on the provided parameter.
     The head or tail end respectively must be in the correct state (idle or error) in order to trigger a fetch.
     If it is already fetching, an assertion is thrown and nothing happens.

     - parameter end: The end from which to trigger a fetch.
     */
    public func loadNextPage(from end: End) {
        let pageFetcherType = PageFetcherType(end: end)
        let pageFetcherState = self.pageFetcherCoordinator.state(for: pageFetcherType)
        let hasFetchedLastPage = self.paginationStateTracker.hasFetchedLastPage(from: end)
        if !pageFetcherState.canLoadPage || hasFetchedLastPage {
            return assertionFailure("Can't load next page from this state")
        }

        let nextPageFetcher = self.pageFetcherFactory.fetcher(for: end, isInitial: false)
        self.pageFetcherCoordinator.replace(fetcher: pageFetcherType, with: nextPageFetcher)
        self.pageFetcherCoordinator.loadPage(from: pageFetcherType)
    }
}

// MARK: Getters

extension ConnectionController {
    /**
     The state the initial load or refresh.
     */
    public var initialLoadState: InitialLoadState {
        return InitialLoadState(pageFetcherState: self.pageFetcherCoordinator.state(for: .initial))
    }

    /**
     An observable for the aforementioned pages.
     */
    public var initialLoadStateObservable: Observable<InitialLoadState> {
        return self.pageFetcherCoordinator.stateObservable(for: .initial)
            .map(InitialLoadState.init)
            .distinctUntilChanged()
    }

    /**
     The state of the given end of the connection.
     */
    public func state(for end: End) -> EndState {
        let fetcherState = self.pageFetcherCoordinator.state(for: PageFetcherType(end: end))
        let hasFetchedLastPage = self.paginationStateTracker.hasFetchedLastPage(from: end)
        return EndState(pageFetcherState: fetcherState, hasFetchedLastPage: hasFetchedLastPage)
    }

    /**
     An observable for the aforementioned pages.
     */
    public func stateObservable(for end: End) -> Observable<EndState> {
        let fetcherStateObservable = self.pageFetcherCoordinator.stateObservable(for: PageFetcherType(end: end))
        let hasFetchedLastPageObservable = self.paginationStateTracker.hasFetchedLastPageObservable(from: end)
        return fetcherStateObservable.withLatestFrom(hasFetchedLastPageObservable) { fetcherState, hasFetchedLastPage in
            return EndState(pageFetcherState: fetcherState, hasFetchedLastPage: hasFetchedLastPage)
        }.distinctUntilChanged()
    }

    /**
     Array of tuples of the page index and the array of edges that was fetched with that page.

     The initial page index is always 0.
     Pages fetched from the head have index [previous head index] - 1.
     Pages fetched from the tail have index [previous tail index] + 1.

     Examples:
     - The first page will have index 0 regardless of whether it is ingested from the head or the tail.
     - If the second page is fetched from the head, it will have index -1.
     - If the third page is fetched from the tail it will have index 1.
     - If the fourth page is fetched from the tail it will have index 2.
     */
    public var pages: [Page<F>] {
        return self.pageStorer.pages
    }

    /**
     An observable for the aforementioned pages.
     */
    public var pagesObservable: Observable<[Page<F>]> {
        return self.pageStorer.pagesObservable
    }
}
