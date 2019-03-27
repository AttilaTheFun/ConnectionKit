@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PageStorerTests: XCTestCase {

    func testIsInitiallyEmpty() throws {

        // Create test data:
        let storer = PageStorer<TestFetcher>()

        // Run test:
        XCTAssertEqual(storer.pages, [])
    }

    func testDropsEmptyPage() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 0)
        let storer = PageStorer<TestFetcher>()

        // Run test:
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages, [])
        storer.ingest(edges: edges, from: .tail)
        XCTAssertEqual(storer.pages, [])
    }

    func testHasEmptyPagesAfterReset() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let storer = PageStorer<TestFetcher>()

        // Run test:
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages.count, 1)
        storer.reset()
        XCTAssertEqual(storer.pages.count, 0)
    }

    func testInitialPageIndexIsAlwaysZero() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let storer = PageStorer<TestFetcher>()

        // Run test:
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages.count, 1)
        XCTAssertEqual(storer.pages, [Page<TestFetcher>(index: 0, edges: edges)])

        storer.reset()
        XCTAssertEqual(storer.pages.count, 0)

        storer.ingest(edges: edges, from: .tail)
        XCTAssertEqual(storer.pages.count, 1)
        XCTAssertEqual(storer.pages, [Page<TestFetcher>(index: 0, edges: edges)])
    }

    func testHeadPageIndicesGoDown() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let storer = PageStorer<TestFetcher>()

        // Run test:
        for i in 0..<5 {
            storer.ingest(edges: edges, from: .head)
            XCTAssertEqual(storer.pages.count, i + 1)

            let managerPages = storer.pages
            let ingestedPage = managerPages[managerPages.count - i - 1]
            let testPage = Page<TestFetcher>(index: -1 * i, edges: edges)

            XCTAssertEqual(ingestedPage, testPage)
        }
    }

    func testTailPageIndicesGoUp() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let storer = PageStorer<TestFetcher>()

        // Run test:
        for i in 0..<5 {
            storer.ingest(edges: edges, from: .tail)
            XCTAssertEqual(storer.pages.count, i + 1)

            let managerPages = storer.pages
            let ingestedPage = managerPages[i]
            let testPage = Page<TestFetcher>(index: i, edges: edges)

            XCTAssertEqual(ingestedPage, testPage)
        }
    }

    func testAlternatingPages() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let storer = PageStorer<TestFetcher>()

        // Insert initial page (initial end doesn't matter):
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages.count, 1)
        XCTAssertEqual(storer.pages, [Page<TestFetcher>(index: 0, edges: edges)])

        // Insert 10 alternating pages from the head and tail when index is even or odd respectively:
        var headPagesInserted = 0
        var tailPagesInserted = 0
        for i in 0..<10 {
            let end: End = i % 2 == 0 ? .head : .tail

            storer.ingest(edges: edges, from: end)
            XCTAssertEqual(storer.pages.count, i + 2)

            let pageIndex: Int
            let insertedPage: Page<TestFetcher>
            switch end {
            case .head:
                headPagesInserted += 1
                pageIndex = -1 * headPagesInserted
                insertedPage = storer.pages.first!
            case .tail:
                tailPagesInserted += 1
                pageIndex = tailPagesInserted
                insertedPage = storer.pages.last!
            }

            let testPage = Page<TestFetcher>(index: pageIndex, edges: edges)
            XCTAssertEqual(insertedPage, testPage)
        }
    }
}
