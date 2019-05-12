import RxCocoa
import RxSwift

final class PageFetcherFactory<Fetcher, Storer>
    where Fetcher: ConnectionFetcherProtocol, Storer: EdgeStorable,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Storer.Model
{
    typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    private let fetcher: Fetcher
    private let edgeStorer: Storer
    private let initialPageSize: Int
    private let paginationPageSize: Int

    // MARK: Initialization

    init(fetcher: Fetcher, edgeStorer: Storer, initialPageSize: Int, paginationPageSize: Int) {
        self.fetcher = fetcher
        self.edgeStorer = edgeStorer

        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
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
            pageSize: isInitial ? self.initialPageSize : self.paginationPageSize,
            cursor: isInitial ? nil : self.edgeStorer.cursor(for: end)
        )
    }
}
