import RxCocoa
import RxSwift

public final class ConnectionController<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    // MARK: Dependencies

    private let paginationStateTracker: PaginationStateTracker
    private let pageStorer: PageStorer<Parser.Model>
    private let pageFetcherFactory: PageFetcherFactory<Fetcher, Parser, PageStorer<Parser.Model>>
    private let pageFetcherCoordinator: PageFetcherCoordinator<Fetcher, Parser>
    private let disposeBag = DisposeBag()

    // MARK: State

    private var hasCompletedInitialLoad = false

    // MARK: Initialization

    public init(
        fetcher: Fetcher,
        parser: Parser.Type,
        initialPageSize: Int,
        paginationPageSize: Int,
        initialState: InitialConnectionState<Fetcher.FetchedConnection>? = nil)
    {
        // Setup Pagination State Tracker
        self.paginationStateTracker = PaginationStateTracker(initialPageInfo: ConnectionController.initialPageInfo(for: initialState),
                                                             from: initialState?.end ?? .head)

        // Setup Page Storer
        self.pageStorer = PageStorer(initialEdges: ConnectionController.initialEdges(for: initialState, parser: parser))

        // Setup Page Fetcher Factory
        self.pageFetcherFactory = PageFetcherFactory(
            fetcher: fetcher,
            parser: parser,
            provider: self.pageStorer,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )

        // Setup Page Fetcher Coordinator
        self.pageFetcherCoordinator = PageFetcherCoordinator(
            initialHeadPageFetcher: self.pageFetcherFactory.fetcher(for: .head, isInitial: true),
            initialTailPageFetcher: self.pageFetcherFactory.fetcher(for: .tail, isInitial: true),
            headPageFetcher: self.pageFetcherFactory.fetcher(for: .head, isInitial: false),
            tailPageFetcher: self.pageFetcherFactory.fetcher(for: .tail, isInitial: false)
        )

        // Observe Page Loads
        self.observeInitialLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .head, isInitial: true), end: .head)
        self.observeNextPageLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .head, isInitial: false), end: .head)
        self.observeInitialLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .tail, isInitial: true), end: .tail)
        self.observeNextPageLoad(fetcher: self.pageFetcherCoordinator.stateObservable(for: .tail, isInitial: false), end: .tail)
    }
}

// MARK: Private

extension ConnectionController {
    private static func initialPageInfo(for initialState: InitialConnectionState<Fetcher.FetchedConnection>?) -> PageInfo {
        guard let initialState = initialState else {
            return PageInfo(hasNextPage: true, hasPreviousPage: true)
        }

        return PageInfo(connectionPageInfo: initialState.connection.pageInfo)
    }

    private static func initialEdges(for initialState: InitialConnectionState<Fetcher.FetchedConnection>?,
                                     parser: Parser.Type) -> [Edge<Parser.Model>]
    {
        guard let initialState = initialState else {
            return []
        }

        return initialState.connection.edges.map { edge -> Edge<Parser.Model> in
            let node = parser.parse(node: edge.node)
            return Edge(node: node, cursor: edge.cursor)
        }
    }

    private func reset(to edges: [Edge<Parser.Model>], pageInfo: PageInfo, from end: End) {
        // Reset to the refreshed state:
        self.hasCompletedInitialLoad = true
        self.pageStorer.reset(to: edges, from: end)
        self.paginationStateTracker.reset(to: pageInfo, from: end)

        // Replace next page fetchers to wipe out in-flight requests:
        let newHeadPageFetcher = self.pageFetcherFactory.fetcher(for: .head, isInitial: false)
        self.pageFetcherCoordinator.replaceNextPageFetcher(at: .head, with: newHeadPageFetcher)
        let newTailPageFetcher = self.pageFetcherFactory.fetcher(for: .tail, isInitial: false)
        self.pageFetcherCoordinator.replaceNextPageFetcher(at: .tail, with: newTailPageFetcher)
    }

    private func observeInitialLoad(fetcher: Observable<PageFetcherState<Parser.Model>>, end: End) {
        fetcher
            .subscribe(onNext: { [weak self] state in
                if case .complete(let edges, let pageInfo) = state {
                    self?.reset(to: edges, pageInfo: pageInfo, from: end)
                }
            })
            .disposed(by: self.disposeBag)
    }

