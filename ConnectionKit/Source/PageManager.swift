import RxCocoa
import RxSwift

// TODO: Do not append empty pages.

final class PageManager<F> where F: ConnectionFetcher {
    private let pagesRelay = BehaviorRelay<[Page<F>]>(value: [])
}

// MARK: Private

extension PageManager {
    private var headPageIndex: Int {
        return self.pages.first?.index ?? 0
    }

    private var tailPageIndex: Int {
        return self.pages.last?.index ?? 0
    }
}

// MARK: Interface

extension PageManager {
    /**
     Array of tuples of the page index and page of data.
     */
    var pages: [Page<F>] {
        return self.pagesRelay.value
    }

    /**
     Observable for the pages.
     */
    var pagesObservable: Observable<[Page<F>]> {
        return self.pagesRelay.asObservable()
    }

    /**
     Ingest a page of data into the manager.

     The initial page index is always 0.
     Pages ingested from the head have index [previous head index] - 1.
     Pages ingested from the tail have index [previous tail index] + 1.

     Examples:
     - The first page will have index 0 regardless of whether it is ingested from the head or the tail.
     - If the second page is ingested from the head, it will have index -1.
     - If the third page is ingested from the tail it will have index 1.
     - If the fourth page is ingested from the tail it will have index 2.
     */
    func ingest(edges: [Edge<F>], from end: End) {
        // Drop empty pages:
        if edges.count == 0 {
            return
        }

        // If initial page, always index 0:
        if self.pages.count == 0 {
            let initialPage = Page<F>(index: 0, edges: edges)
            self.pagesRelay.accept([initialPage])
            return
        }

        // Append the page to the beginning or end if ingesting from the head or tail respectively.
        switch end {
        case .head:
            let headPage = Page<F>(index: self.headPageIndex - 1, edges: edges)
            self.pagesRelay.accept([headPage] + self.pages)
        case .tail:
            let tailPage = Page<F>(index: self.tailPageIndex + 1, edges: edges)
            self.pagesRelay.accept(self.pages + [tailPage])
        }
    }

    /**
     Reset the pages back to an empty array.
     The next ingested page will have index 0 again.
     */
    func reset() {
        self.pagesRelay.accept([])
    }
}
