import RxSwift

/**
 The type of the connection fetched by the given fetcher.
 */
public typealias FetchedConnection<F> = F.FetchedConnection where F: ConnectionFetcher
public typealias PageInfo<F> = FetchedConnection<F>.ConnectedPageInfo where F: ConnectionFetcher
public typealias Edge<F> = FetchedConnection<F>.ConnectedEdge where F: ConnectionFetcher

/**
 A closure wrapping the logic to fetch a specific page of data.
 */
typealias FetchablePage<F> = () -> Maybe<FetchedConnection<F>> where F: ConnectionFetcher
