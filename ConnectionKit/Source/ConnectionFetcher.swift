import RxSwift

protocol ConnectionFetcher {
    associatedtype FetchedConnection where FetchedConnection: ConnectionProtocol
    func fetch(first: Int?, after: String?, last: Int?, before: String?) -> Maybe<FetchedConnection>
}
