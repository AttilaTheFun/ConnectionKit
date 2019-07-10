
/**
 Structs combining the page index and the array of edges that was fetched with that page.

 The initial page index is always 0.
 Pages fetched from the head have index [previous head index] - 1.
 Pages fetched from the tail have index [previous tail index] + 1.

 Examples:
 - The first page will have index 0 regardless of whether it is ingested from the head or the tail.
 - If the second page is fetched from the head, it will have index -1.
 - If the third page is fetched from the tail it will have index 1.
 - If the fourth page is fetched from the tail it will have index 2.
 */
public struct Page<Model> {
    public let index: Int
    public let edges: [Edge<Model>]

    public init(index: Int, edges: [Edge<Model>]) {
        self.index = index
        self.edges = edges
    }
}

extension Page: Equatable where Model: Equatable {}
extension Page: Hashable where Model: Hashable {}

extension Page {
    /**
     Computes the next pages from the previous pages by ingesting the edges.
     */
    static func nextPages(from previousPages: [Page<Model>], ingesting edges: [Edge<Model>], from end: End) -> [Page<Model>] {
        // Drop empty pages:
        if edges.count == 0 {
            return previousPages
        }

        // If initial page, always index 0:
        if previousPages.count == 0 {
            return [Page<Model>(index: 0, edges: edges)]
        }

        // Append the page to the beginning or end if ingesting from the head or tail respectively.
        switch end {
        case .head:
            let headPage = Page<Model>(index: self.headPageIndex(for: previousPages) + 1, edges: edges)
            return previousPages + [headPage]
        case .tail:
            let tailPage = Page<Model>(index: self.tailPageIndex(for: previousPages) - 1, edges: edges)
            return [tailPage] + previousPages
        }
    }

    private static func headPageIndex(for pages: [Page<Model>]) -> Int {
        return pages.last?.index ?? 0
    }

    private static func tailPageIndex(for pages: [Page<Model>]) -> Int {
        return pages.first?.index ?? 0
    }
}
