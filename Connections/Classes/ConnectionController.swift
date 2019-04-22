import RxCocoa
import RxSwift

// TODO: Create connection config struct for non-state.

public final class ConnectionController<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    // MARK: Configuration

    public let configuration: ConnectionControllerConfiguration<Fetcher, Parser>

    // MARK: Dependencies

    private let paginationStateTracker: PaginationStateTracker
    private let pageStorer: PageStorer<Parser.Model>
    private let pageFetcherCoordinator: PageFetcherCoordinator<Fetcher, Parser>

    // MARK: State

    private let stateRelay: BehaviorRelay<ConnectionControllerState<Fetcher, Parser>>
    private let disposeBag = DisposeBag()

    // MARK: Initialization

    public init(
        configuration: ConnectionControllerConfiguration<Fetcher, Parser>,
        initialState: ConnectionControllerState<Fetcher, Parser> = .init())
    {
        // Save configuration:
        self.configuration = configuration

        // Create pagination state tracker:
        self.paginationStateTracker = PaginationStateTracker(initialState: initialState.paginationState)

        // Create page storer:
        self.pageStorer = PageStorer(initialEdges: initialState.initialEdges)

        // Create page fetcher coordinator:
        let factory = PageFetcherFactory(
            fetcher: configuration.fetcher,
            parser: configuration.parser,
            pageStorer: self.pageStorer,
            initialPageSize: self.configuration.initialPageSize,
            paginationPageSize: self.configuration.paginationPageSize
        )
        self.pageFetcherCoordinator = PageFetcherCoordinator(factory: factory)

        // Setup state relay:
        self.stateRelay = BehaviorRelay(value: initialState)

        // Observe Page Loads
//        self.observeInitialLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .head, isInitial: true), end: .head)
//        self.observeNextPageLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .head, isInitial: false), end: .head)
//        self.observeInitialLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .tail, isInitial: true), end: .tail)
//        self.observeNextPageLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .tail, isInitial: false), end: .tail)
    }
}

// MARK: Private

extension ConnectionController {
    private func observeInitialLoad(fetcher: Observable<PageFetcherState<Parser.Model>>, end: End) {
        fetcher
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self, case .complete(let edges, let pageInfo) = state else {
                    return
                }

                // Create the new state:
                let state = ConnectionControllerState<Fetcher, Parser>(
                    hasCompletedInitialLoad: true,
                    paginationState: PaginationState.initial.nextState(pageInfo: pageInfo, from: end),
                    pageFetcherCoordinatorState: .idle,
                    pageStorerPages: Page<Parser.Model>.nextPages(from: [], ingesting: edges, from: end)
                )

                // Reset the connection to the new state:
                self.reset(to: state)
            })
            .disposed(by: self.disposeBag)
    }

    private func observeNextPageLoad(fetcher: Observable<PageFetcherState<Parser.Model>>, end: End) {
        fetcher
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self, case .complete(let edges, let pageInfo) = state else {
                    return
                }

                // Ingest the new page:
                self.pageStorer.ingest(edges: edges, from: end)

                // Ingest the new pagination state:
                self.paginationStateTracker.ingest(pageInfo: pageInfo, from: end)

                // Create the updated state:
                let state = ConnectionControllerState<Fetcher, Parser>(
                    hasCompletedInitialLoad: true,
                    paginationState: self.paginationStateTracker.state,
                    pageFetcherCoordinatorState: self.pageFetcherCoordinator.state,
                    pageStorerPages: self.pageStorer.pages
                )

                // Push to the relay:
                self.stateRelay.accept(state)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: Mutations

extension ConnectionController {
    /**
     Resets the connection back to a given initial state, stopping all inflight requests.
     */
    public func reset(to state: ConnectionControllerState<Fetcher, Parser>) {
        // Create pagination state tracker:
        self.paginationStateTracker.reset(initialState: state.paginationState)

        // Create page storer:
        self.pageStorer.reset(to: state.initialEdges)

        // Reset the pagination state to the given page info from the given end:
        self.paginationStateTracker.reset(initialState: state.paginationState)

        // Reset all the fetchers, wiping out any inflight requests:
        self.pageFetcherCoordinator.reset()

        // Update the state:
        self.stateRelay.accept(state)
    }

    /**
     Fetch the initial page of data from the given end.

     The initial page fetchers for both ends must not be currently fetching.
     If it in an invalid state, an assertion is thrown and this is a no-op.

     When this fetch completes, the connection will be reset to include just the initial page.
     This method could be used initially and then again for refreshing the connection.

     - parameter end: The end from which to trigger a fetch.
     */
    public func loadInitialPage(from end: End) {
        self.pageFetcherCoordinator.loadPage(from: end, isInitial: true)
    }

    /**
     Fetch the next page of data from the given end.

     The next page fetcher must not be currently fetching in order to begin a new fetch.
     Also the initial page must have been fetched before a next page can be fetched.
     And the last page must not have been fetched from this end.
     If it in an invalid state, an assertion is thrown and this is a no-op.

     - parameter end: The end from which to trigger a fetch.
     */
    public func loadNextPage(from end: End) {
        let hasCompletedInitialLoad = self.state.hasEverCompletedInitialLoad
        let hasFetchedLastPage = self.paginationStateTracker.state.hasFetchedLastPage(from: end)
        if !hasCompletedInitialLoad || hasFetchedLastPage {
            return assertionFailure("Can't load next page from this state")
        }

        self.pageFetcherCoordinator.loadPage(from: end, isInitial: false)
    }
}

// MARK: Getters

extension ConnectionController {
    /**
     The current state of the connection controller.
     */
    var state: ConnectionControllerState<Fetcher, Parser> {
        return self.stateRelay.value
    }

    /**
     The current state of the connection controller.
     */
    var stateObservable: Observable<ConnectionControllerState<Fetcher, Parser>> {
        return self.stateRelay.asObservable()
    }

    /**
     An observable for the aforementioned pages.
     */
//    public func stateObservable(for end: End) -> Observable<EndState> {
//        let fetcherStateObservable = self.pageFetcherCoordinator.stateObservable(for: end, isInitial: false)
//        let hasFetchedLastPageObservable = self.paginationStateTracker.stateObservable.map { $0.hasFetchedLastPageObservable(from: end) }
//        return fetcherStateObservable.withLatestFrom(hasFetchedLastPageObservable) { fetcherState, hasFetchedLastPage in
//            return EndState(pageFetcherState: fetcherState, hasFetchedLastPage: hasFetchedLastPage)
//        }.distinctUntilChanged()
//    }
}
