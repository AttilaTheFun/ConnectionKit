@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

// TODO: Additional tests to write:
// - page fetcher invalid cursor tests
// - pagination tracker tests
// - connection manager reset
// - connection manager initial page tests
// - connection manager multiple pages, both directions

class ConnectionManagerTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testEmptyConnection() throws {
        // Create test data:
        let defaultIndex = 0
        let allEdges: [TestEdge] = .create(count: 0)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages: [Page<TestFetcher>] = []

        // Create connection manager:
        let manager = ConnectionManager(fetcher: fetcher, initialPageSize: 2, paginationPageSize: 5)

        // Run test:
        try self.runHeadTest(manager: manager, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
        try self.runTailTest(manager: manager, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
    }

    func testIncompletePageForward() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 5
        let endIndex = defaultIndex + 5
        let allEdges: [TestEdge] = .create(count: 10)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedEdges = Array(allEdges[defaultIndex..<endIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection manager:
        let manager = ConnectionManager(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runTailTest(manager: manager, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
    }

    func testIncompletePageBackward() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 5
        let endIndex = 0
        let allEdges: [TestEdge] = .create(count: 10)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedEdges = Array(allEdges[endIndex..<defaultIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection manager:
        let manager = ConnectionManager(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runHeadTest(manager: manager, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
    }

    func testCompletePageForward() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let endIndex = defaultIndex + initialPageSize
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedEdges = Array(allEdges[defaultIndex..<endIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection manager:
        let manager = ConnectionManager(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runTailTest(manager: manager, expectedEndState: .hasNextPage, expectedPages: expectedPages)
    }

    func testCompletePageBackward() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let endIndex = defaultIndex - initialPageSize
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedEdges = Array(allEdges[endIndex..<defaultIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection manager:
        let manager = ConnectionManager(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runHeadTest(manager: manager, expectedEndState: .hasNextPage, expectedPages: expectedPages)
    }
}

// MARK: Head

extension ConnectionManagerTests {
    private func runHeadTest(
        manager: ConnectionManager<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>]) throws
    {

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            self.expectHeadHasNextPage(manager: manager),
            self.expectHeadIsFetchingNextPage(manager: manager),
            self.expectHeadEndedInState(
                manager: manager,
                expectedEndState: expectedEndState,
                expectedPages: expectedPages
            )
        ]

        // Run the test:
        manager.loadNextPage(from: .head)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectHeadHasNextPage(manager: ConnectionManager<TestFetcher>) -> XCTestExpectation {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        manager.headStateObservable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.hasNextPage)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectHeadIsFetchingNextPage(manager: ConnectionManager<TestFetcher>) -> XCTestExpectation {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        manager.headStateObservable
            .skip(1)
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.isFetchingNextPage)
                receivedFetchingStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedFetchingStateExpectation
    }

    private func expectHeadEndedInState(
        manager: ConnectionManager<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>])
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        manager.headStateObservable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                if state != expectedEndState {
                    XCTFail("Invalid state")
                    return
                }

                XCTAssertEqual(manager.pages, expectedPages)
                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedCompletedStateExpectation
    }
}


// MARK: Tail

extension ConnectionManagerTests {
    private func runTailTest(
        manager: ConnectionManager<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>]) throws
    {

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            self.expectTailHasNextPage(manager: manager),
            self.expectTailIsFetchingNextPage(manager: manager),
            self.expectTailEndedInState(
                manager: manager,
                expectedEndState: expectedEndState,
                expectedPages: expectedPages
            )
        ]

        // Run the test:
        manager.loadNextPage(from: .tail)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectTailHasNextPage(manager: ConnectionManager<TestFetcher>) -> XCTestExpectation {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        manager.tailStateObservable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.hasNextPage)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectTailIsFetchingNextPage(manager: ConnectionManager<TestFetcher>) -> XCTestExpectation {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        manager.tailStateObservable
            .skip(1)
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.isFetchingNextPage)
                receivedFetchingStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedFetchingStateExpectation
    }

    private func expectTailEndedInState(
        manager: ConnectionManager<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>])
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        manager.tailStateObservable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                if state != expectedEndState {
                    XCTFail("Invalid state")
                    return
                }

                XCTAssertEqual(manager.pages, expectedPages)
                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedCompletedStateExpectation
    }
}
