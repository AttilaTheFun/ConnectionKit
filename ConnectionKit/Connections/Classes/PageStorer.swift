import RxCocoa
import RxSwift

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
final class PageStorer<Model> {
    private let pagesRelay: BehaviorRelay<[Page<Model>]>

    init(initialEdges: [Edge<Model>] = []) {
        // Initial end does not matter.
        let initialPages = Page<Model>.nextPages(from: [], ingesting: initialEdges, from: .head)
        self.pagesRelay = BehaviorRelay(value: initialPages)
    }
}

// MARK: Getters

extension PageStorer {

    /**
     The pages currently stored by the storer.
     */
    var pages: [Page<Model>] {
        return self.pagesRelay.value
    }
}

// MARK: Mutations

extension PageStorer {

    /**
     Ingest a page of data into the manager.
     */
    func ingest(edges: [Edge<Model>], from end: End) {
        let nextPages = Page<Model>.nextPages(from: self.pages, ingesting: edges, from: end)
        self.pagesRelay.accept(nextPages)
    }

    /**
     Reset the pages back to a known set of edges.

     */
    func reset(to initialEdges: [Edge<Model>]) {
        // Initial end does not matter.
        let initialPages = Page<Model>.nextPages(from: [], ingesting: initialEdges, from: .head)
        self.pagesRelay.accept(initialPages)
    }
}
