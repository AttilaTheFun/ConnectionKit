
public struct PaginationState: Hashable {
    let hasFetchedInitialPage: Bool
    let hasFetchedLastPageFromHead: Bool
    let hasFetchedLastPageFromTail: Bool
}

extension PaginationState {
    /**
     The initial pagination state for an empty connection.
     */
    public static let initial = PaginationState(hasFetchedInitialPage: false, hasFetchedLastPageFromHead: false, hasFetchedLastPageFromTail: false)

    public init<P>(connectionPageInfo: P, from end: End) where P: ConnectionPageInfo {
        self = PaginationState.initial.nextState(pageInfo: PageInfo(connectionPageInfo: connectionPageInfo), from: end)
    }

    /**
     Instantiates a pagination state instance with the given page info fetched from the given end.
     */
    init(initialPageInfo: PageInfo, from end: End) {
        self = PaginationState.initial.nextState(pageInfo: initialPageInfo, from: end)
    }

    /**
     Compute the next state from the current state given a new page info object fetched from the given end.
     */
    func nextState(pageInfo: PageInfo, from end: End) -> PaginationState {
        switch end {
        case .head:
            // If ingesting from the head, only update canFetchNextPageFromHead.
            return PaginationState(
                hasFetchedInitialPage: true,
                hasFetchedLastPageFromHead: !pageInfo.hasNextPage,
                hasFetchedLastPageFromTail: self.hasFetchedLastPageFromTail
            )
        case .tail:
            // If ingesting from the tail, only update canFetchNextPageFromHead.
            return PaginationState(
                hasFetchedInitialPage: true,
                hasFetchedLastPageFromHead: self.hasFetchedLastPageFromHead,
                hasFetchedLastPageFromTail: !pageInfo.hasPreviousPage
            )
        }
    }
}

extension PaginationState {
    /**
     Whether the receiver has fetched the last page from the given end.
     */
    func hasFetchedLastPage(from end: End) -> Bool {
        switch end {
        case .head:
            return self.hasFetchedLastPageFromHead
        case .tail:
            return self.hasFetchedLastPageFromTail
        }
    }
}
