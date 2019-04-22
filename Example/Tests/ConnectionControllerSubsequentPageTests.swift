//@testable import ConnectionKit
//import RxBlocking
//import RxSwift
//import XCTest
//
//class ConnectionControllerSubsequentPageTests: XCTestCase {
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
//    func testSubsequentIncompletePageHead() throws {
//        // Create test config:
//        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 10)
//
//        // Load initial page:
//        let initialHeadPage = config.initialPage(for: .head)
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .complete,
//            expectedPages: [initialHeadPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        let subsequentHeadPage = config.subsequentPage(relativeTo: [initialHeadPage], for: .head)
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .end,
//            expectedPages: [
//                initialHeadPage,
//                subsequentHeadPage,
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .end)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//    }
//
//    func testSubsequentIncompletePageTail() throws {
//        // Create test config:
//        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 10)
//
//        // Calculate pages:
//        let initialTailPage = config.initialPage(for: .tail)
//        let subsequentTailPage = config.subsequentPage(relativeTo: [initialTailPage], for: .tail)
//
//        // Load initial page:
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .complete,
//            expectedPages: [initialTailPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .end,
//            expectedPages: [
//                subsequentTailPage,
//                initialTailPage,
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .end)
//    }
//
//    func testSubsequentCompletePageHead() throws {
//        // Create test config:
//        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100)
//
//        // Calculate pages:
//        let initialHeadPage = config.initialPage(for: .head)
//        let subsequentHeadPage = config.subsequentPage(relativeTo: [initialHeadPage], for: .head)
//
//        // Load initial page:
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .complete,
//            expectedPages: [initialHeadPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .idle,
//            expectedPages: [
//                initialHeadPage,
//                subsequentHeadPage
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//    }
//
//    func testSubsequentCompletePageTail() throws {
//        // Create test config:
//        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100)
//
//        // Calculate pages:
//        let initialTailPage = config.initialPage(for: .tail)
//        let subsequentTailPage = config.subsequentPage(relativeTo: [initialTailPage], for: .tail)
//
//        // Load initial page:
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .complete,
//            expectedPages: [initialTailPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .idle,
//            expectedPages: [
//                subsequentTailPage,
//                initialTailPage,
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//    }
//
//    func testSubsequentResetHead() throws {
//        // Create test config:
//        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100)
//
//        // Calculate pages:
//        let initialHeadPage = config.initialPage(for: .head)
//        let subsequentHeadPage = config.subsequentPage(relativeTo: [initialHeadPage], for: .head)
//
//        // Load initial page:
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .complete,
//            expectedPages: [initialHeadPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .idle,
//            expectedPages: [
//                initialHeadPage,
//                subsequentHeadPage,
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Load initial page:
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .complete,
//            expectedPages: [initialHeadPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .head,
//            expectedEndState: .idle,
//            expectedPages: [
//                initialHeadPage,
//                subsequentHeadPage,
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//    }
//
//    func testSubsequentResetTail() throws {
//        // Create test config:
//        let config = ConnectionTestConfig(initialPageSize: 5, paginationPageSize: 10, edgeCount: 100)
//
//        // Calculate pages:
//        let initialTailPage = config.initialPage(for: .tail)
//        let subsequentTailPage = config.subsequentPage(relativeTo: [initialTailPage], for: .tail)
//
//        // Load initial page:
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .complete,
//            expectedPages: [initialTailPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .idle,
//            expectedPages: [
//                subsequentTailPage,
//                initialTailPage,
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Load initial page:
//        try self.runInitialLoadTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .complete,
//            expectedPages: [initialTailPage],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//
//        // Run test:
//        try self.runSubsequentPageTest(
//            controller: config.controller,
//            fetchFrom: .tail,
//            expectedEndState: .idle,
//            expectedPages: [
//                subsequentTailPage,
//                initialTailPage,
//            ],
//            disposedBy: self.disposeBag
//        )
//
//        XCTAssertEqual(config.controller.state(for: .head), .idle)
//        XCTAssertEqual(config.controller.state(for: .tail), .idle)
//    }
//}
//
//
