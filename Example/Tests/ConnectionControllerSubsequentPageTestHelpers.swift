@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

extension XCTestCase {
    func runSubsequentPageTest(
        controller: ConnectionController<TestFetcher>,
        fetchFrom end: End,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>],
        disposedBy disposeBag: DisposeBag) throws
    {
        let observable = controller.stateObservable(for: end)

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            try self.expectHasNextPage(observable: observable, disposedBy: disposeBag),
            try self.expectIsFetchingNextPage(observable: observable, disposedBy: disposeBag),
            try self.expectHeadEndedInState(
                observable: observable,
                controller: controller,
                expectedEndState: expectedEndState,
                expectedPages: expectedPages,
                disposedBy: disposeBag
            )
        ]

        // Run the test:
        controller.loadNextPage(from: end)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectHasNextPage(
        observable: Observable<EndState>,
        disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
    {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        observable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, .idle)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectIsFetchingNextPage(
        observable: Observable<EndState>,
        disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
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

    private func expectHeadEndedInState(
        observable: Observable<EndState>,
        controller: ConnectionController<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>],
        disposedBy disposeBag: DisposeBag) throws -> XCTestExpectation
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

                XCTAssertEqual(controller.pages, expectedPages)
                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedCompletedStateExpectation
    }
}
