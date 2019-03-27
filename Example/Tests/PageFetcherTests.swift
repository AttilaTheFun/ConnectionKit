@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PageFetcherTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func tearDown() {
        super.tearDown()

        // Wipe out all disposables:
        self.disposeBag = DisposeBag()
    }

    func testEmptyConnection() throws {
        // Create test data:
        let startIndex = 0
        let edges: [TestEdge] = .create(count: 0)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(defaultIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: false)
        let expectedEdges = edges

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testIncompletePageForward() throws {
        // Create test data:
        let startIndex = 2
        let edges: [TestEdge] = .create(count: 5)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(defaultIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(edges[2...])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testIncompletePageBackward() throws {
        // Create test data:
        let startIndex = 2
        let edges: [TestEdge] = .create(count: 5)
        let config = FetchConfig(last: 10)
        let fetcher = TestFetcher(defaultIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: false, hasPreviousPage: true)
        let expectedEdges = Array(edges[0..<2])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testCompletePageForward() throws {
        // Create test data:
        let startIndex = 50
        let edges: [TestEdge] = .create(count: 100)
        let config = FetchConfig(first: 10)
        let fetcher = TestFetcher(defaultIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let expectedEdges = Array(edges[50..<60])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo:
            expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }

    func testCompletePageBackward() throws {
        // Create test data:
        let startIndex = 50
        let edges: [TestEdge] = .create(count: 100)
        let config = FetchConfig(last: 10)
        let fetcher = TestFetcher(defaultIndex: startIndex, edges: edges)
        let expectedPageInfo = TestPageInfo(hasNextPage: true, hasPreviousPage: true)
        let expectedEdges = Array(edges[40..<50])

        // Run test:
        try self.runTest(
            fetcher: fetcher,
            config: config,
            expectedPageInfo: expectedPageInfo,
            expectedEdges: expectedEdges
        )
    }
}

// MARK: Private Utils

extension PageFetcherTests {
    private func runTest(fetcher: TestFetcher,
                         config: FetchConfig,
                         expectedPageInfo: TestPageInfo,
                         expectedEdges: [TestEdge]) throws
    {
        // Create fetcher:
        let pageFetcher = PageFetcher<TestFetcher>(fetchablePage: {
            return fetcher.fetch(config: config)
        })

        // Create expectations:
        let expectations = [
            self.expectIdle(pageFetcher),
            self.expectFetching(pageFetcher),
            self.expectCompleted(pageFetcher, expectedEdges: expectedEdges, expectedPageInfo: expectedPageInfo)
        ]

        // Run the test:
        pageFetcher.fetchPage()

        // Wait for expectations:
        wait(for: expectations, timeout: 1)
    }

    private func expectIdle(_ fetcher: PageFetcher<TestFetcher>) -> XCTestExpectation {
        let receivedIdleStateExpectation = XCTestExpectation(description: "Received idle state update")
        fetcher.stateObservable
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, PageFetcherState<TestFetcher>.idle)
                receivedIdleStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        return receivedIdleStateExpectation
    }

    private func expectFetching(_ fetcher: PageFetcher<TestFetcher>) -> XCTestExpectation {
        let receivedFetchingStateExpectation = XCTestExpectation(description: "Received fetching state update")
        fetcher.stateObservable
            .skip(1)
            .take(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, PageFetcherState<TestFetcher>.fetching)
                receivedFetchingStateExpectation.fulfill()
            })
            .disposed(by: self.disposeBag)

        return receivedFetchingStateExpectation
    }

    private func expectCompleted(
        _ fetcher: PageFetcher<TestFetcher>,
        expectedEdges: [TestEdge],
        expectedPageInfo: TestPageInfo) -> XCTestExpectation
    {
        let receivedCompletedStateExpectation = XCTestExpectation(description: "Received completed state update")
        fetcher.stateObservable
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
            .disposed(by: self.disposeBag)

        return receivedCompletedStateExpectation
    }

    private func expectError(_ fetcher: PageFetcher<TestFetcher>) -> XCTestExpectation {
        let receivedErrorStateExpectation = XCTestExpectation(description: "Received error state update")
        fetcher.stateObservable
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
            .disposed(by: self.disposeBag)

        return receivedErrorStateExpectation
    }
}
