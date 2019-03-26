import RxCocoa
import RxSwift

fileprivate struct PaginationState {
    let canFetchNextPageFromHead: Bool
    let canFetchNextPageFromTail: Bool

    static let initial = PaginationState(canFetchNextPageFromHead: true, canFetchNextPageFromTail: true)
}

/**
 This class tracks the paginablity from the two ends of the connection.

 We start by assuming that we can paginate in either direction until the server tells us otherwise.
 Whenever we ingest new page info from either end, we update the state to indicate whether or not we can fetch any more
 pages from the relevant end.
 */
final class PaginationStateTracker<F> where F: ConnectionFetcher {
    private let stateRelay = BehaviorRelay<PaginationState>(value: .initial)
}

// MARK: Interface

extension PaginationStateTracker {
    /**
     If has next page is true, this means the server has a page which can be loaded after the tail.
     */
    var canFetchNextPageFromHead: Bool {
        return self.stateRelay.value.canFetchNextPageFromHead
    }

    /**
     If has previous page is true, this means the server has a page which can be loaded before the head.
     */
    var canFetchNextPageFromTail: Bool {
        return self.stateRelay.value.canFetchNextPageFromTail
    }

    /**
     Ingest a new page info object into the manager.
     */
    func ingest(pageInfo: PageInfo<F>, from end: End) {
        let currentState = self.stateRelay.value
        let newState: PaginationState
        switch end {
        case .head:
            // If ingesting from the head, only update canFetchNextPageFromHead.
            newState = PaginationState(
                canFetchNextPageFromHead: pageInfo.hasNextPage,
                canFetchNextPageFromTail: currentState.canFetchNextPageFromTail
            )
        case .tail:
            // If ingesting from the tail, only update canFetchNextPageFromHead.
            newState = PaginationState(
                canFetchNextPageFromHead: currentState.canFetchNextPageFromHead,
                canFetchNextPageFromTail: pageInfo.hasNextPage
            )
        }
        self.stateRelay.accept(newState)
    }

    /**
     Resetting the manager reverts it to its initial state, i.e.:
     canFetchNextPageFromHead and canFetchNextPageFromTail are both true
     */
    func reset() {
        self.stateRelay.accept(.initial)
    }
}
