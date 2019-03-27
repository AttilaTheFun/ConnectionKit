@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

// TODO: Additional tests to write:
// - connection controller reset
// - connection controller initial page tests
// - connection controller multiple pages, both directions
// - page fetcher invalid cursor tests

class ConnectionControllerTests: XCTestCase {

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

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: 2, paginationPageSize: 5)

        // Run test:
        try self.runHeadTest(controller: controller, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
        try self.runTailTest(controller: controller, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
    }

    func testForwardIncompletePage() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 5
        let endIndex = defaultIndex + 5
        let allEdges: [TestEdge] = .create(count: 10)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedEdges = Array(allEdges[defaultIndex..<endIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runTailTest(controller: controller, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
    }

    func testBackwardIncompletePage() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 5
        let endIndex = 0
        let allEdges: [TestEdge] = .create(count: 10)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedEdges = Array(allEdges[endIndex..<defaultIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runHeadTest(controller: controller, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
    }

    func testForwardCompletePage() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let endIndex = defaultIndex + initialPageSize
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let expectedEdges = Array(allEdges[defaultIndex..<endIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runTailTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedPages)
    }

    func testBackwardCompletePage() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let endIndex = defaultIndex - initialPageSize
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let expectedEdges = Array(allEdges[endIndex..<defaultIndex])
        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runHeadTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedPages)
    }

    func testBothCompletePages() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let backwardEndIndex = defaultIndex - initialPageSize
        let expectedBackwardEdges = Array(allEdges[backwardEndIndex..<defaultIndex])
        let expectedBackwardPages = [Page<TestFetcher>(index: 0, edges: expectedBackwardEdges)]

        let forwardEndIndex = defaultIndex + initialPageSize
        let expectedForwardEdges = Array(allEdges[defaultIndex..<forwardEndIndex])
        let expectedForwardPages = expectedBackwardPages + [Page<TestFetcher>(index: 1, edges: expectedForwardEdges)]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runHeadTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedBackwardPages)
        try self.runTailTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedForwardPages)
    }

    func testBothReset() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let backwardEndIndex = defaultIndex - initialPageSize
        let expectedBackwardEdges = Array(allEdges[backwardEndIndex..<defaultIndex])
        let expectedBackwardPages = [Page<TestFetcher>(index: 0, edges: expectedBackwardEdges)]

        let forwardEndIndex = defaultIndex + initialPageSize
        let expectedForwardEdges = Array(allEdges[defaultIndex..<forwardEndIndex])
        let expectedForwardPages = expectedBackwardPages + [Page<TestFetcher>(index: 1, edges: expectedForwardEdges)]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runHeadTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedBackwardPages)
        try self.runTailTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedForwardPages)

        controller.reset()
        XCTAssertEqual(controller.pages, [])
        XCTAssertEqual(controller.headState, .hasNextPage)
        XCTAssertEqual(controller.tailState, .hasNextPage)
    }
}

// MARK: Head

extension ConnectionControllerTests {
    private func runHeadTest(
        controller: ConnectionController<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>]) throws
    {

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            self.expectHeadHasNextPage(controller: controller),
            self.expectHeadIsFetchingNextPage(controller: controller),
            self.expectHeadEndedInState(
                controller: controller,
                expectedEndState: expectedEndState,
                expectedPages: expectedPages
            )
        ]

        // Run the test:
        controller.loadNextPage(from: .head)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectHeadHasNextPage(controller: ConnectionController<TestFetcher>) -> XCTestExpectation {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        controller.headStateObservable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.hasNextPage)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectHeadIsFetchingNextPage(controller: ConnectionController<TestFetcher>) -> XCTestExpectation {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        controller.headStateObservable
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
        controller: ConnectionController<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>])
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        controller.headStateObservable
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
            .disposed(by: self.disposeBag)

        return receivedCompletedStateExpectation
    }
}


// MARK: Tail

extension ConnectionControllerTests {
    private func runTailTest(
        controller: ConnectionController<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>]) throws
    {

        // Create expectations:
        let expectations: [XCTestExpectation] = [
            self.expectTailHasNextPage(controller: controller),
            self.expectTailIsFetchingNextPage(controller: controller),
            self.expectTailEndedInState(
                controller: controller,
                expectedEndState: expectedEndState,
                expectedPages: expectedPages
            )
        ]

        // Run the test:
        controller.loadNextPage(from: .tail)

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectTailHasNextPage(controller: ConnectionController<TestFetcher>) -> XCTestExpectation {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        controller.tailStateObservable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, EndState.hasNextPage)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectTailIsFetchingNextPage(controller: ConnectionController<TestFetcher>) -> XCTestExpectation {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        controller.tailStateObservable
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
        controller: ConnectionController<TestFetcher>,
        expectedEndState: EndState,
        expectedPages: [Page<TestFetcher>])
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        controller.tailStateObservable
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
            .disposed(by: self.disposeBag)

        return receivedCompletedStateExpectation
    }
}
