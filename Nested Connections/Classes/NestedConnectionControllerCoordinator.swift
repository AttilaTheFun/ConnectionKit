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
//    func ingest(states: [(Identifier, InitialConnectionState<Fetcher.FetchedConnection>)]) {
//        var controllers = self.connectionControllersRelay.value
//        for (identifier, state) in states {
//            if let controller = controllers[identifier] {
//                controller.reset(to: state)
//            } else {
//                controllers[identifier] = self.factory.create(with: state)
//            }
//        }
//
//        self.connectionControllersRelay.accept(controllers)
//    }

//    func reset(to states: [(Identifier, InitialConnectionState<Fetcher.FetchedConnection>)]) {
//        let previousControllers = self.connectionControllersRelay.value
//        var controllers = [Identifier : ConnectionController<Fetcher, Parser>]()
//        for (identifier, state) in states {
//            if let controller = previousControllers[identifier] {
//                controller.reset(to: state)
//                controllers[identifier] = controller
//            } else {
//                controllers[identifier] = self.factory.create(with: state)
//            }
//        }
//
//        self.connectionControllersRelay.accept(controllers)
//    }

    func controller(for identifier: Identifier) -> ConnectionController<Fetcher, Parser>? {
        return self.connectionControllersRelay.value[identifier]
    }

    func pages(for identifiers: [Identifier]) -> [Identifier : [Page<Parser.Model>]] {
        let controllers = self.connectionControllersRelay.value
        return Dictionary(uniqueKeysWithValues: identifiers.lazy.map { ($0, controllers[$0]?.state.pages ?? []) })
    }
}
