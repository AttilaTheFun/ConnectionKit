import RxSwift

public protocol NodeFetcherProtocol {
    associatedtype Node
    func fetch(id: String) -> Maybe<Node>
}
