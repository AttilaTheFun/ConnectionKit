
public enum InitialLoadState: Hashable {
    case idle
    case fetching
    case error(ErrorWrapper)
}

extension InitialLoadState {
    init<F>(pageFetcherState: PageFetcherState<F>) {
        switch pageFetcherState {
        case .idle, .completed:
            self = .idle
        case .fetching:
            self = .fetching
        case .error(let error):
            self = .error(error)
        }
    }
}
