@testable import ConnectionKit
import XCTest

extension XCTestCase {
    func initialEdges(
        defaultIndex: Int,
        initialPageSize: Int,
        edges: [TestEdge],
        for end: End) -> [TestEdge]
    {
        let initialPageEdges: [TestEdge]

        switch end {
        case .head:
            let initialHeadPageStartIndex = max(defaultIndex - initialPageSize, 0)
            let initialHeadPageEndIndex = defaultIndex
            initialPageEdges = Array(edges[initialHeadPageStartIndex..<initialHeadPageEndIndex])
        case .tail:
            let initialPageStartIndex = defaultIndex
            let initialPageEndIndex = min(defaultIndex + initialPageSize, edges.count)
            initialPageEdges = Array(edges[initialPageStartIndex..<initialPageEndIndex])
        }

        return initialPageEdges
    }

    func initialPage(
        defaultIndex: Int,
        initialPageSize: Int,
        edges: [TestEdge],
        for end: End) -> Page<TestFetcher>
    {
        let initialPageEdges = self.initialEdges(defaultIndex: defaultIndex, initialPageSize: initialPageSize, edges: edges, for: end)
        return Page<TestFetcher>(index: 0, edges: initialPageEdges)
    }

    func subsequentPage(
        relativeTo pages: [Page<TestFetcher>],
        paginationPageSize: Int,
        edges: [TestEdge],
        for end: End) -> Page<TestFetcher>
    {
        let subsequentPageIndex: Int
        let subsequentPageEdges: [TestEdge]

        switch end {
        case .head:
            let headPage = pages.first!
            let beforeIndex = Int(headPage.edges.first!.cursor)!
            let subsequentPageStartIndex = max(beforeIndex - paginationPageSize, 0)
            let subsequentPageEndIndex = beforeIndex
            subsequentPageEdges = Array(edges[subsequentPageStartIndex..<subsequentPageEndIndex])
            subsequentPageIndex = headPage.index - 1
        case .tail:
            let tailPage = pages.last!
            let afterIndex = Int(tailPage.edges.last!.cursor)!
            let subsequentPageStartIndex = afterIndex + 1
            let subsequentPageEndIndex = min(subsequentPageStartIndex + paginationPageSize, edges.count)
            subsequentPageEdges = Array(edges[subsequentPageStartIndex..<subsequentPageEndIndex])
            subsequentPageIndex = tailPage.index + 1
        }

        return Page<TestFetcher>(index: subsequentPageIndex, edges: subsequentPageEdges)
    }
}
