import RxCocoa
import RxSwift

final class ConnectionManager<F> where F: ConnectionFetcher {

    private let fetcher: F
    private let initialPageSize: Int
    private let paginationPageSize: Int

    private let paginationManager = PaginationManager<F>()
    private let pageManager = PageManager<F>()
    private var headFetcher: PageFetcher<F>
    private var tailFetcher: PageFetcher<F>

    private let headStateRelay = BehaviorRelay<EndState>(value: .idle)
    private let tailStateRelay = BehaviorRelay<EndState>(value: .idle)
    private let disposeBag = DisposeBag()

    init(fetcher: F, initialPageSize: Int = 2, paginationPageSize: Int = 4) {
        self.fetcher = fetcher
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
        self.headFetcher = ConnectionManager.pageFetcher(for: fetcher, position: .head, pageSize: initialPageSize, cursor: nil)
        self.tailFetcher = ConnectionManager.pageFetcher(for: fetcher, position: .tail, pageSize: initialPageSize, cursor: nil)

        // Subscribe to observables:
        self.headFetcher.stateObservable
            .subscribe(onNext: { [weak self] headState in

            })
    }
}

// MARK: Private

extension ConnectionManager {
    private func handleFetcherState(
        _ state: PageFetcherState<F>,
        position: PagePosition)
    {
        let relay = position == .head ? self.headStateRelay : self.tailStateRelay
        switch state {
        case .idle:
            relay.accept(.idle)
        case .fetching:
            relay.accept(.fetching)
        case .error(let error):
            relay.accept(.error(error))
        case .complete(let page, let pageInfo):
            self.paginationManager.ingest(pageInfo: pageInfo, from: position)
            self.pageManager.ingest(page: page, from: position)
            // Does replacing fetcher fire idle?
//            switch position {
//            case .head:

//                self.headStateRelay.accept(.idle)
//            }
        }
    }

    private static func pageFetcher(
        for fetcher: F,
        position: PagePosition,
        pageSize: Int,
        cursor: String?)
        -> PageFetcher<F>
    {
        return PageFetcher(fetchablePage: {
            switch position {
            case .head:
                // Paginating backward: `pageSize and `cursor` will be passed as the `last` and `before` arguments.
                return fetcher.fetch(first: nil, after: nil, last: pageSize, before: cursor)
            case .tail:
                // Paginating forward: `pageSize and `cursor` will be passed as the `first` and `after` arguments.
                return fetcher.fetch(first: pageSize, after: cursor, last: nil, before: nil)
            }
        })
    }
}

// MARK: Interface


