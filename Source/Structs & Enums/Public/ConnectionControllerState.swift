
public struct ConnectionControllerState {
    public let initialLoadState: InitialLoadState
    public let headState: EndState
    public let tailState: EndState
    let paginationState: PaginationState
}

// MARK: Initialization

extension ConnectionControllerState {
    init<Node>(
        hasCompletedInitialLoad: Bool,
        pageFetcherCoordinatorState: CombinedPageFetcherState<Node>,
        paginationState: PaginationState)
    {
        let initialHeadFetcherState = pageFetcherCoordinatorState.state(for: .head, isInitial: true)
        let initialTailFetcherState = pageFetcherCoordinatorState.state(for: .tail, isInitial: true)
        self.initialLoadState = InitialLoadState(
            headPageFetcherState: initialHeadFetcherState,
            tailPageFetcherState: initialTailFetcherState,
            hasCompletedInitialLoad: hasCompletedInitialLoad
        )

        let headFetcherState = pageFetcherCoordinatorState.state(for: .head, isInitial: false)
        let headHasFetchedLastPage = paginationState.hasFetchedLastPage(from: .head)
        self.headState = EndState(pageFetcherState: headFetcherState, hasFetchedLastPage: headHasFetchedLastPage)

        let tailFetcherState = pageFetcherCoordinatorState.state(for: .tail, isInitial: false)
        let tailHasFetchedLastPage = paginationState.hasFetchedLastPage(from: .tail)
        self.tailState = EndState(pageFetcherState: tailFetcherState, hasFetchedLastPage: tailHasFetchedLastPage)

        self.paginationState = paginationState
    }
}

// MARK: Getters

extension ConnectionControllerState {

    /**
     Get the state of the given end of the connection.
     */
    public func endState(for end: End) -> EndState {
        switch end {
        case .head:
            return self.headState
        case .tail:
            return self.tailState
        }
    }
}
