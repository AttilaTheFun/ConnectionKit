import ConnectionKit
import RxSwift

/**
 A test fetcher which vends a set of test data starting from the given index.
 */
struct TestFetcher {
    /// The default start index to use when after or before is nil.
    let defaultIndex: Int
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
                return self.fetch(last: last, before: before)
            }

            return .error(TestFetcherError.neitherParameter)
        }

        if last != nil {
            return .error(TestFetcherError.forwardAndBackwardParameters)
        }

        return self.fetch(first: first, after: after)
    }

    private func fetch(first: Int, after: String?) -> Maybe<TestConnection> {
        let startIndex: Int
        if let after = after {
            if let index = Int(after) {
                // Because we're looking *after* this value, we need to add one.
                startIndex = index + 1
            } else {
                return .error(TestFetcherError.invalidCursor)
            }
        } else {
            startIndex = self.defaultIndex
        }

        if self.edges.count == 0 {
            let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
            let connection = TestConnection(pageInfo: pageInfo, edges: [])
            return .just(connection)
        }

        if startIndex >= self.edges.count || startIndex < 0 {
            return .error(TestFetcherError.invalidCursor)
        }

        let endIndex = startIndex + first
        let pageInfo = TestPageInfo(
            hasNextPage: endIndex < self.edges.count - 1,
            hasPreviousPage: startIndex > 0
        )

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

    private func fetch(last: Int, before: String?) -> Maybe<TestConnection> {
        let endIndex: Int
        if let before = before {
            if let index = Int(before) {
                endIndex = index
            } else {
                return .error(TestFetcherError.invalidCursor)
            }
        } else {
            endIndex = self.defaultIndex
        }

        if self.edges.count == 0 {
            let pageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
            let connection = TestConnection(pageInfo: pageInfo, edges: [])
            return .just(connection)
        }

        if endIndex >= self.edges.count || endIndex < 0 {
            return .error(TestFetcherError.invalidCursor)
        }

        let startIndex = endIndex - last
        let pageInfo = TestPageInfo(
            hasNextPage: startIndex > 0,
            hasPreviousPage: endIndex < self.edges.count - 1
        )

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
