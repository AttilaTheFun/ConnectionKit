@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class ConnectionControllerInitialLoadTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testInitialLoadEmptyConnectionHead() throws {
        // Create test data:
        let defaultIndex = 0
        let allEdges: [TestEdge] = .create(count: 0)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages: [Page<TestFetcher>] = []

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: 2)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .end)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadEmptyConnectionTail() throws {
        // Create test data:
        let defaultIndex = 0
        let allEdges: [TestEdge] = .create(count: 0)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages: [Page<TestFetcher>] = []

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: 2)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .end)
    }

    func testInitialLoadIncompletePageHead() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 3
        let allEdges: [TestEdge] = .create(count: 7)
        let endIndex = max(defaultIndex - initialPageSize, 0)

        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[endIndex..<defaultIndex]))]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .end)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadIncompletePageTail() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 3
        let allEdges: [TestEdge] = .create(count: 7)
        let endIndex = min(defaultIndex + initialPageSize, allEdges.count)

        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[defaultIndex..<endIndex]))]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .end)
    }

    func testInitialLoadCompletePageHead() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let endIndex = defaultIndex - initialPageSize

        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[endIndex..<defaultIndex]))]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadCompletePageTail() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let endIndex = defaultIndex + initialPageSize
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[defaultIndex..<endIndex]))]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadResetHead() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let endIndex = defaultIndex - initialPageSize

        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)
        let expectedPages = [Page<TestFetcher>(index: 0, edges: Array(allEdges[endIndex..<defaultIndex]))]

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)

        // Run test again, resetting connection:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: expectedPages,
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }
}
