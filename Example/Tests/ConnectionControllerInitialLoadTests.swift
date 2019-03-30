//@testable import ConnectionKit
//import RxBlocking
//import RxSwift
//import XCTest
//
//// TODO: Additional tests to write:
//// - connection controller second initial load resets
//// - connection controller initial page tests
//// - connection controller multiple pages, both directions
//// - page fetcher invalid cursor tests
//
//class ConnectionControllerInitialLoadTests: XCTestCase {
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
//    func testInitialLoadEmptyConnectionHead() throws {
//        // Create test data:
//        let defaultIndex = 0
//        let allEdges: [TestEdge] = .create(count: 0)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedPages: [Page<TestFetcher>] = []
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: 2, paginationPageSize: 5)
//
//        // Run test:
//        try self.runInitialLoadTest(
//            controller: controller,
//            fetchFrom: .head,
//            expectedEndState: .hasFetchedInitialPage,
//            expectedPages: expectedPages,
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(controller.headState, .hasFetchedLastPage)
//    }
//
//    func testInitialLoadEmptyConnectionTail() throws {
//        // Create test data:
//        let defaultIndex = 0
//        let allEdges: [TestEdge] = .create(count: 0)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedPages: [Page<TestFetcher>] = []
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: 2, paginationPageSize: 5)
//
//        // Run test:
//        try self.runInitialLoadTest(
//            controller: controller,
//            fetchFrom: .tail,
//            expectedEndState: .hasFetchedInitialPage,
//            expectedPages: expectedPages,
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(controller.tailState, .hasFetchedLastPage)
//    }
//
//    func testInitialLoadIncompletePageHead() throws {
//        // Create test data:
//        let initialPageSize = 2
//        let defaultIndex = 5
//        let endIndex = defaultIndex - initialPageSize
//
//        let allEdges: [TestEdge] = .create(count: 10)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[endIndex..<defaultIndex]))]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runInitialLoadTest(
//            controller: controller,
//            fetchFrom: .head,
//            expectedEndState: .hasFetchedInitialPage,
//            expectedPages: expectedPages,
//            disposedBy: self.disposeBag
//        )
//    }
//
//    func testInitialLoadIncompletePageTail() throws {
//        // Create test data:
//        let initialPageSize = 2
//        let defaultIndex = 5
//        let endIndex = defaultIndex + initialPageSize
//
//        let allEdges: [TestEdge] = .create(count: 10)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[defaultIndex..<endIndex]))]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runInitialLoadTest(
//            controller: controller,
//            fetchFrom: .tail,
//            expectedEndState: .hasFetchedInitialPage,
//            expectedPages: expectedPages,
//            disposedBy: self.disposeBag
//        )
//    }
//
//    func testInitialLoadCompletePageHead() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 50
//        let endIndex = defaultIndex - initialPageSize
//
//        let allEdges: [TestEdge] = .create(count: 100)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[endIndex..<defaultIndex]))]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runInitialLoadTest(
//            controller: controller,
//            fetchFrom: .head,
//            expectedEndState: .hasFetchedInitialPage,
//            expectedPages: expectedPages,
//            disposedBy: self.disposeBag
//        )
//    }
//
//    func testInitialLoadCompletePageTail() throws {
//        // Create test data:
//        let initialPageSize = 10
//        let defaultIndex = 50
//        let endIndex = defaultIndex + initialPageSize
//        let allEdges: [TestEdge] = .create(count: 100)
//        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
//        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[defaultIndex..<endIndex]))]
//
//        // Create connection controller:
//        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)
//
//        // Run test:
//        try self.runInitialLoadTest(
//            controller: controller,
//            fetchFrom: .tail,
//            expectedEndState: .hasFetchedInitialPage,
//            expectedPages: expectedPages,
//            disposedBy: self.disposeBag
//        )
//    }
//}
