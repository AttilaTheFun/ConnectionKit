
public enum InitialLoadState: Hashable {
    // The connection has not started fetching a page.
    case idle

    // The connection is fetching an initial page or refreshing.
    case fetching

    // The connection completed fetching or refreshing its initial page
    case complete

    // The connection
    case error(ErrorWrapper)
}

extension InitialLoadState {
    init<F>(pageFetcherState: PageFetcherState<F>) {
        switch pageFetcherState {
        case .idle:
            self = .idle
        case .fetching:
            self = .fetching
        case .complete:
            self = .complete
        case .error(let error):
            self = .error(error)
        }
    }
}
