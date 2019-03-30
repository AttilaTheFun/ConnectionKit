import RxCocoa
import RxSwift

final class PageFetcherCoordinator<F> where F: ConnectionFetcher {

    private var initialPageFetcher: PageFetcher<F>
    private var headPageFetcher: PageFetcher<F>
    private var tailPageFetcher: PageFetcher<F>

    private let initialPageFetcherStateRelay: BehaviorRelay<PageFetcherState<F>>
    private let headPageFetcherStateRelay: BehaviorRelay<PageFetcherState<F>>
    private let tailPageFetcherStateRelay: BehaviorRelay<PageFetcherState<F>>

    private let disposeBag = DisposeBag()

    // MARK: Initialization

    public init(initialPageFetcher: PageFetcher<F>, headPageFetcher: PageFetcher<F>, tailPageFetcher: PageFetcher<F>) {
        self.initialPageFetcherStateRelay = BehaviorRelay(value: initialPageFetcher.state)
        self.headPageFetcherStateRelay = BehaviorRelay(value: headPageFetcher.state)
        self.tailPageFetcherStateRelay = BehaviorRelay(value: tailPageFetcher.state)
        self.initialPageFetcher = initialPageFetcher
        self.headPageFetcher = headPageFetcher
        self.tailPageFetcher = tailPageFetcher
    }
}

// MARK: Private

extension PageFetcherCoordinator {
    private func fetcher(for type: PageFetcherType) -> PageFetcher<F> {
        switch type {
        case .initial:
            return self.initialPageFetcher
        case .head:
            return self.headPageFetcher
        case .tail:
            return self.tailPageFetcher
        }
    }

    private func relay(for type: PageFetcherType) -> BehaviorRelay<PageFetcherState<F>> {
        switch type {
        case .initial:
            return self.initialPageFetcherStateRelay
        case .head:
            return self.headPageFetcherStateRelay
        case .tail:
            return self.tailPageFetcherStateRelay
        }
    }

    private func observe(fetcher: PageFetcher<F>, for type: PageFetcherType) {
        fetcher.stateObservable.bind(to: self.relay(for: type))
            .disposed(by: self.disposeBag)
    }
}

// MARK: Getters

extension PageFetcherCoordinator {
    func state(for type: PageFetcherType) -> PageFetcherState<F> {
        return self.relay(for: type).value
    }

    func stateObservable(for type: PageFetcherType) -> Observable<PageFetcherState<F>> {
        return self.relay(for: type).asObservable()
    }
}

// MARK: Mutations

extension PageFetcherCoordinator {
    func loadPage(from type: PageFetcherType) {
        if !self.state(for: type).canLoadPage {
            return assertionFailure("Attempted to fetch page from invalid state")
        }

        self.fetcher(for: type).fetchPage()
    }

    func replace(fetcher type: PageFetcherType, with fetcher: PageFetcher<F>) {
        switch type {
        case .initial:
            self.initialPageFetcher = fetcher
        case .head:
            self.headPageFetcher = fetcher
        case .tail:
            self.tailPageFetcher = fetcher
        }

        self.observe(fetcher: fetcher, for: type)
    }
}
