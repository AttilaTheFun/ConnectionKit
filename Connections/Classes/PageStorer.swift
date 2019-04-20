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
final class PageStorer<Model> where Model: Hashable {
    private let pagesRelay = BehaviorRelay<[Page<Model>]>(value: [])

    init(initialEdges: [Edge<Model>] = []) {
        // Initial end doesn't matter so just use head.
        self.applyUpdate(from: [], edges: initialEdges, from: .head)
    }
}

// MARK: Private

extension PageStorer {
    private func headPageIndex(for pages: [Page<Model>]) -> Int {
        return pages.last?.index ?? 0
    }

    private func tailPageIndex(for pages: [Page<Model>]) -> Int {
        return pages.first?.index ?? 0
    }

    /**
     Ingest a page of data into the manager.
     */
    private func applyUpdate(from previousPages: [Page<Model>], edges: [Edge<Model>], from end: End) {
        // Drop empty pages:
        if edges.count == 0 {
            self.pagesRelay.accept(previousPages)
            return
        }

        // If initial page, always index 0:
        if previousPages.count == 0 {
            let initialPage = Page<Model>(index: 0, edges: edges)
            self.pagesRelay.accept([initialPage])
            return
        }

        // Append the page to the beginning or end if ingesting from the head or tail respectively.
        switch end {
        case .head:
            let headPage = Page<Model>(index: self.headPageIndex(for: previousPages) + 1, edges: edges)
            self.pagesRelay.accept(previousPages + [headPage])
        case .tail:
            let tailPage = Page<Model>(index: self.tailPageIndex(for: previousPages) - 1, edges: edges)
            self.pagesRelay.accept([tailPage] + previousPages)
        }
    }
}

// MARK: PageProvider

extension PageStorer: PageProvider {
    var pages: [Page<Model>] {
        return self.pagesRelay.value
    }

    var pagesObservable: Observable<[Page<Model>]> {
        return self.pagesRelay.asObservable()
    }
}

// MARK: Mutations

extension PageStorer {

    /**
     Ingest a page of data into the manager.
     */
    func ingest(edges: [Edge<Model>], from end: End) {
        self.applyUpdate(from: self.pages, edges: edges, from: end)
    }

    /**
     Reset the pages back to an empty array.
     The next ingested page will have index 0 again.
     */
    func reset(to edges: [Edge<Model>], from end: End) {
        self.applyUpdate(from: [], edges: edges, from: end)
    }
}
