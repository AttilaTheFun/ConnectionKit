import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class TestFetcherInitialPageTests: XCTestCase {
    func testInitialEmptyConnection() throws {
        // Create test data:
        let edges: [TestEdge] = .create(count: 0)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(allEdges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges = edges

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testInitialIncompletePageHead() throws {
        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(allEdges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges = edges

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testInitialIncompletePageTail() throws {
        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let config = FetchConfig(last: 10)
        let fetcher = TestFetcher(allEdges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges = edges

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testInitialCompletePageHead() throws {
        // Create test data:
        let edges: [TestEdge] = .create(count: 20)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(allEdges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: false)
        let expectedEdges = Array(edges[0..<10])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testInitialCompletePageTail() throws {
        // Create test data:
        let edges: [TestEdge] = .create(count: 20)
        let config = FetchConfig(last: 10)
        let fetcher = TestFetcher(allEdges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(edges[10..<20])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }
}
