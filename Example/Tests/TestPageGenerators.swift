@testable import ConnectionKit
import XCTest

extension ConnectionTestConfig {
    func initialEdges(for end: End) -> [Edge<TestModel>] {
        let initialPageEdges: [Edge<TestModel>]

        let allEdges = self.fetcherTestConfig.connectionEdges
        switch end {
        case .head:
            let endIndex = min(self.initialPageSize, allEdges.count)
            initialPageEdges = Array(allEdges[0 ..< endIndex])
        case .tail:
            let startIndex = max(allEdges.count - self.initialPageSize, 0)
            initialPageEdges = Array(allEdges[startIndex ..< allEdges.count])
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
            let tailPage = pages.last!
            let afterIndex = Int(tailPage.edges.last!.cursor)!
            let subsequentPageStartIndex = afterIndex + 1
            let subsequentPageEndIndex = min(subsequentPageStartIndex + self.paginationPageSize, self.fetcherTestConfig.connectionEdges.count)
            subsequentPageEdges = Array(self.fetcherTestConfig.connectionEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
            subsequentPageIndex = tailPage.index + 1
        case .tail:
            let headPage = pages.first!
            let beforeIndex = Int(headPage.edges.first!.cursor)!
            let subsequentPageStartIndex = max(beforeIndex - self.paginationPageSize, 0)
            let subsequentPageEndIndex = beforeIndex
            subsequentPageEdges = Array(self.fetcherTestConfig.connectionEdges[subsequentPageStartIndex..<subsequentPageEndIndex])
            subsequentPageIndex = headPage.index - 1
        }

        return Page<TestModel>(index: subsequentPageIndex, edges: subsequentPageEdges)
    }
}
