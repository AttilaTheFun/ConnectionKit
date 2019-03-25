import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class TestFetcherTests: XCTestCase {
    func testEmptyConnection() throws {
        // Create test data:
        let startIndex = 0
        let edges: [TestEdge] = .create(count: 0)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(startIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges = edges

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testIncompletePageForward() throws {
        // Create test data:
        let startIndex = 2
        let edges: [TestEdge] = .create(count: 5)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(startIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(edges[2...])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testIncompletePageBackward() throws {
        // Create test data:
        let startIndex = 2
        let edges: [TestEdge] = .create(count: 5)
        let config = FetchConfig(last: 10)
        let fetcher = TestFetcher(startIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(edges[0..<2])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testCompletePageForward() throws {
        // Create test data:
        let startIndex = 50
        let edges: [TestEdge] = .create(count: 100)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(startIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let expectedEdges = Array(edges[50..<60])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testCompletePageBackward() throws {
        // Create test data:
        let startIndex = 50
        let edges: [TestEdge] = .create(count: 100)
        let config = FetchConfig(last: 10)
        let fetcher = TestFetcher(startIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let expectedEdges = Array(edges[40..<50])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }
}

// MARK: Utils

extension TestFetcherTests {
    private func runTest(fetcher: TestFetcher,
                         config: FetchConfig,
                         expectedPageInfo: TestPageInfo,
                         expectedEdges: [TestEdge]) throws
    {
        let connection = try fetcher.fetch(config: config)
            .toBlocking()
            .single()

        // Assert expectations:
        XCTAssertEqual(connection.pageInfo, expectedPageInfo)
        XCTAssertEqual(connection.edges, expectedEdges)
    }
}

extension TestFetcher {
    func fetch(config: FetchConfig) -> Maybe<TestConnection> {
        return self.fetch(
            first: config.first,
            after: config.after,
            last: config.last,
            before: config.before
        )
    }
}
