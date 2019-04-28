import RxCocoa
import RxSwift

final class ParsingPageStorer<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    private let rawStorer: PageStorer<Node>
    private let parsedStorer: PageStorer<Parser.Model>

    public init(initialEdges: [Edge<Node>] = []) {
        self.rawStorer = PageStorer(initialEdges: initialEdges)
        let parsedEdges = ParsingPageStorer<Fetcher, Parser>.parsedEdges(from: initialEdges)
        self.parsedStorer = PageStorer(initialEdges: parsedEdges)
    }
}

// MARK: Private

extension ParsingPageStorer {
    private static func parsedEdges(from edges: [Edge<Node>]) -> [Edge<Parser.Model>] {
        return edges.map { edge -> Edge<Parser.Model> in
            let node = Parser.parse(node: edge.node)
            return Edge(node: node, cursor: edge.cursor)
        }
    }
}

// MARK: Getters

extension ParsingPageStorer: PageStorable {
    var parsedPages: [Page<Parser.Model>] {
        return self.parsedStorer.pages
    }

    var pages: [Page<Node>] {
        return self.rawStorer.pages
    }

    func ingest(edges: [Edge<Node>], from end: End) {
        self.rawStorer.ingest(edges: edges, from: end)
        let parsedEdges = ParsingPageStorer<Fetcher, Parser>.parsedEdges(from: edges)
        self.parsedStorer.ingest(edges: parsedEdges, from: end)
    }

    func reset(to initialEdges: [Edge<Node>]) {
        self.rawStorer.reset(to: initialEdges)
        let parsedEdges = ParsingPageStorer<Fetcher, Parser>.parsedEdges(from: initialEdges)
        self.parsedStorer.reset(to: parsedEdges)
    }
}
