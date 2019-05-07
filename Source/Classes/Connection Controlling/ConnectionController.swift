import RxCocoa
import RxSwift

public final class ConnectionController<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    public typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node
    private typealias Storer = ParsingPageStorer<Fetcher, Parser>

    // MARK: Configuration

    public let configuration: ConnectionControllerConfiguration<Fetcher>

    // MARK: Dependencies

    private let paginationStateTracker: PaginationStateTracker
    private let pageStorer: Storer
    private let pageFetcherContainer: PageFetcherContainer<Fetcher, Storer>

    // MARK: State

    private var hasCompletedInitialLoad: Bool
    private let stateRelay: BehaviorRelay<ConnectionControllerState<Parser.Model>>
    private let disposeBag = DisposeBag()

    // MARK: Initialization

    private init(
        configuration: ConnectionControllerConfiguration<Fetcher>,
        initialPaginationState: PaginationState,
        initialEdges: [Edge<Node>],
        hasCompletedInitialLoad: Bool)
    {
        // Save configuration:
        self.configuration = configuration

        // Create pagination state tracker:
        self.paginationStateTracker = PaginationStateTracker(initialState: initialPaginationState)

        // Create page storer:
        self.pageStorer = ParsingPageStorer(initialEdges: initialEdges)

        // Create page fetcher coordinator:
        let factory = PageFetcherFactory(
            fetcher: configuration.fetcher,
            pageStorer: self.pageStorer,
            initialPageSize: configuration.initialPageSize,
            paginationPageSize: configuration.paginationPageSize
        )
        self.pageFetcherContainer = PageFetcherContainer(factory: factory)

        // Setup state relay:
        self.hasCompletedInitialLoad = hasCompletedInitialLoad
        let initialState = ConnectionControllerState(
            hasCompletedInitialLoad: self.hasCompletedInitialLoad,
            pageFetcherCoordinatorState: self.pageFetcherContainer.combinedState,
            paginationState: self.paginationStateTracker.state,
            pages: self.pageStorer.parsedPages
        )
        self.stateRelay = BehaviorRelay(value: initialState)

        // Observe everything:
        self.resetFetcherObservables()
    }
}

// MARK: Private

extension ConnectionController {

    private func resetFetcherObservables() {
        // Reset all the fetchers, wiping out any inflight requests:
        self.observeInitialLoad(fetcher: self.pageFetcherContainer.resetFetcher(for: .head, isInitial: true), end: .head)
        self.observeInitialLoad(fetcher: self.pageFetcherContainer.resetFetcher(for: .tail, isInitial: true), end: .tail)
        self.observeNextPageLoad(fetcher: self.pageFetcherContainer.resetFetcher(for: .head, isInitial: false), end: .head)
        self.observeNextPageLoad(fetcher: self.pageFetcherContainer.resetFetcher(for: .tail, isInitial: false), end: .tail)
    }

    private func reset(to edges: [Edge<Node>], paginationState: PaginationState) {

        // Create page storer:
        self.pageStorer.reset(to: edges)

        // Reset the pagination state to the given page info from the given end:
        self.paginationStateTracker.reset(initialState: paginationState)

        // Reset the fetcher observables:
        self.resetFetcherObservables()

        // Update the state:
        self.updateStateRelay()
    }

    private func updateStateRelay() {
        let state = ConnectionControllerState(
            hasCompletedInitialLoad: self.hasCompletedInitialLoad,
            pageFetcherCoordinatorState: self.pageFetcherContainer.combinedState,
            paginationState: self.paginationStateTracker.state,
            pages: self.pageStorer.parsedPages
        )

        self.stateRelay.accept(state)
    }

    private func completeObservable(for fetcher: Observable<PageFetcherState<Node>>) -> Observable<([Edge<Node>], PageInfo)> {
        return fetcher
            .flatMap { state -> Observable<([Edge<Node>], PageInfo)> in
                guard case .complete(let edges, let pageInfo) = state else {
                    return .empty()
                }

                return .just((edges, pageInfo))
            }
    }

