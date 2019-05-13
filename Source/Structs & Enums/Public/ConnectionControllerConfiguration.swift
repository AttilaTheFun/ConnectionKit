
public struct PaginationConfiguration {
    public let initialPageSize: Int
    public let paginationPageSize: Int

    public init(initialPageSize: Int, paginationPageSize: Int) {
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
    }
}

public struct ConnectionControllerConfiguration<Fetcher, Storer>
    where Fetcher: ConnectionFetcherProtocol, Storer: EdgeStorable,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Storer.Model
{
    public typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    public let fetcher: Fetcher
    public let storer: Storer
    public let paginationConfiguration: PaginationConfiguration
    let initialPaginationState: PaginationState
}

extension ConnectionControllerConfiguration {
    public init(
        fetcher: Fetcher,
        storer: Storer,
        paginationConfiguration: PaginationConfiguration)
    {
        self.fetcher = fetcher
        self.storer = storer
        self.paginationConfiguration = paginationConfiguration
        self.initialPaginationState = .initial
    }

    public init(
        fetcher: Fetcher,
        storerType: Storer.Type,
        paginationConfiguration: PaginationConfiguration,
        connection: Fetcher.FetchedConnection,
        fetchedFrom end: End)
    {
        self.fetcher = fetcher
        self.paginationConfiguration = paginationConfiguration

        let initialEdges = connection.edges.map { Edge(node: $0.node, cursor: $0.cursor) }
        self.storer = storerType.init(initialEdges: initialEdges)

        let pageInfo = PageInfo(connectionPageInfo: connection.pageInfo)
        self.initialPaginationState = PaginationState(initialPageInfo: pageInfo, from: end)
    }
}
