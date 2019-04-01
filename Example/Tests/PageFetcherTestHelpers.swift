@testable import ConnectionKit
import RxSwift
import XCTest

extension XCTestCase {
    func runTest(
        config: FetcherTestConfig,
        fetchConfig: FetchConfig,
        expectedPageInfo: PageInfo,
        expectedEdges: [Edge<TestModel>],
        disposedBy disposeBag: DisposeBag) throws
    {
        // Create fetcher:
        let pageFetcher = PageFetcher<TestFetcher, TestParser>(fetchablePage: {
            return config.fetcher.fetch(config: fetchConfig)
        }, parser: TestParser.self)
        let observable = pageFetcher.stateObservable

        // Create expectations:
        let expectations = [
            self.expectIdle(observable: observable, disposedBy: disposeBag),
            self.expectFetching(observable: observable, disposedBy: disposeBag),
            self.expectCompleted(
                observable: observable,
                expectedEdges: expectedEdges,
                expectedPageInfo: expectedPageInfo,
                disposedBy: disposeBag
            )
        ]

        // Run the test:
        pageFetcher.fetchPage()

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectIdle(
        observable: Observable<PageFetcherState<TestModel>>,
        disposedBy disposeBag: DisposeBag)
        -> XCTestExpectation
    {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        observable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, .idle)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectFetching(
        observable: Observable<PageFetcherState<TestModel>>,
        disposedBy disposeBag: DisposeBag)
        -> XCTestExpectation
    {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        observable
            .skip(1)
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, .fetching)
                receivedFetchingStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedFetchingStateExpectation
    }

    private func expectCompleted(
        observable: Observable<PageFetcherState<TestModel>>,
        expectedEdges: [Edge<TestModel>],
        expectedPageInfo: PageInfo,
        disposedBy disposeBag: DisposeBag)
        -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        observable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                guard case .completed(let edges, let pageInfo) = state else {
                    XCTFail("Invalid state")
                    return
                }

                XCTAssertEqual(edges, expectedEdges)
                XCTAssertEqual(pageInfo, expectedPageInfo)
                receivedCompletedStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedCompletedStateExpectation
    }

    private func expectError(
        observable: Observable<PageFetcherState<TestModel>>,
        disposedBy disposeBag: DisposeBag)
        -> XCTestExpectation
    {
        let receivedErrorStateExpectation = XCTestExpectation(description: "Received error state update")
        observable
            .skip(2)
            .take(1)
            .subscribe(onNext: { state in
                guard case .error(let wrappedError) = state else {
                    XCTFail("Invalid state")
                    return
                }

                print(wrappedError.error)
                receivedErrorStateExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        return receivedErrorStateExpectation
    }
}
