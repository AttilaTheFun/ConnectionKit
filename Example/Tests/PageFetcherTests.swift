@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

// TODO: Write more page fetcher tests.

class PageFetcherTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testEmptyConnection() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 0)
        let fetchConfig = FetchConfig(first: 10)
        let expectedPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges: [Edge<TestModel>] = []

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }

    func testIncompletePageForward() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 5)
        let fetchConfig = FetchConfig(first: 10)
        let expectedPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(config.connectionEdges[2...])

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }

    func testIncompletePageBackward() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 5)
        let fetchConfig = FetchConfig(last: 10)
        let expectedPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(config.connectionEdges[0..<2])

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }

    func testCompletePageForward() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 100)
        let fetchConfig = FetchConfig(first: 10)
        let expectedPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        let expectedEdges = Array(config.connectionEdges[50..<60])

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }

    func testCompletePageBackward() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 100)
        let fetchConfig = FetchConfig(last: 10)
        let expectedPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: true)
        let expectedEdges = Array(config.connectionEdges[40..<50])

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }
}
