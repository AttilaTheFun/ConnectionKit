
final class ConnectionControllerFactory<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    private let fetcher: Fetcher
    private let parser: Parser.Type
    private let initialPageSize: Int
    private let paginationPageSize: Int

    init(
        fetcher: Fetcher,
        parser: Parser.Type,
        initialPageSize: Int,
        paginationPageSize: Int)
    {
        self.fetcher = fetcher
        self.parser = parser
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
    }
}

extension ConnectionControllerFactory {
    func create(with initialState: InitialConnectionState<Fetcher.FetchedConnection>? = nil) -> ConnectionController<Fetcher, Parser> {
        return ConnectionController(
            fetcher: self.fetcher,
            parser: self.parser,
            initialPageSize: self.initialPageSize,
            paginationPageSize: self.paginationPageSize,
            initialState: initialState
        )
    }
}