    private func observeNextPageLoad(fetcher: Observable<PageFetcherState<Parser.Model>>, end: End) {
        fetcher
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self,
                    case .complete(let edges, let pageInfo) = state else
                {
                    return
                }

                // Ingest the new state:
                self.pageStorer.ingest(edges: edges, from: end)
                self.paginationStateTracker.ingest(pageInfo: pageInfo, from: end)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: Initialization

extension ConnectionController {
    /**
     Convenience initializer for when the node and model are the same.
     */
    public static func passthrough<Fetcher>(fetcher: Fetcher, initialPageSize: Int, paginationPageSize: Int)
        -> ConnectionController<Fetcher, DefaultParser<Fetcher.FetchedConnection.ConnectedEdge.Node>>
        where Fetcher: ConnectionFetcherProtocol, Fetcher.FetchedConnection.ConnectedEdge.Node: Hashable
    {
        return ConnectionController<Fetcher, DefaultParser<Fetcher.FetchedConnection.ConnectedEdge.Node>>(
            fetcher: fetcher,
            parser: DefaultParser<Fetcher.FetchedConnection.ConnectedEdge.Node>.self,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )
    }
}

// MARK: Mutations

extension ConnectionController {
    /**
     Resets the connection back to a given initial state, stopping all inflight requests.
     */
    public func reset(to state: InitialConnectionState<Fetcher.FetchedConnection>) {
        let initialEdges = ConnectionController.initialEdges(for: state, parser: Parser.self)
        let initialPageInfo = ConnectionController.initialPageInfo(for: state)
        self.reset(to: initialEdges, pageInfo: initialPageInfo, from: state.end)
    }

    /**
     Fetch the initial page of data from the given end.
     The request will use the initial page size.

     If / when this fetch completes, the connection will be reset to include just the initial page.
     It could be used initially and then again for refreshing the connection.
     */
    public func loadInitialPage(from end: End) {
        let pageFetcherState = self.pageFetcherCoordinator.state(for: end, isInitial: true)
        if !pageFetcherState.canLoadPage {
            return assertionFailure("Can't load initial page from this state")
        }

        // Load the initial page:
        self.pageFetcherCoordinator.loadPage(from: end, isInitial: true)
    }

    /**
     Triggers the receiver to begin fetching the head or the tail based on the provided parameter.
     The head or tail end respectively must be in the correct state (idle or error) in order to trigger a fetch.
     If it is already fetching, an assertion is thrown and nothing happens.

     - parameter end: The end from which to trigger a fetch.
     */
    public func loadNextPage(from end: End) {
        let pageFetcherState = self.pageFetcherCoordinator.state(for: end, isInitial: false)
        let hasFetchedLastPage = self.paginationStateTracker.hasFetchedLastPage(from: end)
        if !self.hasEverCompletedInitialLoad || !pageFetcherState.canLoadPage || hasFetchedLastPage {
            return assertionFailure("Can't load next page from this state")
        }

        let nextPageFetcher = self.pageFetcherFactory.fetcher(for: end, isInitial: false)
        self.pageFetcherCoordinator.replaceNextPageFetcher(at: end, with: nextPageFetcher)
        self.pageFetcherCoordinator.loadPage(from: end, isInitial: false)
    }
}

// MARK: Getters

extension ConnectionController {
    /**
     Flag indicating whether the connection has *ever* completed its initial load.
     */
    public var hasEverCompletedInitialLoad: Bool {
        return self.hasCompletedInitialLoad
    }

    /**
     The initial page size for the connection.
     */
    public var initialPageSize: Int {
        return self.pageFetcherFactory.initialPageSize
    }

    /**
     The initial page size for the connection.
     */
    public var paginationPageSize: Int {
        return self.pageFetcherFactory.paginationPageSize
    }

    /**
     The state the initial load or refresh for the given end.
     */
    public func initialLoadState(for end: End) -> InitialLoadState {
        return InitialLoadState(pageFetcherState: self.pageFetcherCoordinator.state(for: end, isInitial: true))
    }

    /**
     An observable for the aforementioned pages.
     */
    public func initialLoadStateObservable(for end: End) -> Observable<InitialLoadState> {
        return self.pageFetcherCoordinator.stateObservable(for: end, isInitial: true)
            .map(InitialLoadState.init)
    }

    /**
     The state of the given end of the connection.
     */
    public func state(for end: End) -> EndState {
        let fetcherState = self.pageFetcherCoordinator.state(for: end, isInitial: false)
        let hasFetchedLastPage = self.paginationStateTracker.hasFetchedLastPage(from: end)
        return EndState(pageFetcherState: fetcherState, hasFetchedLastPage: hasFetchedLastPage)
    }

    /**
     An observable for the aforementioned pages.
     */
    public func stateObservable(for end: End) -> Observable<EndState> {
        let fetcherStateObservable = self.pageFetcherCoordinator.stateObservable(for: end, isInitial: false)
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
    public var pages: [Page<Parser.Model>] {
        return self.pageStorer.pages
    }

    /**
     An observable for the aforementioned pages.
     */
    public var pagesObservable: Observable<[Page<Parser.Model>]> {
        return self.pageStorer.pagesObservable
    }
}
