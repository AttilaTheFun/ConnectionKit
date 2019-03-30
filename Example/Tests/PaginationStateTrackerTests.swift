@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PaginationStateTrackerTests: XCTestCase {

    func testInitialState() throws {

        // Create test data:
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }

    func testHeadCanFetchSecondPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }

    func testHeadIgnoresPreviousPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: false)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }

    func testHeadReachesEnd() throws {

        // Create test data:
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        let first = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.ingest(pageInfo: first, from: .head)
        let second = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        tracker.ingest(pageInfo: second, from: .head)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), true)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }

    func testTailCanFetchSecondPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }

    func testTailIgnoresPreviousPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: false)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }

    func testTailReachesEnd() throws {

        // Create test data:
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        let first = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.ingest(pageInfo: first, from: .tail)
        let second = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        tracker.ingest(pageInfo: second, from: .tail)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), true)
    }

    func testBothCanFetchNextPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }

    func testBothReachEnd() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), true)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), true)
    }

    func testBothCanFetchNextPageAfterReset() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        let initialPageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.reset(to: initialPageInfo, from: .tail)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .head), false)
        XCTAssertEqual(tracker.hasFetchedLastPage(from: .tail), false)
    }
}
