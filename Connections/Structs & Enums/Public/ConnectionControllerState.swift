
public struct ConnectionControllerState<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    let hasCompletedInitialLoad: Bool
    let paginationState: PaginationState
    let pageFetcherCoordinatorState: PageFetcherCoordinatorState<Parser.Model>
    let pageStorerPages: [Page<Parser.Model>]
}

// MARK: Internal

extension ConnectionControllerState {
    var initialEdges: [Edge<Parser.Model>] {
        assert(self.pageStorerPages.count < 2)
        if let initialPage = self.pageStorerPages.first {
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
        self.hasCompletedInitialLoad = false
        self.paginationState = .initial
        self.pageFetcherCoordinatorState = .idle
        self.pageStorerPages = []
    }

    /**
     Used to construct an initial state for the connection controller from a known connection.
     */
    public init(connection: Fetcher.FetchedConnection, fetchedFrom end: End) {
        self.hasCompletedInitialLoad = true
        let pageInfo = PageInfo(connectionPageInfo: connection.pageInfo)
        self.paginationState = PaginationState(initialPageInfo: pageInfo, from: end)
        self.pageFetcherCoordinatorState = .idle
        let initialEdges = connection.edges.map { edge -> Edge<Parser.Model> in
            let node = Parser.parse(node: edge.node)
            return Edge(node: node, cursor: edge.cursor)
        }

        self.pageStorerPages = [Page(index: 0, edges: initialEdges)]
    }
}

// MARK: Getters

extension ConnectionControllerState {
    /**
     Flag indicating whether the connection has *ever* completed its initial load.
     */
    public var hasEverCompletedInitialLoad: Bool {
        return self.hasCompletedInitialLoad
    }

    /**
     Array of structs combining the page index and the array of edges that was fetched with that page.

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
        return self.pageStorerPages
    }

    /**
     The state the initial load or refresh for the given end.
     */
    public func initialLoadState(for end: End) -> InitialLoadState {
        return InitialLoadState(pageFetcherState: self.pageFetcherCoordinatorState.state(for: end, isInitial: true))
    }

    /**
     The state of the given end of the connection.
     */
    public func endState(for end: End) -> EndState {
        let fetcherState = self.pageFetcherCoordinatorState.state(for: end, isInitial: false)
        let hasFetchedLastPage = self.paginationState.hasFetchedLastPage(from: end)
        return EndState(pageFetcherState: fetcherState, hasFetchedLastPage: hasFetchedLastPage)
    }
}
