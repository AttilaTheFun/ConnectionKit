import RxCocoa
import RxSwift

final class PageFetcherFactory<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    private let fetcher: Fetcher
    private let parser: Parser.Type
    private let pageStorer: PageStorer<Parser.Model>
    private let initialPageSize: Int
    private let paginationPageSize: Int

    // MARK: Initialization

    init(fetcher: Fetcher, parser: Parser.Type, pageStorer: PageStorer<Parser.Model>, initialPageSize: Int, paginationPageSize: Int) {
        self.fetcher = fetcher
        self.parser = parser
        self.pageStorer = pageStorer

        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
    }
}

// MARK: Private

extension PageFetcherFactory {
    private func cursor(for end: End) -> String? {
        let pages = self.pageStorer.pages
        guard let page = end == .head ? pages.last : pages.first else {
            return nil
        }

        guard let edge = end == .head ? page.edges.last : page.edges.first else {
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
    func fetcher(for end: End, isInitial: Bool) -> PageFetcher<Fetcher, Parser> {
        return PageFetcher(
            for: self.fetcher,
            parser: self.parser,
            end: end,
            pageSize: isInitial ? self.initialPageSize : self.paginationPageSize,
            cursor: isInitial ? nil : self.cursor(for: end)
        )
    }
}
