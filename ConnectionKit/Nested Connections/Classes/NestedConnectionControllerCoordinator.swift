import RxCocoa

final class NestedConnectionControllerCoordinator<Identifier, Fetcher, Parser>
    where
    // MARK: Conformances
    Identifier: Hashable,
    Fetcher: ConnectionFetcherProtocol,
    Parser: ModelParser,
    // MARK: Conditions
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    // Factory for creating new connection controller instances.
    private let factory: ConnectionControllerFactory<Fetcher, Parser>

    // Connection controllers indexed by their outer nodes.
    private var connectionControllersRelay: BehaviorRelay<[Identifier : ConnectionController<Fetcher, Parser>]>

    init(factory: ConnectionControllerFactory<Fetcher, Parser>) {
        self.factory = factory
        self.connectionControllersRelay = BehaviorRelay(value: [:])
    }
}

extension NestedConnectionControllerCoordinator {
    /**
     Ingest a mapping of identifiers to connection controller states.
     Missing controllers will be created and existing ones will be ignored.
     This will typically be called after paginating.
     */
    func update(to states: [Identifier : ConnectionControllerState<Node>]) {
        var controllers = self.connectionControllersRelay.value
        for (identifier, state) in states {
            if controllers[identifier] == nil {
                controllers[identifier] = self.factory.create(with: state)
            }
        }

        self.connectionControllersRelay.accept(controllers)
    }

    /**
     Reset to a mapping of identifiers to connection controller states.
     Missing controllers will be created and existing ones will be reset.
     Extra controllers will be dropped.
     This will typically be called initially and then after a pull-to-refresh.
     */
    func reset(to states: [Identifier : ConnectionControllerState<Node>]) {
        let previousControllers = self.connectionControllersRelay.value
        var controllers = [Identifier : ConnectionController<Fetcher, Parser>]()
        for (identifier, state) in states {
            if let controller = previousControllers[identifier] {
                controller.reset(to: state)
                controllers[identifier] = controller
            } else {
                controllers[identifier] = self.factory.create(with: state)
            }
        }

        self.connectionControllersRelay.accept(controllers)
    }

    /**
     Retrieve the controller for the given identifier if one exists.
     */
    func controller(for identifier: Identifier) -> ConnectionController<Fetcher, Parser>? {
        return self.connectionControllersRelay.value[identifier]
    }

    /**
     Retrieve the pages for the given identifiers from their respective controllers.
     */
    func parsedPages(for identifiers: [Identifier]) -> [Identifier : [Page<Parser.Model>]] {
        let controllers = self.connectionControllersRelay.value
        return Dictionary(uniqueKeysWithValues: identifiers.lazy.map { ($0, controllers[$0]?.parsedPages ?? []) })
    }
}
