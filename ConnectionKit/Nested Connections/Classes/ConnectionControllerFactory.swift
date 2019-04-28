
final class ConnectionControllerFactory<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    private let configuration: ConnectionControllerConfiguration<Fetcher>

    init(configuration: ConnectionControllerConfiguration<Fetcher>) {
        self.configuration = configuration
    }
}

extension ConnectionControllerFactory {
    func create(
        for connection: Fetcher.FetchedConnection,
        fetchedFrom end: End)
        -> ConnectionController<Fetcher, Parser>
    {
        return ConnectionController<Fetcher, Parser>(configuration: self.configuration, connection: connection, fetchedFrom: end)
    }
}
