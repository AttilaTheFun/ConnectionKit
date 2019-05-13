
public protocol ParsedEdgeProvider {
    associatedtype ParsedModel
    var parsedEdges: [Edge<ParsedModel>] { get }
}
