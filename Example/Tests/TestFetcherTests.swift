import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class TestFetcherTests: XCTestCase {
    func testEmptyConnection() throws {
        let testFetcher = TestFetcher(startIndex: 0, testData: TestData(nodes: []))
        let connection = try testFetcher.fetch(first: 10, after: nil, last: nil, before: nil)
            .toBlocking()
            .single()

        XCTAssertFalse(connection.pageInfo.hasNextPage)
        XCTAssertFalse(connection.pageInfo.hasPreviousPage)
        XCTAssertEqual(connection.edges, [])
    }

    func testIncompletePageForward() throws {
        let nodes: [TestNode] = .createNodes(count: 5)
        let testFetcher = TestFetcher(startIndex: 2, testData: TestData(nodes: nodes))
        let connection = try testFetcher.fetch(first: 10, after: nil, last: nil, before: nil)
            .toBlocking()
            .single()

        XCTAssertFalse(connection.pageInfo.hasNextPage)
        XCTAssertTrue(connection.pageInfo.hasPreviousPage)
        XCTAssertEqual(connection.edges, nodes[2...].map(TestEdge.init))
    }

    func testIncompletePageBackward() throws {
        let nodes: [TestNode] = .createNodes(count: 5)
        let testFetcher = TestFetcher(startIndex: 2, testData: TestData(nodes: nodes))
        let connection = try testFetcher.fetch(first: nil, after: nil, last: 10, before: nil)
            .toBlocking()
            .single()

        XCTAssertFalse(connection.pageInfo.hasNextPage)
        XCTAssertTrue(connection.pageInfo.hasPreviousPage)
        XCTAssertEqual(connection.edges, nodes[0..<2].map(TestEdge.init))
    }

    func testCompletePageForward() throws {
        let nodes: [TestNode] = .createNodes(count: 100)
        let testFetcher = TestFetcher(startIndex: 50, testData: TestData(nodes: nodes))
        let connection = try testFetcher.fetch(first: 10, after: nil, last: nil, before: nil)
            .toBlocking()
            .single()

        XCTAssertTrue(connection.pageInfo.hasNextPage)
        XCTAssertTrue(connection.pageInfo.hasPreviousPage)
        XCTAssertEqual(connection.edges, nodes[50..<60].map(TestEdge.init))
    }

    func testCompletePageBackward() throws {
        let nodes: [TestNode] = .createNodes(count: 100)
        let testFetcher = TestFetcher(startIndex: 50, testData: TestData(nodes: nodes))
        let connection = try testFetcher.fetch(first: 10, after: nil, last: nil, before: nil)
            .toBlocking()
            .single()

        XCTAssertTrue(connection.pageInfo.hasNextPage)
        XCTAssertTrue(connection.pageInfo.hasPreviousPage)
        XCTAssertEqual(connection.edges, nodes[40..<50].map(TestEdge.init))
    }
}
