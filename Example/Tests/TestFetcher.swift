import ConnectionKit
import RxSwift

/**
 A test fetcher which vends a set of test data starting from the given index.
 */
struct TestFetcher {
    let startIndex: Int
    let edges: [TestEdge]
}

extension TestFetcher: ConnectionFetcher {
    private enum TestFetcherError: Error {
        case forwardAndBackwardParameters
        case neitherParameter
        case invalidCursor

        case unimplemented
    }

    func fetch(first: Int?, after: String?, last: Int?, before: String?)
        -> Maybe<TestConnection>
    {
        guard let first = first else {
            if let last = last {
                return self.fetch(last: last, before: before ?? String(self.startIndex))
            }

            return .error(TestFetcherError.neitherParameter)
        }

        if last != nil {
            return .error(TestFetcherError.forwardAndBackwardParameters)
        }

        return self.fetch(first: first, after: after ?? String(self.startIndex))
    }

    private func fetch(first: Int, after: String) -> Maybe<TestConnection> {
        guard let startIndex = Int(after) else {
            return .error(TestFetcherError.invalidCursor)
        }

        if startIndex < 0 {
            return .error(TestFetcherError.invalidCursor)
        }

        if self.edges.count == 0 {
            let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
            let connection = TestConnection(pageInfo: pageInfo, edges: [])
            return .just(connection)
        }

        let endIndex = startIndex + first
        let pageInfo = TestPageInfo(
            hasNextPage: endIndex < self.edges.count - 1,
            hasPreviousPage: startIndex > 0)

        let range = Range.bounded(
            low: startIndex,
            high: endIndex,
            lowest: 0,
            highest: self.edges.count
        )
        let edges = Array(self.edges[range])
        let connection = TestConnection(pageInfo: pageInfo, edges: edges)

        return .just(connection)
    }

    private func fetch(last: Int, before: String) -> Maybe<TestConnection> {
        guard let endIndex = Int(before) else {
            return .error(TestFetcherError.invalidCursor)
        }

        if endIndex >= self.edges.count {
            return .error(TestFetcherError.invalidCursor)
        }

        if self.edges.count == 0 {
            let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
            let connection = TestConnection(pageInfo: pageInfo, edges: [])
            return .just(connection)
        }

        let startIndex = endIndex - last
        let pageInfo = TestPageInfo(
            hasNextPage: startIndex > 0,
            hasPreviousPage: endIndex < self.edges.count - 1)

        let range = Range.bounded(
            low: startIndex,
            high: endIndex,
            lowest: 0,
            highest: self.edges.count
        )
        let edges = Array(self.edges[range])
        let connection = TestConnection(pageInfo: pageInfo, edges: edges)

        return .just(connection)
    }
}
