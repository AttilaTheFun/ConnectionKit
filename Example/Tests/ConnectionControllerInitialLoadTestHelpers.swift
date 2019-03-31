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
            try self.expectInitialLoadIdle(
                controller: controller,
                fetchFrom: end,
                disposedBy: disposeBag
            ),
            try self.expectInitialLoadIsFetchingInitialPage(
                controller: controller,
                fetchFrom: end,
                disposedBy: disposeBag
            ),
            try self.expectInitialLoadEndedInState(
                controller: controller,
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

    private func expectInitialLoadIdle(controller: ConnectionController<TestFetcher>,
                                       fetchFrom end: End,
                                       disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
    {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        controller.initialLoadStateObservable(for: end)
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, .idle)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectInitialLoadIsFetchingInitialPage(controller: ConnectionController<TestFetcher>,
                                                        fetchFrom end: End,
                                                        disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
    {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        controller.initialLoadStateObservable(for: end)
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
        fetchFrom end: End,
        expectedEndState: InitialLoadState,
        disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        controller.initialLoadStateObservable(for: end)
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
