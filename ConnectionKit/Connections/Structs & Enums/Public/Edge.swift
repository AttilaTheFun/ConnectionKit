
public struct Edge<Model> {
    public let node: Model
    public let cursor: String
}

extension Edge: Equatable where Model: Equatable {}
extension Edge: Hashable where Model: Hashable {}
