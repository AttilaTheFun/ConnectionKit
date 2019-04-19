
public final class NestedConnectionController<Node, Fetcher, Parser, NodeFetcher, NestedNode, NestedFetcher, NestedParser> {
//    where
//    // Conformances
//    Node: NestedConnectionNode,
//    Fetcher: ConnectionFetcherProtocol,
//    Parser: ModelParser,
//    NodeFetcher: NodeFetcherProtocol,
//    NestedFetcher: ConnectionFetcherProtocol,
//    NestedParser: ModelParser,
//    // Conditions
//    Node == Fetcher.FetchedConnection.ConnectedEdge.Node,
//    Node == NodeFetcher.Node,
//    Node == Parser.Node,
//    NestedNode == NestedFetcher.FetchedConnection.ConnectedEdge.Node,
//    NestedNode == Node.NestedConnection.ConnectedEdge.Node,
//    NestedNode == NestedParser.Node
//{
//    // Chronological connection over the outer nodes sorted by their most recent inner nodes.
//    private let outerController: ConnectionController<Fetcher, Parser>
//
//    // Chronological connection over the inner nodes.
//    private let innerController: ConnectionController<NestedFetcher, NestedParser>
//
//    // Nested connection controllers over the inner nodes per thread.
//    private var nestedControllers: [String : ConnectionController<NestedFetcher, NestedParser>]
//
//    init(fetcher: Fetcher, parser: Parser.Type, nestedFetcher: NestedFetcher, nestedParser: NestedParser.Type) {
//        self.outerController = ConnectionController(fetcher: fetcher, parser: parser, initialPageSize: 10, paginationPageSize: 10)
//        self.innerController = ConnectionController(fetcher: nestedFetcher, parser: nestedParser, initialPageSize: 25, paginationPageSize: 25)
//        self.nestedControllers = [:]
//    }
}

