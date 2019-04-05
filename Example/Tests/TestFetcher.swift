import ConnectionKit
import RxSwift

/**
 A test fetcher which vends a set of test data starting from the given index.
 */
struct TestFetcher {
    // The edges backing the connection, assumed to be in chronologically ascending order.
    let allEdges: [TestEdge]
}

extension TestFetcher: ConnectionFetcher {
    private enum TestFetcherError: Error {
        case forwardAndBackwardParameters
        case neitherParameter
        case invalidCursor

        case unimplemented
    }

    func fetch(first: Int?, after: String?, last: Int?, before: String?) -> Maybe<TestConnection> {

        // Parse the indices:
        let afterIndex: Int?
        let beforeIndex: Int?
        switch self.parseIndices(after: after, before: before) {
        case .failure(let error):
            return .error(error)
        case .success(let after, let before):
            afterIndex = after
            beforeIndex = before
        }

        // Validate the indices:
        if let error = self.validateIndices(afterIndex: afterIndex, beforeIndex: beforeIndex) {
            return .error(error)
        }

        // Slice the edges:
        let slicedEdges = self.applyCursorsToEdges(afterIndex: afterIndex, beforeIndex: beforeIndex)

        // Call the appropriate fetcher:
        guard let first = first else {
            if let last = last {
                return self.fetch(last: last, beforeIndex: beforeIndex, slicedEdges: slicedEdges)
            }

            return .error(TestFetcherError.neitherParameter)
        }

        if last != nil {
            return .error(TestFetcherError.forwardAndBackwardParameters)
        }

        return self.fetch(first: first, afterIndex: afterIndex, slicedEdges: slicedEdges)
    }

    private func parseIndices(after: String?, before: String?) -> Result<(Int?, Int?), TestFetcherError> {
        var afterIndex: Int?
        var beforeIndex: Int?

        if let after = after {
            if let index = Int(after) {
                afterIndex = index
            } else {
                return .failure(TestFetcherError.invalidCursor)
            }
        }

        if let before = before {
            if let index = Int(before) {
                beforeIndex = index
            } else {
                return .failure(TestFetcherError.invalidCursor)
            }
        }

        return .success((afterIndex, beforeIndex))
    }

    private func validateIndices(afterIndex: Int?, beforeIndex: Int?) -> TestFetcherError? {

        if afterIndex != nil && beforeIndex != nil {
            return TestFetcherError.forwardAndBackwardParameters
        }

        if let afterIndex = afterIndex {
            if afterIndex >= self.allEdges.count || afterIndex < 0 {
                return TestFetcherError.invalidCursor
            }
        }

        if let beforeIndex = beforeIndex {
            if beforeIndex >= self.allEdges.count || beforeIndex < 0 {
                return TestFetcherError.invalidCursor
            }
        }

        return nil
    }

    private func applyCursorsToEdges(afterIndex: Int?, beforeIndex: Int?) -> [TestEdge] {
        if let afterIndex = afterIndex {
            return Array(self.allEdges[(afterIndex + 1)...])
        }

        if let beforeIndex = beforeIndex {
            return Array(self.allEdges[..<beforeIndex])
        }

        return self.allEdges
    }

    /**
     Head (forwards) pagination with first / after.
     */
    private func fetch(first: Int, afterIndex: Int?, slicedEdges: [TestEdge]) -> Maybe<TestConnection> {
        let firstEdges = slicedEdges.count > first ? Array(slicedEdges[..<first]) : slicedEdges
        let pageInfo = TestPageInfo(
            hasNextPage: firstEdges.count < slicedEdges.count,
            hasPreviousPage: afterIndex ?? 0 > 0
        )

        let connection = TestConnection(pageInfo: pageInfo, edges: firstEdges)
        return .just(connection)
    }

    /**
     Tail (backwards) pagination with last / before.
     */
    private func fetch(last: Int, beforeIndex: Int?, slicedEdges: [TestEdge]) -> Maybe<TestConnection> {
        let lastEdges = slicedEdges.count > last ? Array(slicedEdges[(slicedEdges.count - last)...]) : slicedEdges
        let pageInfo = TestPageInfo(
            hasNextPage: beforeIndex ?? self.allEdges.count < self.allEdges.count - 1,
            hasPreviousPage: lastEdges.count < slicedEdges.count
        )

        let connection = TestConnection(pageInfo: pageInfo, edges: lastEdges)
        return .just(connection)
    }
}