    private func observeInitialLoad(fetcher: PageFetcher<Fetcher>, end: End) {
        fetcher.stateObservable
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self else {
                    return
                }

                switch state {
                case .idle, .fetching, .error:
                    self.updateStateRelay()
                case .complete(let edges, let pageInfo):
                    self.hasCompletedInitialLoad = true
                    let paginationState = PaginationState.initial.nextState(pageInfo: pageInfo, from: end)
                    self.reset(to: edges, paginationState: paginationState)
                }
            })
            .disposed(by: self.disposeBag)
    }

    private func observeNextPageLoad(fetcher: PageFetcher<Fetcher>, end: End) {
        fetcher.stateObservable
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self else {
                    return
                }

                switch state {
                case .idle, .fetching, .error:
                    self.updateStateRelay()
                case .complete(let edges, let pageInfo):
                    self.pageStorer.ingest(edges: edges, from: end)
                    self.paginationStateTracker.ingest(pageInfo: pageInfo, from: end)
                    self.observeNextPageLoad(fetcher: self.pageFetcherContainer.resetFetcher(for: end, isInitial: false), end: end)
                }
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: Initialization

extension ConnectionController {
    public convenience init(configuration: ConnectionControllerConfiguration<Fetcher>) {
        self.init(
            configuration: configuration,
            initialPaginationState: .initial,
            initialEdges: [],
            hasCompletedInitialLoad: false
        )
    }

    convenience init(
        configuration: ConnectionControllerConfiguration<Fetcher>,
        connection: Fetcher.FetchedConnection,
        fetchedFrom end: End)
    {
        let pageInfo = PageInfo(connectionPageInfo: connection.pageInfo)
        let edges = connection.edges.map { edge -> Edge<Node> in
            return Edge(node: edge.node, cursor: edge.cursor)
        }
        self.init(
            configuration: configuration,
            initialPaginationState: PaginationState(initialPageInfo: pageInfo, from: end),
            initialEdges: edges,
            hasCompletedInitialLoad: true
        )
    }
}

// MARK: Mutations

extension ConnectionController {
    /**
     Resets the connection back to a given initial state, stopping all inflight requests.
     */
//    public func reset(to state: ConnectionControllerState<Parser.Model>) {
//        self.hasCompletedInitialLoad = state.initialLoadState.hasCompletedInitialLoad
//        self.reset(to: state.initialEdges, paginationState: state.paginationState)
//    }

    /**
     Fetch the initial page of data from the given end.

     The initial page fetchers for both ends must not be currently fetching.
     If it in an invalid state, an assertion is thrown and this is a no-op.

     When this fetch completes, the connection will be reset to include just the initial page.
     This method could be used initially and then again for refreshing the connection.

     - parameter end: The end from which to trigger a fetch.
     */
    public func loadInitialPage(from end: End) {
        let fetcher = self.pageFetcherContainer.fetcher(for: end, isInitial: true)
        let oppositeFetcher = self.pageFetcherContainer.fetcher(for: end, isInitial: true)
        if fetcher.state.isLoadingPage || oppositeFetcher.state.isLoadingPage {
            return assertionFailure("Unable to fetch page from this state")
        }

        fetcher.fetchPage()
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
        let fetcher = self.pageFetcherContainer.fetcher(for: end, isInitial: false)
        let hasCompletedInitialLoad = self.state.initialLoadState.hasCompletedInitialLoad
        let hasFetchedLastPage = self.paginationStateTracker.state.hasFetchedLastPage(from: end)
        if !hasCompletedInitialLoad || fetcher.state.isLoadingPage || hasFetchedLastPage {
            return assertionFailure("Can't load next page from this state")
        }

        fetcher.fetchPage()
    }
}

// MARK: Getters

extension ConnectionController {
    var pages: [Page<Node>] {
        return self.pageStorer.pages
    }

    /**
     The current state of the connection controller.
     */
    public var state: ConnectionControllerState<Parser.Model> {
        return self.stateRelay.value
    }

    /**
     The current state of the connection controller.
     */
    public var stateObservable: Observable<ConnectionControllerState<Parser.Model>> {
        return self.stateRelay.asObservable()
    }
}
