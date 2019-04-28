
public struct ConnectionControllerState<Model> {
    public let initialLoadState: InitialLoadState
    public let headState: EndState
    public let pages: [Page<Model>]
    public let tailState: EndState

    let paginationState: PaginationState
}

extension ConnectionControllerState: Equatable where Model: Equatable {}
extension ConnectionControllerState: Hashable where Model: Hashable {}

// MARK: Internal

extension ConnectionControllerState {
    var initialEdges: [Edge<Model>] {
        assert(self.pages.count < 2)
        if let initialPage = self.pages.first {
            assert(initialPage.index == 0)
            return initialPage.edges
        } else {
            return []
        }
    }
}

// MARK: Initialization

extension ConnectionControllerState {
    /**
     Initialize an empty connection controller state.
     */
    public init() {
        self.initialLoadState = InitialLoadState(hasCompletedInitialLoad: false, status: .idle)
        self.headState = .idle
        self.tailState = .idle
        self.paginationState = .initial
        self.pages = []
    }

    /**
     Used to construct an initial state for the connection controller from a known connection.
     */
    public init<Connection>(connection: Connection, fetchedFrom end: End)
        where Connection: ConnectionProtocol, Connection.ConnectedEdge.Node == Model
    {
        self.initialLoadState = InitialLoadState(hasCompletedInitialLoad: true, status: .complete)
        self.headState = .idle
        self.tailState = .idle

        let pageInfo = PageInfo(connectionPageInfo: connection.pageInfo)
        self.paginationState = PaginationState(initialPageInfo: pageInfo, from: end)
        let edges = connection.edges.map { edge -> Edge<Model> in
            return Edge(node: edge.node, cursor: edge.cursor)
        }

        self.pages = [Page<Model>(index: 0, edges: edges)]
    }

    init(hasCompletedInitialLoad: Bool,
         pageFetcherCoordinatorState: CombinedPageFetcherState<Model>,
         paginationState: PaginationState,
         pages: [Page<Model>])
    {
        let initialHeadFetcherState = pageFetcherCoordinatorState.state(for: .head, isInitial: true)
        let initialTailFetcherState = pageFetcherCoordinatorState.state(for: .tail, isInitial: true)
        self.initialLoadState = InitialLoadState(
            headPageFetcherState: initialHeadFetcherState,
            tailPageFetcherState: initialTailFetcherState,
            hasCompletedInitialLoad: hasCompletedInitialLoad
        )

        let headFetcherState = pageFetcherCoordinatorState.state(for: .head, isInitial: false)
        let headHasFetchedLastPage = paginationState.hasFetchedLastPage(from: .head)
        self.headState = EndState(pageFetcherState: headFetcherState, hasFetchedLastPage: headHasFetchedLastPage)

        let tailFetcherState = pageFetcherCoordinatorState.state(for: .tail, isInitial: false)
        let tailHasFetchedLastPage = paginationState.hasFetchedLastPage(from: .tail)
        self.tailState = EndState(pageFetcherState: tailFetcherState, hasFetchedLastPage: tailHasFetchedLastPage)

        self.paginationState = paginationState
        self.pages = pages
    }
}

// MARK: Getters

extension ConnectionControllerState {

    /**
     Get the state of the given end of the connection.
     */
    public func endState(for end: End) -> EndState {
        switch end {
        case .head:
            return self.headState
        case .tail:
            return self.tailState
        }
    }
}
