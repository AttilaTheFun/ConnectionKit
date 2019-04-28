@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

extension XCTestCase {
    func runInitialLoadTest(
        controller: ConnectionController<TestFetcher, TestParser>,
        fetchFrom end: End,
        expectedEndState: InitialLoadState.Status,
        expectedPages: [Page<TestModel>],
        disposedBy disposeBag: DisposeBag) throws
    {
        let initialLoadStateObservable = controller.stateObservable.map { $0.initialLoadState }

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            try self.expectInitialLoadBeganInState(
                observable: initialLoadStateObservable,
                fetchFrom: end,
                expectedBeginState: controller.state.initialLoadState.status,
                disposedBy: disposeBag
            ),
            try self.expectInitialLoadIsFetchingInitialPage(
                observable: initialLoadStateObservable,
                fetchFrom: end,
                disposedBy: disposeBag
            ),
            try self.expectInitialLoadEndedInState(
                observable: initialLoadStateObservable,
                fetchFrom: end,
                expectedEndState: expectedEndState,
                disposedBy: disposeBag
            )
        ]

        // Run the test:
        controller.loadInitialPage(from: end)

        XCTAssertEqual(controller.state.pages, expectedPages)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectInitialLoadBeganInState(
        observable: Observable<InitialLoadState>,
        fetchFrom end: End,
        expectedBeginState: InitialLoadState.Status,
        disposedBy disposeBag: DisposeBag) throws
        -> XCTestExpectation
    {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        observable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state.status, expectedBeginState)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectInitialLoadIsFetchingInitialPage(
        observable: Observable<InitialLoadState>,
        fetchFrom end: End,
        disposedBy disposeBag: DisposeBag) throws
        -> XCTestExpectation
    {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        observable
            .skip(1)
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state.status, .fetching)
                receivedFetchingStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedFetchingStateExpectation
    }

    private func expectInitialLoadEndedInState(
        observable: Observable<InitialLoadState>,
        fetchFrom end: End,
        expectedEndState: InitialLoadState.Status,
        disposedBy disposeBag: DisposeBag) throws
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        observable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                if state.status != expectedEndState {
                    XCTFail("Invalid state")
                    return
                }

                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedCompletedStateExpectation
    }
}
