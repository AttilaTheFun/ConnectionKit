import ConnectionKit
import RxSwift
import XCTest

class TestFetcherTests: XCTestCase {
    func testEmptyConnection() {
        let testFetcher = TestFetcher(startIndex: 0, testData: TestData(nodes: []))
        let fetchObservable = testFetcher.fetch(first: 10, after: nil, last: nil, before: nil).tobo

        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
}
