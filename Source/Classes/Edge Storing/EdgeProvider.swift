
public protocol EdgeProvider: EdgeStorable {
    var edges: [Edge<Model>] { get }
}
