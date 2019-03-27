@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PaginationStateTrackerTests: XCTestCase {

    func testInitialState() throws {

        // Create test data:
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }

    func testHeadCanFetchSecondPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }

    func testHeadIgnoresPreviousPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: false)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }

    func testHeadReachesEnd() throws {

        // Create test data:
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        let first = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.ingest(pageInfo: first, from: .head)
        let second = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        tracker.ingest(pageInfo: second, from: .head)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, false)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }

    func testTailCanFetchSecondPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }

    func testTailIgnoresPreviousPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: false)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }

    func testTailReachesEnd() throws {

        // Create test data:
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        let first = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        tracker.ingest(pageInfo: first, from: .tail)
        let second = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        tracker.ingest(pageInfo: second, from: .tail)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, false)
    }

    func testBothCanFetchNextPage() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }

    func testBothReachEnd() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        XCTAssertEqual(tracker.canFetchNextPageFromHead, false)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, false)
    }

    func testBothCanFetchNextPageAfterReset() throws {

        // Create test data:
        let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let tracker = PaginationStateTracker<TestFetcher>()

        // Run test:
        tracker.ingest(pageInfo: pageInfo, from: .head)
        tracker.ingest(pageInfo: pageInfo, from: .tail)
        tracker.reset()
        XCTAssertEqual(tracker.canFetchNextPageFromHead, true)
        XCTAssertEqual(tracker.canFetchNextPageFromTail, true)
    }
}
