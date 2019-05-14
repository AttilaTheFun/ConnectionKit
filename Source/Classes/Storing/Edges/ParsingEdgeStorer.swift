import RxCocoa
import RxSwift

public final class ParsingEdgeStorer<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    public typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    private let rawStorer: EdgeStorer<Node>
    private let parsedStorer: EdgeStorer<Parser.Model>

    public init(initialEdges: [Edge<Node>] = []) {
        self.rawStorer = EdgeStorer(initialEdges: initialEdges)
        let parsedEdges = Parser.parsedEdges(from: initialEdges)
        self.parsedStorer = EdgeStorer(initialEdges: parsedEdges)
    }
}

// MARK: ParsedPageProvider

extension ParsingEdgeStorer: ParsedEdgeProvider {
    public var parsedEdges: [Edge<Parser.Model>] {
        return self.parsedStorer.edges
    }
}

// MARK: Getters

extension ParsingEdgeStorer: EdgeStorable {
    public var edges: [Edge<Parser.Node>] {
        return self.rawStorer.edges
    }

    public func ingest(edges: [Edge<Node>], from end: End) {
        self.rawStorer.ingest(edges: edges, from: end)
        let parsedEdges = Parser.parsedEdges(from: edges)
        self.parsedStorer.ingest(edges: parsedEdges, from: end)
    }

    public func reset(to initialEdges: [Edge<Node>]) {
        self.rawStorer.reset(to: initialEdges)
        let parsedEdges = Parser.parsedEdges(from: initialEdges)
        self.parsedStorer.reset(to: parsedEdges)
    }
}
