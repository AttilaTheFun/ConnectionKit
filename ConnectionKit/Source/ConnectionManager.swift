import RxCocoa
import RxSwift

// TODO: Improve handling around initial page.
// Will need some form of state to know if we have fetched the initial page.
// Will also need to determine what to do if fetching initial page and told to fetch separate page.
// ? Use initial page size in both directions? This is the easiest.

// TODO: Does replacing fetcher refires fire idle?

public final class ConnectionManager<F> where F: ConnectionFetcher {

    // MARK: Constants

    private let fetcher: F
    private let initialPageSize: Int
    private let paginationPageSize: Int

    // MARK: Dependencies

    private let paginationManager = PaginationManager<F>()
    private let pageStorer = PageStorer<F>()
    private var headFetcher: PageFetcher<F>
    private var tailFetcher: PageFetcher<F>

    // MARK: State

    private let headStateRelay = BehaviorRelay<EndState>(value: .hasNextPage)
    private let tailStateRelay = BehaviorRelay<EndState>(value: .hasNextPage)
    private let disposeBag = DisposeBag()

    // MARK: Initialization

    public init(fetcher: F, initialPageSize: Int = 2, paginationPageSize: Int = 4) {
        self.fetcher = fetcher
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
        self.headFetcher = PageFetcher(for: fetcher, end: .head, pageSize: initialPageSize, cursor: nil)
        self.tailFetcher = PageFetcher(for: fetcher, end: .tail, pageSize: initialPageSize, cursor: nil)

        // Rebuild the fetchers now that we can access self:
        self.headFetcher = self.createFetcher(for: .head, from: [], isInitialPage: true, disposedBy: self.disposeBag)
        self.tailFetcher = self.createFetcher(for: .tail, from: [], isInitialPage: true, disposedBy: self.disposeBag)
    }
}

// MARK: Private

extension ConnectionManager {
    private func handle(state: PageFetcherState<F>, end: End) {
        let relay = end == .head ? self.headStateRelay : self.tailStateRelay
        switch state {
        case .idle:
            let endHasNextPage = end == .head ?
                self.paginationManager.hasPreviousPage : self.paginationManager.hasNextPage
            let state: EndState = endHasNextPage ? .hasNextPage : .hasFetchedLastPage
            relay.accept(state)
        case .fetching:
            relay.accept(.isFetchingNextPage)
        case .error(let error):
            relay.accept(.failedToFetchNextPage(error))
        case .completed(let edges, let pageInfo):
            self.paginationManager.ingest(pageInfo: pageInfo, from: end)
            self.pageStorer.ingest(edges: edges, from: end)
            let fetcher = self.createFetcher(for: end, from: edges, isInitialPage: false, disposedBy: self.disposeBag)
            switch end {
            case .head:
                self.headFetcher = fetcher
            case .tail:
                self.tailFetcher = fetcher
            }
        }
    }

    /**
     Create a new fetcher for the given position and re-subscribe to it.

     - parameter position: The position for which to replace the fetcher.
     - parameter page: The page of data that led this fetcher to be replaced.
     The next cursor will be the first or last item in the page depending whether the position is head or tal respectively.
     - parameter pageInfo: The page info for the fetch leading up to this page.
     - parameter isInitial: Whether this will be the initial page.
     */
    private func createFetcher(
        for end: End,
        from edges: [Edge<F>],
        isInitialPage: Bool,
        disposedBy disposeBag: DisposeBag)
        -> PageFetcher<F>
    {
        let pageSize = isInitialPage ? self.initialPageSize : self.paginationPageSize
        let fetcher = PageFetcher(
            for: self.fetcher,
            end: .tail,
            pageSize: pageSize,
            cursor: end == .head ? edges.first?.cursor : edges.last?.cursor
        )

        fetcher.stateObservable
            .subscribe(onNext: { [weak self] state in
                self?.handle(state: state, end: end)
            })
            .disposed(by: disposeBag)

        return fetcher
    }
}

extension ConnectionManager {
    private var canLoadHead: Bool {
        switch self.headState {
        case .hasNextPage, .failedToFetchNextPage:
            return true
        case .isFetchingNextPage, .hasFetchedLastPage:
            return false
        }
    }

    private var canLoadTail: Bool {
        switch self.tailState {
        case .hasNextPage, .failedToFetchNextPage:
            return true
        case .isFetchingNextPage, .hasFetchedLastPage:
            return false
        }
    }
}

// MARK: Interface

extension ConnectionManager {
    public var headState: EndState {
        return self.headStateRelay.value
    }

    public var headStateObservable: Observable<EndState> {
        return self.headStateRelay.asObservable()
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

    public var tailState: EndState {
        return self.tailStateRelay.value
    }

    public var tailStateObservable: Observable<EndState> {
        return self.tailStateRelay.asObservable()
    }

    /**
     Triggers the receiver to begin fetching the head or the tail based on the provided parameter.
     The head or tail end respectively must be in the correct state (idle or error) in order to trigger a fetch.
     If it is already fetching, an assertion is thrown and nothing happens.

     - parameter end: The end from which to trigger a fetch.
     */
    public func loadNextPage(from end: End) {
        switch end {
        case .head where self.canLoadHead:
            self.headFetcher.fetchPage()
        case .tail where self.canLoadTail:
            self.tailFetcher.fetchPage()
        case .head, .tail:
            return assertionFailure("Can't load next page from this state")
        }
    }

    /**
     Reset the connection back to its original state.
     */
    public func reset() {
        fatalError("Not implemented yet")
    }
}
