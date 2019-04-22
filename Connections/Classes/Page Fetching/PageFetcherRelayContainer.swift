import RxCocoa
import RxSwift

/**
 This class is responsible for observing the fetchers' states and feeding them into relays to provide
 long-lived state observables.
 */
final class PageFetcherRelayContainer<Fetcher, Parser>
    where Fetcher: ConnectionFetcherProtocol, Parser: ModelParser,
    Fetcher.FetchedConnection.ConnectedEdge.Node == Parser.Node
{
    private let initialHeadPageFetcherStateRelay: BehaviorRelay<PageFetcherState<Parser.Model>>
    private let initialTailPageFetcherStateRelay: BehaviorRelay<PageFetcherState<Parser.Model>>
    private let headPageFetcherStateRelay: BehaviorRelay<PageFetcherState<Parser.Model>>
    private let tailPageFetcherStateRelay: BehaviorRelay<PageFetcherState<Parser.Model>>

    private let disposeBag = DisposeBag()

    init(initialHeadPageFetcher: PageFetcher<Fetcher, Parser>,
         initialTailPageFetcher: PageFetcher<Fetcher, Parser>,
         headPageFetcher: PageFetcher<Fetcher, Parser>,
         tailPageFetcher: PageFetcher<Fetcher, Parser>)
    {
        // Create individual state relays:
        self.initialHeadPageFetcherStateRelay = BehaviorRelay(value: initialHeadPageFetcher.state)
        self.initialTailPageFetcherStateRelay = BehaviorRelay(value: initialTailPageFetcher.state)
        self.headPageFetcherStateRelay = BehaviorRelay(value: headPageFetcher.state)
        self.tailPageFetcherStateRelay = BehaviorRelay(value: tailPageFetcher.state)

        // Bind fetchers to their respective relays:
        self.bind(fetcher: initialHeadPageFetcher, for: .head, isInitial: true)
        self.bind(fetcher: initialTailPageFetcher, for: .tail, isInitial: true)
        self.bind(fetcher: headPageFetcher, for: .head, isInitial: false)
        self.bind(fetcher: tailPageFetcher, for: .tail, isInitial: false)
    }
}

// MARK: Private

extension PageFetcherRelayContainer {
    private func relay(for end: End, isInitial: Bool) -> BehaviorRelay<PageFetcherState<Parser.Model>> {
        switch (end, isInitial) {
        case (.head, true):
            return self.initialHeadPageFetcherStateRelay
        case (.head, false):
            return self.headPageFetcherStateRelay
        case (.tail, true):
            return self.initialTailPageFetcherStateRelay
        case (.tail, false):
            return self.tailPageFetcherStateRelay
        }
    }
}

// MARK: Getters

extension PageFetcherRelayContainer {

    /**
     State for the fetcher matching the given parameters.
     */
    func state(for end: End, isInitial: Bool) -> PageFetcherState<Parser.Model> {
        return self.relay(for: end, isInitial: isInitial).value
    }

    /**
     Observable for the aforementioned state.
     */
    func stateObservable(for end: End, isInitial: Bool) -> Observable<PageFetcherState<Parser.Model>> {
        return self.relay(for: end, isInitial: isInitial).asObservable()
    }
}

// MARK: Mutations

extension PageFetcherRelayContainer {

    /**
     Bind the given fetcher to its respective state relay.
     */
    func bind(fetcher: PageFetcher<Fetcher, Parser>, for end: End, isInitial: Bool) {
        fetcher.stateObservable
            .subscribe(onNext: { [weak self] pageFetcherState in
                guard let `self` = self else {
                    return
                }

                self.relay(for: end, isInitial: isInitial).accept(pageFetcherState)
            })
            .disposed(by: self.disposeBag)
    }
}
