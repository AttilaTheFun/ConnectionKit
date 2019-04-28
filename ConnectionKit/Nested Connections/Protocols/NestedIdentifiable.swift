
public protocol NestedIdentifiable: Identifiable {
    associatedtype ParentIdentity: Hashable
    var parentIdentity: ParentIdentity { get }
}
