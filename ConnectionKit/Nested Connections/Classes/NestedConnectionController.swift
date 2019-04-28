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
    public let outerController: ConnectionController<Fetcher, Parser>

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
    }
}

extension NestedConnectionController {
    private func observeOuterState(from controller: ConnectionController<Fetcher, Parser>) -> Disposable {
        return controller.stateObservable
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self else {
                    return
                }

                let edges = state.pages.flatMap { $0.edges }
                let nodes = edges.map { $0.node }
                let states = Dictionary(uniqueKeysWithValues: nodes.map { node -> (Node.Identity, ConnectionControllerState<NestedNode>) in
                    let nestedConnection = self.extractor(node)
                    return (node.identity, ConnectionControllerState(connection: nestedConnection, fetchedFrom: .tail))
                })
                self.coordinator.update(to: states)
            })
    }
}

extension NestedConnectionController {
    /**
     Retrieve the controller for the given identifier if one exists.
     */
    func controller(for identifier: Node.Identity) -> ConnectionController<NestedFetcher, NestedParser>? {
        return self.coordinator.controller(for: identifier)
    }

    /**
     Retrieve the pages for the given identifiers from their respective controllers.
     */
    func parsedPages(for identifiers: [Node.Identity]) -> [Node.Identity : [Page<NestedParser.Model>]] {
        return self.coordinator.parsedPages(for: identifiers)
    }
}
