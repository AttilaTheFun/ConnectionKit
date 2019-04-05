import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

// MARK: Utils

extension XCTestCase {
    func runTest(
        fetcher: TestFetcher,
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
