@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PageFetcherSubsequentPageTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testSubsequentIncompletePageHead() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 15)

        // Run test:
        let initialFetchConfig = FetchConfig(first: 10)
        let initialPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: false)
        let initialEdges = Array(config.connectionEdges[0..<10])
        try self.runTest(
            config: config,
            fetchConfig: initialFetchConfig,
            expectedPageInfo: initialPageInfo,
            expectedEdges: initialEdges,
            disposedBy: self.disposeBag
        )

        // Run test:
        let subsequentFetchConfig = FetchConfig(first: 10, after: initialEdges.last!.cursor)
        let subsequentPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let subsequentEdges = Array(config.connectionEdges[10...])
        try self.runTest(
            config: config,
            fetchConfig: subsequentFetchConfig,
            expectedPageInfo: subsequentPageInfo,
            expectedEdges: subsequentEdges,
            disposedBy: self.disposeBag
        )
    }

    func testSubsequentIncompletePageTail() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 15)

        // Run test:
        let initialFetchConfig = FetchConfig(last: 10)
        let initialPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let initialEdges = Array(config.connectionEdges[5...])
        try self.runTest(
            config: config,
            fetchConfig: initialFetchConfig,
            expectedPageInfo: initialPageInfo,
            expectedEdges: initialEdges,
            disposedBy: self.disposeBag
        )

        // Run test:
        let subsequentFetchConfig = FetchConfig(last: 10, before: initialEdges.first!.cursor)
        let subsequentPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: false)
        let subsequentEdges = Array(config.connectionEdges[..<5])
        try self.runTest(
            config: config,
            fetchConfig: subsequentFetchConfig,
            expectedPageInfo: subsequentPageInfo,
            expectedEdges: subsequentEdges,
            disposedBy: self.disposeBag
        )
    }

    func testSubsequentCompletePageHead() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 30)

        // Run test:
        let initialFetchConfig = FetchConfig(first: 10)
        let initialPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: false)
        let initialEdges = Array(config.connectionEdges[0..<10])
        try self.runTest(
            config: config,
            fetchConfig: initialFetchConfig,
            expectedPageInfo: initialPageInfo,
            expectedEdges: initialEdges,
            disposedBy: self.disposeBag
        )

        // Run test:
        let subsequentFetchConfig = FetchConfig(first: 10, after: initialEdges.last!.cursor)
        let subsequentPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        let subsequentEdges = Array(config.connectionEdges[10..<20])
        try self.runTest(
            config: config,
            fetchConfig: subsequentFetchConfig,
            expectedPageInfo: subsequentPageInfo,
            expectedEdges: subsequentEdges,
            disposedBy: self.disposeBag
        )
    }

    func testSubsequentCompletePageTail() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 30)

        // Run test:
        let initialFetchConfig = FetchConfig(last: 10)
        let initialPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let initialEdges = Array(config.connectionEdges[20...])
        try self.runTest(
            config: config,
            fetchConfig: initialFetchConfig,
            expectedPageInfo: initialPageInfo,
            expectedEdges: initialEdges,
            disposedBy: self.disposeBag
        )

        // Run test:
        let subsequentFetchConfig = FetchConfig(last: 10, before: initialEdges.first!.cursor)
        let subsequentPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        let subsequentEdges = Array(config.connectionEdges[10..<20])
        try self.runTest(
            config: config,
            fetchConfig: subsequentFetchConfig,
            expectedPageInfo: subsequentPageInfo,
            expectedEdges: subsequentEdges,
            disposedBy: self.disposeBag
        )
    }
}
