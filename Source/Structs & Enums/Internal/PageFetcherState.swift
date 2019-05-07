
/**
 Encapsulates the possible states of a page fetcher.
 The initial state is idle.
 The possible transitions are:
 - idle -> fetching
 - fetching -> complete
 - fetching -> error
 - error -> fetching
 */
enum PageFetcherState<Model> {
    // The fetcher has not started fetching a page.
    case idle

    // The fetcher is actively fetching a page.
    case fetching

    // The fetcher completed fetching a page.
    case complete([Edge<Model>], PageInfo)

    // The fetcher failed to fetch a page.
    case error(ErrorWrapper)
}

extension PageFetcherState: Equatable where Model: Equatable {}
extension PageFetcherState: Hashable where Model: Hashable {}

extension PageFetcherState {
    var isLoadingPage: Bool {
        switch self {
        case .idle, .complete, .error:
            return false
        case .fetching:
            return true
        }
    }

    var canLoadPage: Bool {
        return !self.isLoadingPage
    }
}
