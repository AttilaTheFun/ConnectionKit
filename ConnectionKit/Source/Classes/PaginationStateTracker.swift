import RxCocoa
import RxSwift

private struct PaginationState {
    static let initial = PaginationState(hasFetchedLastPageFromHead: false, hasFetchedLastPageFromTail: false)
    let hasFetchedLastPageFromHead: Bool
    let hasFetchedLastPageFromTail: Bool

    func hasFetchedLastPage(from end: End) -> Bool {
        switch end {
        case .head:
            return self.hasFetchedLastPageFromHead
        case .tail:
            return self.hasFetchedLastPageFromTail
        }
    }
}

/**
 This class tracks the paginablity from the two ends of the connection.

 We start by assuming that we can paginate in either direction until the server tells us otherwise.
 Whenever we ingest new page info from either end, we update the state to indicate whether or not we can fetch any more
 pages from the relevant end.
 */
final class PaginationStateTracker {
    private let stateRelay = BehaviorRelay<PaginationState>(value: .initial)
}

// MARK: Private

extension PaginationStateTracker {
    private func applyUpdate(from previousState: PaginationState, pageInfo: PageInfo, from end: End) {
        let newState: PaginationState
        switch end {
        case .head:
            // If ingesting from the head, only update canFetchNextPageFromHead.
            newState = PaginationState(
                hasFetchedLastPageFromHead: !pageInfo.hasNextPage,
                hasFetchedLastPageFromTail: previousState.hasFetchedLastPageFromTail
            )
        case .tail:
            // If ingesting from the tail, only update canFetchNextPageFromHead.
            newState = PaginationState(
                hasFetchedLastPageFromHead: previousState.hasFetchedLastPageFromHead,
                hasFetchedLastPageFromTail: !pageInfo.hasNextPage
            )
        }
        self.stateRelay.accept(newState)
    }
}

// MARK: Getters

extension PaginationStateTracker {
    /**
     Whether another page can be fetched from the given end.
     */
    func hasFetchedLastPage(from end: End) -> Bool {
        return self.stateRelay.value.hasFetchedLastPage(from: end)
    }

    /**
     Observable for the aforementioned state.
     */
    func hasFetchedLastPageObservable(from end: End) -> Observable<Bool> {
        return self.stateRelay.map { $0.hasFetchedLastPage(from: end) }
    }
}

// MARK: Mutations

extension PaginationStateTracker {
    /**
     Ingest a new page info object into the manager.
     */
    func ingest(pageInfo: PageInfo, from end: End) {
        self.applyUpdate(from: self.stateRelay.value, pageInfo: pageInfo, from: end)
    }

    /**
     Resetting the manager reverts it to its initial state, i.e.:
     canFetchNextPageFromHead and canFetchNextPageFromTail are both true
     */
    func reset(to pageInfo: PageInfo, from end: End) {
        self.applyUpdate(from: .initial, pageInfo: pageInfo, from: end)
    }
}
