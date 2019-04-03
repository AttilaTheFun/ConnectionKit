@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class ConnectionControllerSubsequentPageTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testSubsequentIncompletePageHead() throws {
        // Create test config:
        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 20, defaultIndex: 10)

        // Calculate pages:
        let initialHeadPage = config.initialPage(for: .head)
        let subsequentHeadPage = config.subsequentPage(relativeTo: [initialHeadPage], for: .head)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .end,
            expectedPages: [
                subsequentHeadPage,
                initialHeadPage,
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .end)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)
    }

    func testSubsequentIncompletePageTail() throws {
        // Create test config:
        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 20, defaultIndex: 10)

        // Calculate pages:
        let initialTailPage = config.initialPage(for: .tail)
        let subsequentTailPage = config.subsequentPage(relativeTo: [initialTailPage], for: .tail)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .end,
            expectedPages: [
                initialTailPage,
                subsequentTailPage,
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .end)
    }

    func testSubsequentIncompletePageBoth() throws {
        // Create test config:
        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 15, defaultIndex: 10)

        // Calculate pages:
        let initialHeadPage = config.initialPage(for: .head)
        let subsequentHeadPage = config.subsequentPage(relativeTo: [initialHeadPage], for: .head)
        let subsequentTailPage = config.subsequentPage(relativeTo: [subsequentHeadPage, initialHeadPage], for: .tail)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run head test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .end,
            expectedPages: [
                subsequentHeadPage,
                initialHeadPage,
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .end)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run tail test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .end,
            expectedPages: [
                subsequentHeadPage,
                initialHeadPage,
                subsequentTailPage,
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .end)
        XCTAssertEqual(config.controller.state(for: .tail), .end)
    }

    func testSubsequentCompletePageHead() throws {
        // Create test config:
        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100, defaultIndex: 50)

        // Calculate pages:
        let initialHeadPage = config.initialPage(for: .head)
        let subsequentHeadPage = config.subsequentPage(relativeTo: [initialHeadPage], for: .head)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [
                subsequentHeadPage,
                initialHeadPage
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)
    }

    func testSubsequentCompletePageTail() throws {
        // Create test config:
        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100, defaultIndex: 50)

        // Calculate pages:
        let initialTailPage = config.initialPage(for: .tail)
        let subsequentTailPage = config.subsequentPage(relativeTo: [initialTailPage], for: .tail)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [
                initialTailPage,
                subsequentTailPage
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)
    }

    func testSubsequentResetHead() throws {
        // Create test config:
        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100, defaultIndex: 50)

        // Calculate pages:
        let initialHeadPage = config.initialPage(for: .head)
        let subsequentHeadPage = config.subsequentPage(relativeTo: [initialHeadPage], for: .head)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [
                subsequentHeadPage,
                initialHeadPage
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [
                subsequentHeadPage,
                initialHeadPage
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)
    }

    func testSubsequentResetTail() throws {
        // Create test config:
        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100, defaultIndex: 50)

        // Calculate pages:
        let initialTailPage = config.initialPage(for: .tail)
        let subsequentTailPage = config.subsequentPage(relativeTo: [initialTailPage], for: .tail)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [
                initialTailPage,
                subsequentTailPage,
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Load initial page:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [
                initialTailPage,
                subsequentTailPage,
            ],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state(for: .head), .idle)
        XCTAssertEqual(config.controller.state(for: .tail), .idle)
    }

//    func testBothCompletePages() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 50
//        let allEdges: [TestEdge] = .create(count: 100)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//
//        let backwardEndIndex = defaultIndex - initialPageSize
//        let expectedBackwardEdges = Array(allEdges[backwardEndIndex..<defaultIndex])
//        let expectedBackwardPages = [Page<TestFetcher>(index: 0, edges: expectedBackwardEdges)]
//
//        let forwardEndIndex = defaultIndex + initialPageSize
//        let expectedForwardEdges = Array(allEdges[defaultIndex..<forwardEndIndex])
//        let expectedForwardPages = expectedBackwardPages + [Page<TestFetcher>(index: 1, edges: expectedForwardEdges)]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runHeadTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedBackwardPages)
//        try self.runTailTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedForwardPages)
//    }
//
//    func testBothReset() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 50
//        let allEdges: [TestEdge] = .create(count: 100)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//
//        let backwardEndIndex = defaultIndex - initialPageSize
//        let expectedBackwardEdges = Array(allEdges[backwardEndIndex..<defaultIndex])
//        let expectedBackwardPages = [Page<TestFetcher>(index: 0, edges: expectedBackwardEdges)]
//
//        let forwardEndIndex = defaultIndex + initialPageSize
//        let expectedForwardEdges = Array(allEdges[defaultIndex..<forwardEndIndex])
//        let expectedForwardPages = expectedBackwardPages + [Page<TestFetcher>(index: 1, edges: expectedForwardEdges)]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runHeadTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedBackwardPages)
//        try self.runTailTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedForwardPages)
//
////        controller
//        XCTAssertEqual(controller.pages, [])
//        XCTAssertEqual(controller.headState, .hasNextPage)
//        XCTAssertEqual(controller.tailState, .hasNextPage)
//    }
}


