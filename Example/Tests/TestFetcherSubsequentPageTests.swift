import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class TestFetcherSubsequentPageTests: XCTestCase {
    func testSubsequentIncompletePageHead() throws {
        // Create test data:
        let allEdges: [TestEdge] = .create(count: 15)
        let fetcher = TestFetcher(allEdges: allEdges)

        // Run test:
        let firstPage = Array(allEdges[0..<10])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(first: 10),
            expectedPageInfo: TestPageInfo(hasNextPage: true, hasPreviousPage: false),
            expectedEdges: firstPage
        )

        // Run test:
        let secondPage = Array(allEdges[10...])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(first: 10, after: firstPage.last!.cursor),
            expectedPageInfo: TestPageInfo(hasNextPage: false, hasPreviousPage: true),
            expectedEdges: secondPage
        )
    }

    func testSubsequentIncompletePageTail() throws {
        // Create test data:
        let allEdges: [TestEdge] = .create(count: 15)
        let fetcher = TestFetcher(allEdges: allEdges)

        // Run test:
        let firstPage = Array(allEdges[5...])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(last: 10),
            expectedPageInfo: TestPageInfo(hasNextPage: false, hasPreviousPage: true),
            expectedEdges: firstPage
        )

        // Run test:
        let secondPage = Array(allEdges[..<5])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(last: 10, before: firstPage.first!.cursor),
            expectedPageInfo: TestPageInfo(hasNextPage: true, hasPreviousPage: false),
            expectedEdges: secondPage
        )
    }

    func testSubsequentCompletePageHead() throws {
        // Create test data:
        let allEdges: [TestEdge] = .create(count: 30)
        let fetcher = TestFetcher(allEdges: allEdges)

        // Run test:
        let firstPage = Array(allEdges[0..<10])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(first: 10),
            expectedPageInfo: TestPageInfo(hasNextPage: true, hasPreviousPage: false),
            expectedEdges: firstPage
        )

        // Run test:
        let secondPage = Array(allEdges[10..<20])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(first: 10, after: firstPage.last!.cursor),
            expectedPageInfo: TestPageInfo(hasNextPage: true, hasPreviousPage: true),
            expectedEdges: secondPage
        )
    }

    func testSubsequentCompletePageTail() throws {
        // Create test data:
        let allEdges: [TestEdge] = .create(count: 30)
        let fetcher = TestFetcher(allEdges: allEdges)

        // Run test:
        let firstPage = Array(allEdges[20...])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(last: 10),
            expectedPageInfo: TestPageInfo(hasNextPage: false, hasPreviousPage: true),
            expectedEdges: firstPage
        )

        // Run test:
        let secondPage = Array(allEdges[10..<20])
        try self.runTest(
            fetcher: fetcher,
            config: FetchConfig(last: 10, before: firstPage.first!.cursor),
            expectedPageInfo: TestPageInfo(hasNextPage: true, hasPreviousPage: true),
            expectedEdges: secondPage
        )
    }
}
