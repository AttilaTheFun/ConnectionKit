import RxCocoa
import RxSwift

final class PageFetcherFactory<Fetcher, Parser, Provider>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser, Provider: PageProvider,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node, Parser.Model == Provider.Model
{
    let initialPageSize: Int
    let paginationPageSize: Int

    private let fetcher: Fetcher
    private let parser: Parser.Type
    private let provider: Provider

    // MARK: Initialization

    init(fetcher: Fetcher, parser: Parser.Type, provider: Provider, initialPageSize: Int, paginationPageSize: Int) {
        self.fetcher = fetcher
        self.parser = parser
        self.provider = provider

        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
    }
}

// MARK: Private

extension PageFetcherFactory {
    private func cursor(for end: End) -> String? {
        let pages = self.provider.pages
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
        let pageSize = isInitial ? self.initialPageSize : self.paginationPageSize
        return PageFetcher(
            for: self.fetcher,
            parser: self.parser,
            end: end,
            pageSize: pageSize,
            cursor: self.cursor(for: end)
        )
    }
}
