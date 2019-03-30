@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

extension XCTestCase {
    func runInitialLoadTest(
        controller: ConnectionController<TestFetcher>,
        fetchFrom end: End,
        expectedEndState: InitialLoadState,
        expectedPages: [Page<TestFetcher>],
        disposedBy disposeBag: DisposeBag) throws
    {
        // Create expectations:
        let expectations: [XCTestExpectation] = [
            try self.expectInitialLoadIdle(controller: controller, disposedBy: disposeBag),
            try self.expectInitialLoadIsFetchingInitialPage(controller: controller, disposedBy: disposeBag),
            try self.expectInitialLoadEndedInState(
                controller: controller,
                expectedEndState: expectedEndState,
                expectedPages: expectedPages,
                disposedBy: disposeBag
            )
        ]

        // Run the test:
        controller.loadInitialPage(from: end)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectInitialLoadIdle(controller: ConnectionController<TestFetcher>,
                                       disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
    {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        controller.initialLoadStateObservable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, .idle)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectInitialLoadIsFetchingInitialPage(controller: ConnectionController<TestFetcher>,
                                                        disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
    {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        controller.initialLoadStateObservable
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
        controller: ConnectionController<TestFetcher>,
        expectedEndState: InitialLoadState,
        expectedPages: [Page<TestFetcher>],
        disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        controller.initialLoadStateObservable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                if state != expectedEndState {
                    XCTFail("Invalid state")
                    return
                }

                XCTAssertEqual(controller.pages, expectedPages)
                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedCompletedStateExpectation
    }
}
