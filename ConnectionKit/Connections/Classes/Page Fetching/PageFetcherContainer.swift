
final class PageFetcherContainer<Fetcher, Storer>
    where Fetcher: ConnectionFetcherProtocol, Storer: PageStorable,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Storer.Model
{
    typealias Node = Fetcher.FetchedConnection.ConnectedEdge.Node

    private let factory: PageFetcherFactory<Fetcher, Storer>
    private var initialHeadPageFetcher: PageFetcher<Fetcher>
    private var initialTailPageFetcher: PageFetcher<Fetcher>
    private var headPageFetcher: PageFetcher<Fetcher>
    private var tailPageFetcher: PageFetcher<Fetcher>

    init(factory: PageFetcherFactory<Fetcher, Storer>) {
        // Save factory:
        self.factory = factory

        // Create fetchers:
        self.initialHeadPageFetcher = self.factory.fetcher(for: .head, isInitial: true)
        self.initialTailPageFetcher = self.factory.fetcher(for: .tail, isInitial: true)
        self.headPageFetcher = self.factory.fetcher(for: .head, isInitial: false)
        self.tailPageFetcher = self.factory.fetcher(for: .tail, isInitial: false)
    }
}

// MARK: Getters

extension PageFetcherContainer {

    /**
     The combined state of all the fetchers.
     */
    var combinedState: CombinedPageFetcherState<Node> {
        return CombinedPageFetcherState<Node>(
            initialHeadPageFetcherState: self.fetcher(for: .head, isInitial: true).state,
            initialTailPageFetcherState: self.fetcher(for: .tail, isInitial: true).state,
            headPageFetcherState: self.fetcher(for: .head, isInitial: false).state,
            tailPageFetcherState: self.fetcher(for: .tail, isInitial: false).state
        )
    }

    /**
     Get the fetcher for the given parameters.
     */
    func fetcher(for end: End, isInitial: Bool) -> PageFetcher<Fetcher> {
        switch (end, isInitial) {
        case (.head, true):
            return self.initialHeadPageFetcher
        case (.head, false):
            return self.headPageFetcher
        case (.tail, true):
            return self.initialTailPageFetcher
        case (.tail, false):
            return self.tailPageFetcher
        }
    }
}

// MARK: Mutations

extension PageFetcherContainer {

    /**
     Reset the fetcher for the given parameters.
     Returns the newly created fetcher.
     */
    func resetFetcher(for end: End, isInitial: Bool) -> PageFetcher<Fetcher> {
        switch (end, isInitial) {
        case (.head, true):
            self.initialHeadPageFetcher = self.factory.fetcher(for: .head, isInitial: true)
        case (.tail, true):
            self.initialTailPageFetcher = self.factory.fetcher(for: .tail, isInitial: true)
        case (.head, false):
            self.headPageFetcher = self.factory.fetcher(for: .head, isInitial: false)
        case (.tail, false):
            self.tailPageFetcher = self.factory.fetcher(for: .tail, isInitial: false)
        }

        return self.fetcher(for: end, isInitial: isInitial)
    }
}
