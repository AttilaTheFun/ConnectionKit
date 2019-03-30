//@testable import ConnectionKit
//import RxBlocking
//import RxSwift
//import XCTest
//
//// TODO: Additional tests to write:
//// - connection controller reset
//// - connection controller initial page tests
//// - connection controller multiple pages, both directions
//// - page fetcher invalid cursor tests
//
//class ConnectionControllerTests: XCTestCase {
//
//    private var disposeBag = DisposeBag()
//
//    override func tearDown() {
//        super.tearDown()
//
//        // Wipe out all disposables:
//        self.disposeBag = DisposeBag()
//    }
//
//    func testForwardIncompletePage() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 5
//        let endIndex = defaultIndex + 5
//        let allEdges: [TestEdge] = .create(count: 10)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedEdges = Array(allEdges[defaultIndex..<endIndex])
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runTailTest(controller: controller, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
//    }
//
//    func testBackwardIncompletePage() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 5
//        let endIndex = 0
//        let allEdges: [TestEdge] = .create(count: 10)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedEdges = Array(allEdges[endIndex..<defaultIndex])
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runHeadTest(controller: controller, expectedEndState: .hasFetchedLastPage, expectedPages: expectedPages)
//    }
//
//    func testForwardCompletePage() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 50
//        let endIndex = defaultIndex + initialPageSize
//        let allEdges: [TestEdge] = .create(count: 100)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//
//        let expectedEdges = Array(allEdges[defaultIndex..<endIndex])
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runTailTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedPages)
//    }
//
//    func testBackwardCompletePage() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 50
//        let endIndex = defaultIndex - initialPageSize
//        let allEdges: [TestEdge] = .create(count: 100)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//
//        let expectedEdges = Array(allEdges[endIndex..<defaultIndex])
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: expectedEdges)]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runHeadTest(controller: controller, expectedEndState: .hasNextPage, expectedPages: expectedPages)
//    }
//
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
//}
//
//
