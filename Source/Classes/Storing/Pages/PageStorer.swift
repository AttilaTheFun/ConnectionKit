import RxCocoa
import RxSwift

public final class PageStorer<Model> {
    private(set) public var pages: [Page<Model>]

    public init(initialEdges: [Edge<Model>] = []) {
        self.pages = Page<Model>.nextPages(from: [], ingesting: initialEdges, from: .head)
    }
}

// MARK: Getters

extension PageStorer: PageStorable {
    public func ingest(edges: [Edge<Model>], from end: End) {
        self.pages = Page<Model>.nextPages(from: self.pages, ingesting: edges, from: end)
    }

    public func reset(to initialEdges: [Edge<Model>]) {
        // Initial end does not matter.
        self.pages = Page<Model>.nextPages(from: [], ingesting: initialEdges, from: .head)
    }
}
