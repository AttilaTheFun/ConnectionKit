
struct CombinedPageFetcherState<Model> {
    let initialHeadPageFetcherState: PageFetcherState<Model>
    let initialTailPageFetcherState: PageFetcherState<Model>
    let headPageFetcherState: PageFetcherState<Model>
    let tailPageFetcherState: PageFetcherState<Model>
}

extension CombinedPageFetcherState: Equatable where Model: Equatable {}
extension CombinedPageFetcherState: Hashable where Model: Hashable {}

extension CombinedPageFetcherState {
    static var idle: CombinedPageFetcherState<Model> {
        return CombinedPageFetcherState(
            initialHeadPageFetcherState: .idle,
            initialTailPageFetcherState: .idle,
            headPageFetcherState: .idle,
            tailPageFetcherState: .idle
        )
    }

    func updated(with pageFetcherState: PageFetcherState<Model>, for end: End, isInitial: Bool) -> CombinedPageFetcherState<Model> {
        return CombinedPageFetcherState(
            initialHeadPageFetcherState: (end == .head && isInitial) ? pageFetcherState : self.initialHeadPageFetcherState,
            initialTailPageFetcherState: (end == .tail && isInitial) ? pageFetcherState : self.initialTailPageFetcherState,
            headPageFetcherState: (end == .head && !isInitial) ? pageFetcherState : self.headPageFetcherState,
            tailPageFetcherState: (end == .tail && !isInitial) ? pageFetcherState : self.tailPageFetcherState
        )
    }

    /**
     Retrieve the state for the fetcher matching the given parameters.
     */
    func state(for end: End, isInitial: Bool) -> PageFetcherState<Model> {
        switch (end, isInitial) {
        case (.head, true):
            return self.initialHeadPageFetcherState
        case (.tail, true):
            return self.initialTailPageFetcherState
        case (.head, false):
            return self.headPageFetcherState
        case (.tail, false):
            return self.tailPageFetcherState
        }
    }
}
