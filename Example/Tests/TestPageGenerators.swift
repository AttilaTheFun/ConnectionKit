@testable import ConnectionKit
import XCTest

extension ConnectionTestConfig {
    func initialEdges(for end: End) -> [Edge<TestModel>] {
        let initialPageEdges: [Edge<TestModel>]

        switch end {
        case .head:
            let initialHeadPageStartIndex = max(self.fetcherTestConfig.defaultIndex - self.initialPageSize, 0)
            let initialHeadPageEndIndex = self.fetcherTestConfig.defaultIndex
            initialPageEdges = Array(self.fetcherTestConfig.connectionEdges[initialHeadPageStartIndex..<initialHeadPageEndIndex])
        case .tail:
            let initialPageStartIndex = self.fetcherTestConfig.defaultIndex
            let initialPageEndIndex = min(self.fetcherTestConfig.defaultIndex + self.initialPageSize, self.fetcherTestConfig.connectionEdges.count)
            initialPageEdges = Array(self.fetcherTestConfig.connectionEdges[initialPageStartIndex..<initialPageEndIndex])
        }

        return initialPageEdges
    }

    func initialPage(for end: End) -> Page<TestModel> {
        let initialPageEdges = self.initialEdges(for: end)
        return Page<TestModel>(index: 0, edges: initialPageEdges)
    }

    func subsequentPage(
        relativeTo pages: [Page<TestModel>],
        for end: End)
        -> Page<TestModel>
    {
        let subsequentPageIndex: Int
        let subsequentPageEdges: [Edge<TestModel>]

        switch end {
        case .head:
            let headPage = pages.first!
            let beforeIndex = Int(headPage.edges.first!.cursor)!
            let subsequentPageStartIndex = max(beforeIndex - self.paginationPageSize, 0)
            let subsequentPageEndIndex = beforeIndex
            subsequentPageEdges = Array(self.fetcherTestConfig.connectionEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
            subsequentPageIndex = headPage.index - 1
        case .tail:
            let tailPage = pages.last!
            let afterIndex = Int(tailPage.edges.last!.cursor)!
            let subsequentPageStartIndex = afterIndex + 1
            let subsequentPageEndIndex = min(subsequentPageStartIndex + self.paginationPageSize, self.fetcherTestConfig.connectionEdges.count)
            subsequentPageEdges = Array(self.fetcherTestConfig.connectionEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
            subsequentPageIndex = tailPage.index + 1
        }

        return Page<TestModel>(index: subsequentPageIndex, edges: subsequentPageEdges)
    }
}
