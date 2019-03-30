import RxCocoa
import RxSwift

final class PageFetcher<F> where F: ConnectionFetcher {
    private let stateRelay = BehaviorRelay<PageFetcherState<F>>(value: .idle)
    private let fetchablePage: FetchablePage<F>
    private let disposeBag = DisposeBag()

    init(fetchablePage: @escaping FetchablePage<F>) {
        self.fetchablePage = fetchablePage
    }
}

// MARK: Private

extension PageFetcher {
    private enum PageFetcherError: String, Error {
        case fetchFiredCompleted = "Fetch should not fire onCompleted"
    }
}

// MARK: Interface

extension PageFetcher {

    // The current state of the fetcher.
    var state: PageFetcherState<F> {
        return self.stateRelay.value
    }

    // Observe the state of the fetch page.
    var stateObservable: Observable<PageFetcherState<F>> {
        return self.stateRelay.asObservable()
    }

    /**
     Begin fetching the page.
     If called from the idle state, will transition into the fetching state and begin the fetch.
     If called from the fetching state, an assertion is fired and nothing happens.
     If called from the complete state, an assertion is fired and nothing happens.
     If called from the error state, it transitions back into the fetching state.
     */
    func fetchPage() {
        switch self.state {
        case .idle, .error:
            self.restartFetch()
        case .fetching:
            return assertionFailure("Already fetching")
        case .completed:
            return assertionFailure("Already complete")
        }
    }

    private func restartFetch() {
        self.stateRelay.accept(.fetching)
        self.fetchablePage()
            .subscribe(
                onSuccess: { [weak self] connection in
                    self?.stateRelay.accept(.completed(connection.edges, connection.pageInfo))
                },
                onError: { [weak self] error in
                    let wrappedError = ErrorWrapper(error: error)
                    self?.stateRelay.accept(.error(wrappedError))
                },
                onCompleted: { [weak self] () -> Void in
                    let wrappedError = ErrorWrapper(error: PageFetcherError.fetchFiredCompleted)
                    self?.stateRelay.accept(.error(wrappedError))
                })
            .disposed(by: self.disposeBag)
    }
}

// MARK: Internal

extension PageFetcher {
    convenience init(
        for fetcher: F,
        end: End,
        pageSize: Int,
        cursor: String?)
    {
        self.init(fetchablePage: {
            switch end {
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
