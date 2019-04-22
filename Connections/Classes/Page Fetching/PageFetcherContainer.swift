
final class PageFetcherContainer<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    private let factory: PageFetcherFactory<Fetcher, Parser>

    private var initialHeadPageFetcher: PageFetcher<Fetcher, Parser>
    private var initialTailPageFetcher: PageFetcher<Fetcher, Parser>
    private var headPageFetcher: PageFetcher<Fetcher, Parser>
    private var tailPageFetcher: PageFetcher<Fetcher, Parser>

    init(factory: PageFetcherFactory<Fetcher, Parser>) {
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
     Get the fetcher for the given parameters.
     */
    func fetcher(for end: End, isInitial: Bool) -> PageFetcher<Fetcher, Parser> {
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
    func resetFetcher(for end: End, isInitial: Bool) -> PageFetcher<Fetcher, Parser> {
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
