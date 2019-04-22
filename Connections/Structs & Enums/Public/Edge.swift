
public struct Edge<Model>: Hashable where Model: Hashable {
    public let node: Model
    public let cursor: String
}
