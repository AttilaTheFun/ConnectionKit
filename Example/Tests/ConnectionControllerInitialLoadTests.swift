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
        let config = ConnectionTestConfig(initialPageSize: 2, paginationPageSize: 5, edgeCount: 0)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .end)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)
    }

    func testInitialLoadEmptyConnectionTail() throws {
        // Create test data:
        let config = ConnectionTestConfig(initialPageSize: 2, paginationPageSize: 5, edgeCount: 0)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .end)
    }

    func testInitialLoadIncompletePageHead() throws {
        // Create test data:
        let config = ConnectionTestConfig(initialPageSize: 10, paginationPageSize: 10, edgeCount: 7)

        // Calculate pages:
        let initialHeadPage = config.initialPage(for: .head)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .end)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)
    }

    func testInitialLoadIncompletePageTail() throws {
        // Create test data:
        let config = ConnectionTestConfig(initialPageSize: 10, paginationPageSize: 10, edgeCount: 7)

        // Calculate pages:
        let initialTailPage = config.initialPage(for: .tail)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .end)
    }

    func testInitialLoadCompletePageHead() throws {
        // Create test data:
        let config = ConnectionTestConfig(initialPageSize: 10, paginationPageSize: 10, edgeCount: 100)

        // Calculate pages:
        let initialHeadPage = config.initialPage(for: .head)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)
    }

    func testInitialLoadCompletePageTail() throws {
        // Create test data:
        let config = ConnectionTestConfig(initialPageSize: 10, paginationPageSize: 10, edgeCount: 100)

        // Calculate pages:
        let initialTailPage = config.initialPage(for: .tail)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)
    }

    func testInitialLoadResetHead() throws {
        // Create test data:
        let config = ConnectionTestConfig(initialPageSize: 10, paginationPageSize: 10, edgeCount: 100)

        // Calculate pages:
        let initialHeadPage = config.initialPage(for: .head)

        XCTAssertEqual(config.controller.state.initialLoadState.hasCompletedInitialLoad, false)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.initialLoadState.hasCompletedInitialLoad, true)
        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)

        // Run test again, resetting connection:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .head,
            expectedEndState: .complete,
            expectedPages: [initialHeadPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.initialLoadState.hasCompletedInitialLoad, true)
        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)
    }

    func testInitialLoadResetTail() throws {
        // Create test data:
        let config = ConnectionTestConfig(initialPageSize: 10, paginationPageSize: 10, edgeCount: 100)

        // Calculate pages:
        let initialTailPage = config.initialPage(for: .tail)

        // Run test:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)

        // Run test again, resetting connection:
        try self.runInitialLoadTest(
            controller: config.controller,
            fetchFrom: .tail,
            expectedEndState: .complete,
            expectedPages: [initialTailPage],
            disposedBy: self.disposeBag
        )

        XCTAssertEqual(config.controller.state.endState(for: .head), .idle)
        XCTAssertEqual(config.controller.state.endState(for: .tail), .idle)
    }
}
