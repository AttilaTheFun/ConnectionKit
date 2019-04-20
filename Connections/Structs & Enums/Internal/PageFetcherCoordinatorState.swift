
struct PageFetcherCoordinatorState<Model>: Hashable where Model: Hashable {
    let initialHeadPageFetcherState: PageFetcherState<Model>
    let initialTailPageFetcherState: PageFetcherState<Model>
    let headPageFetcherState: PageFetcherState<Model>
    let tailPageFetcherState: PageFetcherState<Model>
}

extension PageFetcherCoordinatorState {
    /**
     Retrieve the state for the fetcher matching the given parameters.
     */
    func fetcherState(for end: End, isInitial: Bool) -> PageFetcherState<Model> {
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
