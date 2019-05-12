
/**
 Stores a collection of pages of data and their indices.

 The initial page index is always 0.
 Pages ingested from the head have index [previous head index] - 1.
 Pages ingested from the tail have index [previous tail index] + 1.

 Examples:
 - The first page will have index 0 regardless of whether it is ingested from the head or the tail.
 - If the second page is ingested from the head, it will have index -1.
 - If the third page is ingested from the tail it will have index 1.
 - If the fourth page is ingested from the tail it will have index 2.
 */
protocol PageStorable: EdgeStorable {
    var pages: [Page<Model>] { get }
}

extension PageStorable {
    func cursor(for end: End) -> String? {
        guard let page = end == .head ? self.pages.last : self.pages.first else {
            return nil
        }

        guard let edge = end == .head ? page.edges.last : page.edges.first else {
            return nil
        }

        return edge.cursor
    }
}
