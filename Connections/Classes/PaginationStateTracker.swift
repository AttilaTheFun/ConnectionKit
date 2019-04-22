import RxCocoa
import RxSwift

/**
 This class tracks the paginablity from the two ends of the connection.

 We start by assuming that we can paginate in either direction until the server tells us otherwise.
 Whenever we ingest new page info from either end, we update the state to indicate whether or not we can fetch any more
 pages from the relevant end.
 */
final class PaginationStateTracker {
    /**
     The pagination state of the connection.
     */
    private(set) var state: PaginationState

    /**
     Initializes the receiver with a known pagination state.
     */
    init(initialState: PaginationState) {
        self.state = initialState
    }
}

// MARK: Mutations

extension PaginationStateTracker {
    /**
     Ingest a new page info object into the manager.
     */
    func ingest(pageInfo: PageInfo, from end: End) {
        self.state = self.state.nextState(pageInfo: pageInfo, from: end)
    }

    /**
     Resetting the tracker reverts it to its initial state:
     canFetchNextPageFromHead and canFetchNextPageFromTail are both true
     */
    func reset(initialState: PaginationState) {
        self.state = initialState
    }
}
