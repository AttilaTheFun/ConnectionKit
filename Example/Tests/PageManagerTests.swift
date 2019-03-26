@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PageManagerTests: XCTestCase {

    func testIsInitiallyEmpty() throws {

        // Create test data:
        let manager = PageManager<TestFetcher>()

        // Run test:
        XCTAssertEqual(manager.pages, [])
    }

    func testDropsEmptyPage() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 0)
        let manager = PageManager<TestFetcher>()

        // Run test:
        manager.ingest(edges: edges, from: .head)
        XCTAssertEqual(manager.pages, [])
        manager.ingest(edges: edges, from: .tail)
        XCTAssertEqual(manager.pages, [])
    }

    func testHasEmptyPagesAfterReset() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let manager = PageManager<TestFetcher>()

        // Run test:
        manager.ingest(edges: edges, from: .head)
        XCTAssertEqual(manager.pages.count, 1)
        manager.reset()
        XCTAssertEqual(manager.pages.count, 0)
    }

    func testInitialPageIndexIsAlwaysZero() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let manager = PageManager<TestFetcher>()

        // Run test:
        manager.ingest(edges: edges, from: .head)
        XCTAssertEqual(manager.pages.count, 1)
        XCTAssertEqual(manager.pages, [Page<TestFetcher>(index: 0, edges: edges)])

        manager.reset()
        XCTAssertEqual(manager.pages.count, 0)

        manager.ingest(edges: edges, from: .tail)
        XCTAssertEqual(manager.pages.count, 1)
        XCTAssertEqual(manager.pages, [Page<TestFetcher>(index: 0, edges: edges)])
    }

    func testHeadPageIndicesGoDown() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let manager = PageManager<TestFetcher>()

        // Run test:
        for i in 0..<5 {
            manager.ingest(edges: edges, from: .head)
            XCTAssertEqual(manager.pages.count, i + 1)

            let managerPages = manager.pages
            let ingestedPage = managerPages[managerPages.count - i - 1]
            let testPage = Page<TestFetcher>(index: -1 * i, edges: edges)

            XCTAssertEqual(ingestedPage, testPage)
        }
    }

    func testTailPageIndicesGoUp() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let manager = PageManager<TestFetcher>()

        // Run test:
        for i in 0..<5 {
            manager.ingest(edges: edges, from: .tail)
            XCTAssertEqual(manager.pages.count, i + 1)

            let managerPages = manager.pages
            let ingestedPage = managerPages[i]
            let testPage = Page<TestFetcher>(index: i, edges: edges)

            XCTAssertEqual(ingestedPage, testPage)
        }
    }

    func testAlternatingPages() throws {

        // Create test data:
        let edges: [TestEdge] = .create(count: 5)
        let manager = PageManager<TestFetcher>()

        // Insert initial page (initial end doesn't matter):
        manager.ingest(edges: edges, from: .head)
        XCTAssertEqual(manager.pages.count, 1)
        XCTAssertEqual(manager.pages, [Page<TestFetcher>(index: 0, edges: edges)])

        // Insert 10 alternating pages from the head and tail when index is even or odd respectively:
        var headPagesInserted = 0
        var tailPagesInserted = 0
        for i in 0..<10 {
            let end: End = i % 2 == 0 ? .head : .tail

            manager.ingest(edges: edges, from: end)
            XCTAssertEqual(manager.pages.count, i + 2)

            let pageIndex: Int
            let insertedPage: Page<TestFetcher>
            switch end {
            case .head:
                headPagesInserted += 1
                pageIndex = -1 * headPagesInserted
                insertedPage = manager.pages.first!
            case .tail:
                tailPagesInserted += 1
                pageIndex = tailPagesInserted
                insertedPage = manager.pages.last!
            }

            let testPage = Page<TestFetcher>(index: pageIndex, edges: edges)
            XCTAssertEqual(insertedPage, testPage)
        }
    }
}
