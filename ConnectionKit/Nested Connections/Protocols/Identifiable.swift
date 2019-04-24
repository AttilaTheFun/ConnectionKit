
public protocol Identifiable {
    associatedtype Identity: Hashable
    var identity: Identity { get }
}
