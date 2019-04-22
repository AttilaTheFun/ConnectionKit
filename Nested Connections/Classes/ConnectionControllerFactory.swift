
final class ConnectionControllerFactory<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    private let configuration: ConnectionControllerConfiguration<Fetcher, Parser>

    init(configuration: ConnectionControllerConfiguration<Fetcher, Parser>) {
        self.configuration = configuration
    }
}

extension ConnectionControllerFactory {
    func create(with initialState: ConnectionControllerState<Fetcher, Parser> = .init()) -> ConnectionController<Fetcher, Parser> {
        return ConnectionController(
            configuration: self.configuration,
            initialState: initialState
        )
    }
}
