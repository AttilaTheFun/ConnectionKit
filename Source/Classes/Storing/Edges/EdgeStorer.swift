import RxCocoa
import RxSwift

public final class EdgeStorer<Model> {
    private(set) public var edges: [Edge<Model>]

    public init(initialEdges: [Edge<Model>] = []) {
        self.edges = initialEdges
    }
}

// MARK: Getters

extension EdgeStorer: EdgeStorable {
    public func ingest(edges: [Edge<Model>], from end: End) {
        self.edges = Edge<Model>.nextEdges(from: self.edges, ingesting: edges, from: end)
    }

    public func reset(to initialEdges: [Edge<Model>]) {
        self.edges = initialEdges
    }
}
