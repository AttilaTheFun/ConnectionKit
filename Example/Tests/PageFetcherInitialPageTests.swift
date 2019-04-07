@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PageFetcherInitialPageTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testInitialEmptyConnectionHead() throws {
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

    func testInitialEmptyConnectionTail() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 0)
        let fetchConfig = FetchConfig(last: 10)
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

    func testInitialIncompletePageHead() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 5)
        let fetchConfig = FetchConfig(first: 10)
        let expectedPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges = Array(config.connectionEdges)

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }

    func testInitialIncompletePageTail() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 5)
        let fetchConfig = FetchConfig(last: 10)
        let expectedPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges = Array(config.connectionEdges)

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }

    func testInitialCompletePageHead() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 20)
        let fetchConfig = FetchConfig(first: 10)
        let expectedPageInfo = PageInfo(hasNextPage: true, hasPreviousPage: false)
        let expectedEdges = Array(config.connectionEdges[0..<10])

        // Run test:
        try self.runTest(
            config: config,
            fetchConfig: fetchConfig,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges,
            disposedBy: self.disposeBag
        )
    }

    func testInitialCompletePageTail() throws {
        // Create test data:
        let config = FetcherTestConfig(edgeCount: 20)
        let fetchConfig = FetchConfig(last: 10)
        let expectedPageInfo = PageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(config.connectionEdges[10..<20])

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
