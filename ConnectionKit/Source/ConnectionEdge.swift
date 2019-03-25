
protocol ConnectionEdge {
    associatedtype Node
    var cursor: String { get }
    var node: Node { get }
}
