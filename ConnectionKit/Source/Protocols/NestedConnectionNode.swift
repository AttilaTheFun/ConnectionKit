
public protocol NestedConnectionNode {
    associatedtype NestedConnection: ConnectionProtocol
    var nestedConnection: NestedConnection { get }
}
