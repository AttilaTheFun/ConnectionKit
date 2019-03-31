import RxCocoa
import RxSwift

final class PageFetcherFactory<F, P> where P: PageProvider, P.Fetcher == F {

    private let fetcher: F
    private let initialPageSize: Int
    private let paginationPageSize: Int
    private let pageProvider: P

    // MARK: Initialization

    init(fetcher: F, pageProvider: P, initialPageSize: Int, paginationPageSize: Int) {
        self.fetcher = fetcher
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
        self.pageProvider = pageProvider
    }
}

// MARK: Private

extension PageFetcherFactory {
    private func cursor(for end: End) -> String? {
        let pages = self.pageProvider.pages
        guard let page = end == .head ? pages.first : pages.last else {
            return nil
        }

        guard let edge = end == .head ? page.edges.first : page.edges.last else {
            return nil
        }

        return edge.cursor
    }
}

// MARK: Interface

extension PageFetcherFactory {
    /**
     Create a new fetcher with the appropriate page size which will fetch with the associated cursor for the end.
     */
    func fetcher(for end: End, isInitial: Bool) -> PageFetcher<F> {
        return PageFetcher(
            for: self.fetcher,
            end: end,
            pageSize: isInitial ? self.initialPageSize : self.paginationPageSize,
            cursor: self.cursor(for: end)
        )
    }
}
