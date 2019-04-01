
public struct Page<M>: Hashable where M: Hashable {
    public let index: Int
    public let edges: [Edge<M>]
}
