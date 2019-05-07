
public struct InitialLoadState: Hashable {
    public enum Status: Hashable {
        // The connection has not started fetching a page.
        case idle

        // The connection is fetching an initial page or refreshing.
        case fetching

        // The connection completed fetching or refreshing its initial page
        case complete

        // The connection
        case error(ErrorWrapper)
    }

    public let hasCompletedInitialLoad: Bool
    public let status: Status
}

extension InitialLoadState {
    init<F>(headPageFetcherState: PageFetcherState<F>, tailPageFetcherState: PageFetcherState<F>, hasCompletedInitialLoad: Bool) {
        self.hasCompletedInitialLoad = hasCompletedInitialLoad
        switch (headPageFetcherState, tailPageFetcherState, hasCompletedInitialLoad) {
        case (.fetching, .fetching, _):
            assertionFailure("Can't do initial load from both ends at once.")
            self.status = .fetching
        case (.fetching, _, _), (_, .fetching, _):
            self.status = .fetching
        case (.error(let error), _, _), (_, .error(let error), _):
            self.status = .error(error)
        case (.idle, .idle, false):
            self.status = .idle
        case (.idle, .idle, true), (.complete, _, _), (_, .complete, _):
            self.status = .complete
        }
    }
}
