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

    func testIncompleteSubsequentPageHead() throws {
        // Create test data:
        let initialPageSize = 5
        let paginationPageSize = 10
        let defaultIndex = 10
        let allEdges: [TestEdge] = .create(count: 20)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let initialPageStartIndex = max(defaultIndex - initialPageSize, 0)
        let initialPageEndIndex = defaultIndex
        let subsequentPageStartIndex = max(initialPageStartIndex - paginationPageSize, 0)
        let subsequentPageEndIndex = initialPageStartIndex

        let initialPageEdges = Array(allEdges[initialPageStartIndex..<initialPageEndIndex])
        let initialPage = Page<TestFetcher>(index: 0, edges: initialPageEdges)
        let subsequentPageEdges = Array(allEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
        let subsequentPage = Page<TestFetcher>(index: -1, edges: subsequentPageEdges)
        let expectedPages = [
            subsequentPage,
            initialPage,
        ]

        // Create connection controller:
        let controller = ConnectionController(
            fetcher: fetcher,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )

        // Load initial page:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [initialPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .end,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .end)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testIncompleteSubsequentPageTail() throws {
        // Create test data:
        let initialPageSize = 5
        let paginationPageSize = 10
        let defaultIndex = 10
        let allEdges: [TestEdge] = .create(count: 20)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let initialPageStartIndex = defaultIndex
        let initialPageEndIndex = min(defaultIndex + initialPageSize, allEdges.count)
        let subsequentPageStartIndex = initialPageEndIndex
        let subsequentPageEndIndex = min(initialPageEndIndex + paginationPageSize, allEdges.count)

        let initialPageEdges = Array(allEdges[initialPageStartIndex..<initialPageEndIndex])
        let initialPage = Page<TestFetcher>(index: 0, edges: initialPageEdges)
        let subsequentPageEdges = Array(allEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
        let subsequentPage = Page<TestFetcher>(index: 1, edges: subsequentPageEdges)
        let expectedPages = [
            initialPage,
            subsequentPage,
        ]

        // Create connection controller:
        let controller = ConnectionController(
            fetcher: fetcher,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )

        // Load initial page:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [initialPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .end,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .end)
    }

    func testCompleteSubsequentPageHead() throws {
        // Create test data:
        let initialPageSize = 5
        let paginationPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let initialPageStartIndex = max(defaultIndex - initialPageSize, 0)
        let initialPageEndIndex = defaultIndex
        let subsequentPageStartIndex = max(initialPageStartIndex - paginationPageSize, 0)
        let subsequentPageEndIndex = initialPageStartIndex

        let initialPageEdges = Array(allEdges[initialPageStartIndex..<initialPageEndIndex])
        let initialPage = Page<TestFetcher>(index: 0, edges: initialPageEdges)
        let subsequentPageEdges = Array(allEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
        let subsequentPage = Page<TestFetcher>(index: -1, edges: subsequentPageEdges)
        let expectedPages = [
            subsequentPage,
            initialPage,
        ]

        // Create connection controller:
        let controller = ConnectionController(
            fetcher: fetcher,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )

        // Load initial page:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [initialPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testCompleteSubsequentPageTail() throws {
        // Create test data:
        let initialPageSize = 5
        let paginationPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        let initialPageStartIndex = defaultIndex
        let initialPageEndIndex = min(defaultIndex + initialPageSize, allEdges.count)
        let subsequentPageStartIndex = initialPageEndIndex
        let subsequentPageEndIndex = min(initialPageEndIndex + paginationPageSize, allEdges.count)

        let initialPageEdges = Array(allEdges[initialPageStartIndex..<initialPageEndIndex])
        let initialPage = Page<TestFetcher>(index: 0, edges: initialPageEdges)
        let subsequentPageEdges = Array(allEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
        let subsequentPage = Page<TestFetcher>(index: 1, edges: subsequentPageEdges)
        let expectedPages = [
            initialPage,
            subsequentPage,
        ]

        // Create connection controller:
        let controller = ConnectionController(
            fetcher: fetcher,
            initialPageSize: initialPageSize,
            paginationPageSize: paginationPageSize
        )

        // Load initial page:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [initialPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)

        // Run test:
        try self.runSubsequentPageTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
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


