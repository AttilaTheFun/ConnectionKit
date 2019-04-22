@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PaginationStateTrackerTests: XCTestCase {

    func testInitialState() throws {

        // Create test data:
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }

    func testHeadCanFetchSecondPage() throws {

        // Create test data:
        let pageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }

    func testHeadIgnoresPreviousPage() throws {

        // Create test data:
        let pageInfo = PageInfo(hasNextPage: true, hasPreviousPage: false)
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }

    func testHeadReachesEnd() throws {

        // Create test data:
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        let first = PageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.ingest(pageInfo: first, from: .head)
        let second = PageInfo(hasNextPage: false, hasPreviousPage: true)
        tracker.ingest(pageInfo: second, from: .head)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), true)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }

    func testTailCanFetchSecondPage() throws {

        // Create test data:
        let pageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }

    func testTailIgnoresNextPage() throws {

        // Create test data:
        let pageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }

    func testTailReachesEnd() throws {

        // Create test data:
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        let first = PageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.ingest(pageInfo: first, from: .tail)
        let second = PageInfo(hasNextPage: true, hasPreviousPage: false)
        tracker.ingest(pageInfo: second, from: .tail)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), true)
    }

    func testBothCanFetchNextPage() throws {

        // Create test data:
        let pageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }

    func testBothReachEnd() throws {

        // Create test data:
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        let first = PageInfo(hasNextPage: false, hasPreviousPage: true)
        tracker.ingest(pageInfo: first, from: .head)
        let second = PageInfo(hasNextPage: true, hasPreviousPage: false)
        tracker.ingest(pageInfo: second, from: .tail)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), true)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), true)
    }

    func testBothCanFetchNextPageAfterReset() throws {

        // Create test data:
        let pageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let tracker = PaginationStateTracker(initialState: .initial)

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        let initialPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.reset(initialState: .init(initialPageInfo: initialPageInfo, from: .tail))
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.state.hasFetchedLastPage(from: .tail), false)
    }
}
