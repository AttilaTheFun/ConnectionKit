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
        let initialPageSize = 2
        let defaultIndex = 0
        let allEdges: [TestEdge] = .create(count: 0)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .end)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadEmptyConnectionTail() throws {
        // Create test data:
        let initialPageSize = 2
        let defaultIndex = 0
        let allEdges: [TestEdge] = .create(count: 0)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [],
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
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Calculate pages:
        let initialHeadPage = self.initialPage(defaultIndex: defaultIndex, initialPageSize: initialPageSize, edges: allEdges, for: .head)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [initialHeadPage],
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
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Calculate pages:
        let initialTailPage = self.initialPage(defaultIndex: defaultIndex, initialPageSize: initialPageSize, edges: allEdges, for: .tail)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .end)
    }

    func testInitialLoadCompletePageHead() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Calculate pages:
        let initialHeadPage = self.initialPage(defaultIndex: defaultIndex, initialPageSize: initialPageSize, edges: allEdges, for: .head)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadCompletePageTail() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Calculate pages:
        let initialTailPage = self.initialPage(defaultIndex: defaultIndex, initialPageSize: initialPageSize, edges: allEdges, for: .tail)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadResetHead() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Calculate pages:
        let initialHeadPage = self.initialPage(defaultIndex: defaultIndex, initialPageSize: initialPageSize, edges: allEdges, for: .head)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)

        // Run test again, resetting connection:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .head,
            expectedEndState: .idle,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }

    func testInitialLoadResetTail() throws {
        // Create test data:
        let initialPageSize = 10
        let defaultIndex = 50
        let allEdges: [TestEdge] = .create(count: 100)
        let fetcher = TestFetcher(defaultIndex: defaultIndex, edges: allEdges)

        // Calculate pages:
        let initialTailPage = self.initialPage(defaultIndex: defaultIndex, initialPageSize: initialPageSize, edges: allEdges, for: .tail)

        // Create connection controller:
        let controller = ConnectionController(fetcher: fetcher, initialPageSize: initialPageSize)

        // Run test:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)

        // Run test again, resetting connection:
        try self.runInitialLoadTest(
            controller: controller,
            fetchFrom: .tail,
            expectedEndState: .idle,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(controller.state(for: .head), .idle)
        XCTAssertEqual(controller.state(for: .tail), .idle)
    }
}
