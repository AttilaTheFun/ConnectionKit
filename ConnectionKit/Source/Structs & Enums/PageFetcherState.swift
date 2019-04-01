
/**
 Encapsulates the possible states of a page fetcher.
 The initial state is idle.
 The possible transitions are:
 - idle -> fetching
 - fetching -> complete
 - fetching -> error
 - error -> fetching
 */
enum PageFetcherState<M>: Hashable where M: Hashable {
    // The fetcher has not started fetching a page.
    case idle

    // The fetcher is actively fetching a page.
    case fetching

    // The fetcher completed fetching a page.
    case completed([Edge<M>], PageInfo)

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
