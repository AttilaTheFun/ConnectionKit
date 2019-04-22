
public struct ConnectionControllerConfiguration<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    let fetcher: Fetcher
    let parser: Parser.Type
    public let initialPageSize: Int
    public let paginationPageSize: Int

    public init(fetcher: Fetcher, parser: Parser.Type, initialPageSize: Int, paginationPageSize: Int) {
        self.fetcher = fetcher
        self.parser = parser
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
    }
}

extension ConnectionControllerConfiguration {
    /**
     Convenience initializer for when the node and model are the same.
     */
    public static func passthrough<Fetcher>(fetcher: Fetcher, initialPageSize: Int, paginationPageSize: Int)
        -> ConnectionControllerConfiguration<Fetcher, DefaultParser<Fetcher.FetchedConnection.ConnectedEdge.Node>>
        where Fetcher: ConnectionFetcherProtocol, Fetcher.FetchedConnection.ConnectedEdge.Node: Hashable
    {
        return ConnectionControllerConfiguration<Fetcher, DefaultParser<Fetcher.FetchedConnection.ConnectedEdge.Node>>(
            fetcher: fetcher,
            parser: DefaultParser<Fetcher.FetchedConnection.ConnectedEdge.Node>.self,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )
    }
}
