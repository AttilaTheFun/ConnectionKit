import RxSwift

/**
 The type of the connection fetched by the given fetcher.
 */
public typealias FetchedConnection<F> = F.FetchedConnection where F: ConnectionFetcherProtocol
