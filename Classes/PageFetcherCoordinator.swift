import RxCocoa
import RxSwift

final class PageFetcherCoordinator<F> where F: ConnectionFetcher {

    private var initialHeadPageFetcher: PageFetcher<F>
    private var initialTailPageFetcher: PageFetcher<F>
    private var headPageFetcher: PageFetcher<F>
    private var tailPageFetcher: PageFetcher<F>

    private let initialHeadPageFetcherStateRelay: BehaviorRelay<PageFetcherState<F>>
    private let initialTailPageFetcherStateRelay: BehaviorRelay<PageFetcherState<F>>
    private let headPageFetcherStateRelay: BehaviorRelay<PageFetcherState<F>>
    private let tailPageFetcherStateRelay: BehaviorRelay<PageFetcherState<F>>

    private var initialHeadPageDisposable = Disposables.create()
    private var initialTailPageDisposable = Disposables.create()
    private var headPageDisposable = Disposables.create()
    private var tailPageDisposable = Disposables.create()
    private let disposeBag = DisposeBag()

    // MARK: Initialization

    public init(
        initialHeadPageFetcher: PageFetcher<F>,
        initialTailPageFetcher: PageFetcher<F>,
        headPageFetcher: PageFetcher<F>,
        tailPageFetcher: PageFetcher<F>)
    {
        self.initialHeadPageFetcher = initialHeadPageFetcher
        self.initialTailPageFetcher = initialTailPageFetcher
        self.headPageFetcher = headPageFetcher
        self.tailPageFetcher = tailPageFetcher

        self.initialHeadPageFetcherStateRelay = BehaviorRelay(value: initialHeadPageFetcher.state)
        self.initialTailPageFetcherStateRelay = BehaviorRelay(value: initialTailPageFetcher.state)
        self.headPageFetcherStateRelay = BehaviorRelay(value: headPageFetcher.state)
        self.tailPageFetcherStateRelay = BehaviorRelay(value: tailPageFetcher.state)

        // Bind observables to their respective relays:
        self.bind(fetcher: initialHeadPageFetcher, for: .head, isInitial: true)
        self.bind(fetcher: headPageFetcher, for: .head, isInitial: false)
        self.bind(fetcher: initialTailPageFetcher, for: .tail, isInitial: true)
        self.bind(fetcher: tailPageFetcher, for: .tail, isInitial: false)
    }
}

// MARK: Private

extension PageFetcherCoordinator {
    private func fetcher(for end: End, isInitial: Bool) -> PageFetcher<F> {
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

    private func relay(for end: End, isInitial: Bool) -> BehaviorRelay<PageFetcherState<F>> {
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

    private func replaceDisposable(for end: End, isInitial: Bool, with newDisposable: Disposable) {
        switch (end, isInitial) {
        case (.head, true):
            self.initialHeadPageDisposable.dispose()
            self.initialHeadPageDisposable = newDisposable
        case (.head, false):
            self.headPageDisposable.dispose()
            self.headPageDisposable = newDisposable
        case (.tail, true):
            self.initialTailPageDisposable.dispose()
            self.initialTailPageDisposable = newDisposable
        case (.tail, false):
            self.tailPageDisposable.dispose()
            self.tailPageDisposable = newDisposable
        }

        newDisposable.disposed(by: self.disposeBag)
    }

    private func bind(fetcher: PageFetcher<F>, for end: End, isInitial: Bool) {
        let relay = self.relay(for: end, isInitial: isInitial)
        let newDisposable = fetcher.stateObservable.bind(to: relay)
        self.replaceDisposable(for: end, isInitial: isInitial, with: newDisposable)
    }
}

// MARK: Getters

extension PageFetcherCoordinator {
    /**
     Retrieve the state for the fetcher matching the given parameters.
     */
    func state(for end: End, isInitial: Bool) -> PageFetcherState<F> {
        return self.relay(for: end, isInitial: isInitial).value
    }

    /**
     Observable for the aforementioned state.
     */
    func stateObservable(for end: End, isInitial: Bool) -> Observable<PageFetcherState<F>> {
        return self.relay(for: end, isInitial: isInitial).asObservable()
    }
}

// MARK: Mutations

extension PageFetcherCoordinator {
    /**
     Load a page from the fetcher matching the given parameters.
     */
    func loadPage(from end: End, isInitial: Bool) {
        if !self.state(for: end, isInitial: isInitial).canLoadPage {
            return assertionFailure("Attempted to fetch page from invalid state")
        }

        self.fetcher(for: end, isInitial: isInitial).fetchPage()
    }

    /**
     Replace the next page fetcher at the given end.
     The initial load fetchers cannot be replaced as they do not change.
     */
    func replaceNextPageFetcher(at end: End, with fetcher: PageFetcher<F>) {
        switch end {
        case .head:
            self.headPageFetcher = fetcher
        case .tail:
            self.tailPageFetcher = fetcher
        }

        // Bind the new fetcher to its respective relay:
        self.bind(fetcher: fetcher, for: end, isInitial: false)
    }
}
