
final class NestedConnectionCoordinator<Identifier, Fetcher, Parser>
    where
    // MARK: Conformances
    Identifier: Hashable,
    Fetcher: ConnectionFetcherProtocol,
    Parser: ModelParser,
    // MARK: Conditions
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    // Connection controllers indexed by their outer nodes.
    private var connectionControllers: [Identifier : ConnectionController<Fetcher, Parser>]

    init() {
        self.connectionControllers = [:]
    }
}

extension NestedConnectionCoordinator {
//    func ingest(
}
