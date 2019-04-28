
/**
 Parses nodes fetched from the server into another model type.
 */
public protocol ModelParser {
    associatedtype Node
    associatedtype Model: Hashable
    static func parse(node: Node) -> Model
}

public enum DefaultParser<Passthrough>: ModelParser where Passthrough: Hashable {
    public typealias Node = Passthrough
    public typealias Model = Passthrough
    public static func parse(node: Passthrough) -> Passthrough {
        return node
    }
}
