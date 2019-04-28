import RxSwift

public final class NestedConnectionController<Node, Fetcher, Parser, NestedNode, NestedFetcher, NestedParser>
    where
    // Conformances
    Node: Identifiable,
    Fetcher: ConnectionFetcherProtocol,
    Parser: ModelParser,
    NestedFetcher: ConnectionFetcherProtocol,
    NestedParser: ModelParser,
    // Conditions
    Node == Fetcher.FetchedConnection.ConnectedEdge.Node,
    Node == Parser.Node,
    NestedNode == NestedFetcher.FetchedConnection.ConnectedEdge.Node,
    NestedNode == NestedParser.Node
{
    // Chronological connection over the outer nodes sorted by their most recent inner nodes.
    private let outerController: ConnectionController<Fetcher, Parser>

    // Function to extract the nested connections from the nodes.
    typealias NestedConnectionExtractor = (Node) -> NestedFetcher.FetchedConnection
    private let extractor: NestedConnectionExtractor

    // Coordinator for inner controllers:
    private let coordinator: NestedConnectionControllerCoordinator<Node.Identity, NestedFetcher, NestedParser>

    private let disposeBag = DisposeBag()

    init(outerConfiguration: ConnectionControllerConfiguration<Fetcher>,
         extractor: @escaping NestedConnectionExtractor,
         innerConfiguration: ConnectionControllerConfiguration<NestedFetcher>)
    {
        // Create Outer Controller
        self.outerController = ConnectionController<Fetcher, Parser>(configuration: outerConfiguration)

        // Save a reference to the extractor:
        self.extractor = extractor

        // Create Coordinator
        let factory = ConnectionControllerFactory<NestedFetcher, NestedParser>(configuration: innerConfiguration)
        self.coordinator = NestedConnectionControllerCoordinator<Node.Identity, NestedFetcher, NestedParser>(factory: factory)

        // Observe Outer Connection
//        self.observeOuterConnection()
    }
}

extension NestedConnectionController {
}
