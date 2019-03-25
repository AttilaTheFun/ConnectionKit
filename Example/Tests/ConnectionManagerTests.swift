@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class ConnectionManagerTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testEmptyConnection() throws {
        // Create test data:
        let startIndex = 0
        let edges: [TestEdge] = .create(count: 0)
        let fetcher = TestFetcher(startIndex: startIndex, edges: edges)
        let expectedEdges = edges
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection manager:
        let manager = ConnectionManager(fetcher: fetcher, initialPageSize: 2, paginationPageSize: 5)

        // Run test:
        try self.runTailTest(manager: manager, expectedPages: expectedPages)
    }

    func testCompletePageForward() throws {
        // Create test data:
        let initialPageSize = 2
        let startIndex = 50
        let endIndex = startIndex + 2
        let edges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(startIndex: startIndex, edges: edges)
        let expectedEdges = Array(edges[50..<endIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection manager:
        let manager = ConnectionManager(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runTailTest(manager: manager, expectedPages: expectedPages)
    }
}

// MARK: Private Utils

extension ConnectionManagerTests {
    private func runTailTest(
        manager: ConnectionManager<TestFetcher>,
        expectedPages: [Page<TestFetcher>]) throws
    {

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            self.expectIdleTail(manager: manager),
            self.expectFetchingTail(manager: manager),
            self.expectCompletedTail(manager: manager, expectedPages: expectedPages)
        ]

        // Run the test:
        manager.loadNextPage(from: .tail)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectIdleTail(manager: ConnectionManager<TestFetcher>) -> XCTestExpectation {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        manager.tailStateObservable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.idle)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectFetchingTail(manager: ConnectionManager<TestFetcher>) -> XCTestExpectation {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        manager.tailStateObservable
            .skip(1)
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.fetching)
                receivedFetchingStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedFetchingStateExpectation
    }

    private func expectCompletedTail(
        manager: ConnectionManager<TestFetcher>,
        expectedPages: [Page<TestFetcher>])
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        manager.tailStateObservable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                guard case .idle = state else {
                    XCTFail("Invalid state")
                    return
                }

                XCTAssertEqual(manager.pages, expectedPages)
                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedCompletedStateExpectation
    }

    private func expectError(_ fetcher: PageFetcher<TestFetcher>) -> XCTestExpectation {
        let receivedErrorStateExpectation = XCTestExpectation(description: "Received error state update")
        fetcher.stateObservable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                guard case .error(let wrappedError) = state else {
                    XCTFail("Invalid state")
                    return
                }

                print(wrappedError.error)
                receivedErrorStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedErrorStateExpectation
    }
}
