import RxCocoa
import RxSwift

final class PageStorer<Model> {
    private let pagesRelay: BehaviorRelay<[Page<Model>]>

    init(initialEdges: [Edge<Model>] = []) {
        let initialPages = Page<Model>.nextPages(from: [], ingesting: initialEdges, from: .head)
        self.pagesRelay = BehaviorRelay(value: initialPages)
    }
}

// MARK: Getters

extension PageStorer: PageStorable {
    var pages: [Page<Model>] {
        return self.pagesRelay.value
    }

    func ingest(edges: [Edge<Model>], from end: End) {
        let nextPages = Page<Model>.nextPages(from: self.pages, ingesting: edges, from: end)
        self.pagesRelay.accept(nextPages)
    }

    func reset(to initialEdges: [Edge<Model>]) {
        // Initial end does not matter.
        let initialPages = Page<Model>.nextPages(from: [], ingesting: initialEdges, from: .head)
        self.pagesRelay.accept(initialPages)
    }
}
