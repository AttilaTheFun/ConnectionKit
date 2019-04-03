
/**
 Encapsulates the possible states of an end of a connection (head or tail).
 The possible transitions are:
 - idle -> fetching
 - fetching -> idle
 - fetching -> error
 - fetching -> end
 All states could revert to idle if the connection was reset.
 */
public enum EndState: Hashable {
    case idle
    case fetching
    case error(ErrorWrapper)
    case end
}

extension EndState {
    init<F>(pageFetcherState: PageFetcherState<F>, hasFetchedLastPage: Bool) {
        switch (pageFetcherState, hasFetchedLastPage) {
        case (.fetching, _):
            self = .fetching
        case (.error(let error), _):
            self = .error(error)
        case (.idle, false), (.complete, false):
            self = .idle
        case (.idle, true), (.complete, true):
            self = .end
        }
    }
}
