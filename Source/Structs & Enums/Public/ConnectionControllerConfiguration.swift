
public struct ConnectionControllerConfiguration<Fetcher, Storer>
    where Fetcher: ConnectionFetcherProtocol, Storer: EdgeStorable,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Storer.Model
{
    public typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    public let fetcher: Fetcher
    public let storer: Storer
    public let initialPageSize: Int
    public let paginationPageSize: Int
    let initialPaginationState: PaginationState
    let hasCompletedInitialLoad: Bool
}

extension ConnectionControllerConfiguration {
    public init(
        fetcher: Fetcher,
        storer: Storer,
        initialPageSize: Int,
        paginationPageSize: Int)
    {
        self.fetcher = fetcher
        self.storer = storer
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
        self.initialPaginationState = .initial
        self.hasCompletedInitialLoad = false
    }

    public init(
        fetcher: Fetcher,
        storerType: Storer.Type,
        connection: Fetcher.FetchedConnection,
        fetchedFrom end: End,
        initialPageSize: Int,
        paginationPageSize: Int)
    {
        let pageInfo = PageInfo(connectionPageInfo: connection.pageInfo)
        let initialEdges = connection.edges.map { Edge(node: $0.node, cursor: $0.cursor) }
        self.storer = storerType.init(initialEdges: initialEdges)
        self.fetcher = fetcher
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
        self.initialPaginationState = PaginationState(initialPageInfo: pageInfo, from: end)
        self.hasCompletedInitialLoad = true
    }
}
