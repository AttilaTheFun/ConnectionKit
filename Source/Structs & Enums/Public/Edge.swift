
public struct Edge<Model> {
    public let node: Model
    public let cursor: String

    public init(node: Model, cursor: String) {
        self.node = node
        self.cursor = cursor
    }
}

extension Edge: Equatable where Model: Equatable {}
extension Edge: Hashable where Model: Hashable {}

extension Edge {
    static func nextEdges(from previousEdges: [Edge<Model>], ingesting edges: [Edge<Model>], from end: End) -> [Edge<Model>] {
        switch end {
        case .head:
            return previousEdges + edges
        case .tail:
            return edges + previousEdges
        }
    }
}
