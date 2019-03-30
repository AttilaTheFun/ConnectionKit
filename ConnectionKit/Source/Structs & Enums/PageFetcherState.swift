
/**
 Encapsulates the possible states of a page fetcher.
 The initial state is idle.
 The possible transitions are:
 - idle -> fetching
 - fetching -> complete
 - fetching -> error
 - error -> fetching
 */
enum PageFetcherState<F> where F: ConnectionFetcher {
    // The fetcher has not started fetching a page.
    case idle

    // The fetcher is actively fetching a page.
    case fetching

    // The fetcher completed fetching a page.
    case completed([Edge<F>], PageInfo<F>)

    // The fetcher failed to fetch a page.
    case error(ErrorWrapper)
}

extension PageFetcherState {
    var canLoadPage: Bool {
        switch self {
        case .idle, .completed, .error:
            return true
        case .fetching:
            return false
        }
    }
}

extension PageFetcherState: Equatable where
F.FetchedConnection.ConnectedPageInfo : Equatable,
F.FetchedConnection.ConnectedEdge: Equatable
{}

extension PageFetcherState: Hashable where
    F.FetchedConnection.ConnectedPageInfo : Hashable,
    F.FetchedConnection.ConnectedEdge: Hashable
{}
