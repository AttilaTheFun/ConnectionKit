import RxCocoa
import RxSwift
//import SwiftToolbox

final class PageFetcher<F> where F: ConnectionFetcher {
    private let stateRelay = BehaviorRelay<Connection.PageFetcherState<F>>(value: .idle)
    private let fetchablePage: FetchablePage<F>
    private let disposeBag = DisposeBag()

    init(fetchablePage: @escaping FetchablePage<F>) {
        self.fetchablePage = fetchablePage
    }
}

// MARK: Interface

extension PageFetcher {
    // The current state of the fetcher.
    var state: Connection.PageFetcherState<F> {
        return self.stateRelay.value
    }

    // Observe the state of the fetch page.
    var stateObservable: Observable<Connection.PageFetcherState<F>> {
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
        case .complete:
            return assertionFailure("Already complete")
        }
    }

    private func restartFetch() {
        self.stateRelay.accept(.fetching)
        self.fetchablePage()
            .subscribe(onSuccess: { [weak self] connection in
                self?.stateRelay.accept(.complete(connection.edges, connection.pageInfo))
            }, onError: { [weak self] error in
                self?.stateRelay.accept(.error(error))
            }, onCompleted: { [weak self] in
                self?.stateRelay.accept(.error(GenericError("Fetch should not fire onCompleted")))
            })
            .disposed(by: self.disposeBag)
    }
}
