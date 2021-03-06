import RxCocoa
import RxSwift

public final class ParsingPageStorer<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    public typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    private let rawStorer: PageStorer<Node>
    private let parsedStorer: PageStorer<Parser.Model>

    public init(initialEdges: [Edge<Node>] = []) {
        self.rawStorer = PageStorer(initialEdges: initialEdges)
        let parsedEdges = Parser.parsedEdges(from: initialEdges)
        self.parsedStorer = PageStorer(initialEdges: parsedEdges)
    }
}

// MARK: ParsedPageProvider

extension ParsingPageStorer: ParsedPageProvider {
    public var parsedPages: [Page<Parser.Model>] {
        return self.parsedStorer.pages
    }
}

// MARK: Getters

extension ParsingPageStorer: PageStorable {
    public var pages: [Page<Node>] {
        return self.rawStorer.pages
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
