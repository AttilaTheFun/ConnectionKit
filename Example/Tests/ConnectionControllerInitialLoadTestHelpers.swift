@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

extension XCTestCase {
    func runInitialLoadTest(
        controller: ConnectionController<TestFetcher, TestParser>,
        fetchFrom end: End,
        expectedEndState: InitialLoadState,
        expectedPages: [Page<TestModel>],
        disposedBy disposeBag: DisposeBag) throws
    {
        let observable = controller.initialLoadStateObservable(for: end)

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            try self.expectInitialLoadBeganInState(
                observable: observable,
                fetchFrom: end,
                expectedBeginState: controller.initialLoadState(for: end) == .idle ? .idle : .complete,
                disposedBy: disposeBag
            ),
            try self.expectInitialLoadIsFetchingInitialPage(
                observable: observable,
                fetchFrom: end,
                disposedBy: disposeBag
            ),
            try self.expectInitialLoadEndedInState(
                observable: observable,
                fetchFrom: end,
                expectedEndState: expectedEndState,
                disposedBy: disposeBag
            )
        ]

        // Run the test:
        controller.loadInitialPage(from: end)

        XCTAssertEqual(controller.pages, expectedPages)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectInitialLoadBeganInState(
        observable: Observable<InitialLoadState>,
        fetchFrom end: End,
        expectedBeginState: InitialLoadState,
        disposedBy disposeBag: DisposeBag) throws
        -> XCTestExpectation
    {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        observable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, expectedBeginState)
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
                XCTAssertEqual(state, .fetching)
                receivedFetchingStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedFetchingStateExpectation
    }

    private func expectInitialLoadEndedInState(
        observable: Observable<InitialLoadState>,
        fetchFrom end: End,
        expectedEndState: InitialLoadState,
        disposedBy disposeBag: DisposeBag) throws
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        observable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                if state != expectedEndState {
                    XCTFail("Invalid state")
                    return
                }

                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedCompletedStateExpectation
    }
}
