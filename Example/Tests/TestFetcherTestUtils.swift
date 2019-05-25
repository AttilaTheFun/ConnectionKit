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
        switch config.end {
        case .head:
            return self.fetch(
                first: config.limit,
                after: config.cursor,
                last: nil,
                before: nil
            )
        case .tail:
            return self.fetch(
                first: nil,
                after: nil,
                last: config.limit,
                before: config.cursor
            )
        }

    }
}
