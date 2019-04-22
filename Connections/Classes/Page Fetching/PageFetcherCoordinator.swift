import RxCocoa
import RxSwift

final class PageFetcherCoordinator<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    private let pageFetcherContainer: PageFetcherContainer<Fetcher, Parser>
    private let pageFetcherRelayContainer: PageFetcherRelayContainer<Fetcher, Parser>

    // MARK: Initialization

    public init(factory: PageFetcherFactory<Fetcher, Parser>) {
        self.pageFetcherContainer = PageFetcherContainer(factory: factory)
        self.pageFetcherRelayContainer = PageFetcherRelayContainer(
            initialHeadPageFetcher: self.pageFetcherContainer.fetcher(for: .head, isInitial: true),
            initialTailPageFetcher: self.pageFetcherContainer.fetcher(for: .tail, isInitial: true),
            headPageFetcher: self.pageFetcherContainer.fetcher(for: .head, isInitial: false),
            tailPageFetcher: self.pageFetcherContainer.fetcher(for: .tail, isInitial: false)
        )
    }
}

// MARK: Getters

extension PageFetcherCoordinator {
    /**
     The current combined state of all of the fetchers.
     */
    var state: PageFetcherCoordinatorState<Parser.Model> {
        return PageFetcherCoordinatorState<Parser.Model>(
            initialHeadPageFetcherState: self.pageFetcherRelayContainer.state(for: .head, isInitial: true),
            initialTailPageFetcherState: self.pageFetcherRelayContainer.state(for: .tail, isInitial: true),
            headPageFetcherState: self.pageFetcherRelayContainer.state(for: .head, isInitial: false),
            tailPageFetcherState: self.pageFetcherRelayContainer.state(for: .tail, isInitial: false)
        )
    }

    /**
     State for the fetcher matching the given parameters.
     */
    func state(for end: End, isInitial: Bool) -> PageFetcherState<Parser.Model> {
        return self.pageFetcherRelayContainer.state(for: end, isInitial: isInitial)
    }

    /**
     Observable for the aforementioned state.
     */
    func stateObservable(for end: End, isInitial: Bool) -> Observable<PageFetcherState<Parser.Model>> {
        return self.pageFetcherRelayContainer.stateObservable(for: end, isInitial: isInitial)
    }
}

// MARK: Mutations

extension PageFetcherCoordinator {

    /**
     Load a page from the fetcher matching the given parameters.
     */
    func loadPage(from end: End, isInitial: Bool) {

        // Make sure we can fetch a page from this state:
        if self.pageFetcherRelayContainer.state(for: end, isInitial: isInitial).isLoadingNextPage {
            return assertionFailure("Already loading next page from this fetcher")
        }

        if isInitial {
            // Initial page can only be fetched from one end at a time and doesn't need reset:
            if self.pageFetcherRelayContainer.state(for: end.opposite, isInitial: true).isLoadingNextPage {
                return assertionFailure("Already loading initial page from opposite fetcher")
            }
        } else {
            // If fetching next page, need to reset fetcher to get current cursor:
            let newFetcher = self.pageFetcherContainer.resetFetcher(for: end, isInitial: false)
            self.pageFetcherRelayContainer.bind(fetcher: newFetcher, for: end, isInitial: false)
        }

        // Actually begin the fetch.
        self.pageFetcherContainer.fetcher(for: end, isInitial: isInitial).fetchPage()
    }

    /**
     Reset all of the fetchers to their idle states, stopping all inflight requests.
     */
    func reset() {

        // Reset fetchers:
        let initialHeadPageFetcher = self.pageFetcherContainer.resetFetcher(for: .head, isInitial: true)
        let initialTailPageFetcher = self.pageFetcherContainer.resetFetcher(for: .tail, isInitial: true)
        let headPageFetcher = self.pageFetcherContainer.resetFetcher(for: .head, isInitial: false)
        let tailPageFetcher = self.pageFetcherContainer.resetFetcher(for: .tail, isInitial: false)

        // Bind fetchers to their respective relays:
        self.pageFetcherRelayContainer.bind(fetcher: initialHeadPageFetcher, for: .head, isInitial: true)
        self.pageFetcherRelayContainer.bind(fetcher: initialTailPageFetcher, for: .tail, isInitial: true)
        self.pageFetcherRelayContainer.bind(fetcher: headPageFetcher, for: .head, isInitial: false)
        self.pageFetcherRelayContainer.bind(fetcher: tailPageFetcher, for: .tail, isInitial: false)
    }
}
