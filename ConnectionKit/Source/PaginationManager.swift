import RxCocoa
import RxSwift

fileprivate struct PaginationManagerState {
    let hasNextPage: Bool
    let hasPreviousPage: Bool

    static let initial = PaginationManagerState(hasNextPage: true, hasPreviousPage: true)
}

/**
 This class abstracts the logic around managing pagination capabilities.

 We start by assuming that we can paginate in either direction until the server tells us otherwise.
 */
final class PaginationManager<F> where F: ConnectionFetcher {
    private let stateRelay = BehaviorRelay<PaginationManagerState>(value: .initial)
}

// MARK: Interface

extension PaginationManager {
    /**
     If has next page is true, this means the server has a page which can be loaded after the tail.
     */
    var hasNextPage: Bool {
        return self.stateRelay.value.hasNextPage
    }

    /**
     If has previous page is true, this means the server has a page which can be loaded before the head.
     */
    var hasPreviousPage: Bool {
        return self.stateRelay.value.hasNextPage
    }

    /**
     Resetting the manager reverts it to its initial state, i.e.:
     - hasNextPage is true
     - hasPreviousPage is true
     */
    func reset() {
        self.stateRelay.accept(.initial)
    }

    /**
     Ingest a new page info object into the manager.
     */
    func ingest(pageInfo: PageInfo<F>, from end: End) {
        let currentState = self.stateRelay.value
        let newState: PaginationManagerState
        switch end {
        case .head:
            // If ingesting from the head, only update hasPreviousPage.
            newState = PaginationManagerState(
                hasNextPage: currentState.hasNextPage,
                hasPreviousPage: pageInfo.hasNextPage
            )
        case .tail:
            // If ingesting from the tail, only update hasNextPage.
            newState = PaginationManagerState(
                hasNextPage: pageInfo.hasNextPage,
                hasPreviousPage: currentState.hasPreviousPage
            )
        }
        self.stateRelay.accept(newState)
    }
}
