import RxCocoa
import RxSwift

final class PageManager<F> where F: ConnectionFetcher {
    private let pagesRelay = BehaviorRelay<[(Int, Edges<F>)]>(value: [])
}

// MARK: Private

extension PageManager {
    private var headPageIndex: Int {
        return self.pages.first?.0 ?? 0
    }

    private var tailPageIndex: Int {
        return self.pages.last?.0 ?? 0
    }
}

// MARK: Interface

extension PageManager {
    /**
     Array of tuples of the page index and page of data.
     */
    var pages: [(Int, Edges<F>)] {
        return self.pagesRelay.value
    }

    /**
     Observable for the pages.
     */
    var pagesObservable: Observable<[(Int, Edges<F>)]> {
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
    func ingest(page: Edges<F>, from position: PagePosition) {
        if self.pages.count == 0 {
            let initialPage = (0, page)
            self.pagesRelay.accept([initialPage])
            return
        }

        switch position {
        case .head:
            let headPage = (self.headPageIndex - 1, page)
            self.pagesRelay.accept([headPage] + self.pages)
        case .tail:
            let tailPage = (self.tailPageIndex + 1, page)
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
