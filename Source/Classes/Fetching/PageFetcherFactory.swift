import RxCocoa
import RxSwift

final class PageFetcherFactory<Fetcher, Storer>
    where Fetcher: ConnectionFetcherProtocol, Storer: EdgeStorable,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Storer.Model
{
    typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    private let fetcher: Fetcher
    private let storer: Storer
    private let configuration: PaginationConfiguration

    // MARK: Initialization

    init(fetcher: Fetcher, storer: Storer, configuration: PaginationConfiguration) {
        self.fetcher = fetcher
        self.storer = storer
        self.configuration = configuration
    }
}

// MARK: Interface

extension PageFetcherFactory {

    /**
     Create a new fetcher with the appropriate page size which will fetch with the associated cursor for the end.
     */
    func fetcher(for end: End, isInitial: Bool) -> PageFetcher<Fetcher> {
        return PageFetcher(
            for: self.fetcher,
            end: end,
            pageSize: isInitial ? self.configuration.initialPageSize : self.configuration.paginationPageSize,
            cursor: isInitial ? nil : self.storer.cursor(for: end)
        )
    }
}
