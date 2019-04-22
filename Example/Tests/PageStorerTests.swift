@testable import ConnectionKit
import RxBlocking
import RxSwift
import XCTest

class PageStorerTests: XCTestCase {

    func testIsInitiallyEmpty() throws {

        // Create test data:
        let storer = PageStorer<TestModel>()

        // Run test:
        XCTAssertEqual(storer.pages, [])
    }

    func testDropsEmptyPage() throws {

        // Create test data:
        let edges: [Edge<TestModel>] = .create(count: 0)
        let storer = PageStorer<TestModel>()

        // Run test:
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages, [])
        storer.ingest(edges: edges, from: .tail)
        XCTAssertEqual(storer.pages, [])
    }

    func testInitialEdges() throws {

        // Create test data:
        let edges: [Edge<TestModel>] = .create(count: 5)
        let storer = PageStorer<TestModel>(initialEdges: edges)

        // Run test:
        XCTAssertEqual(storer.pages.count, 1)
        XCTAssertEqual(storer.pages, [Page<TestModel>(index: 0, edges: edges)])
    }

    func testHasEmptyPagesAfterReset() throws {

        // Create test data:
        let edges: [Edge<TestModel>] = .create(count: 5)
        let storer = PageStorer<TestModel>()

        // Run test:
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages.count, 1)
        storer.reset(to: [])
        XCTAssertEqual(storer.pages.count, 0)
    }

    func testInitialPageIndexIsAlwaysZero() throws {

        // Create test data:
        let edges: [Edge<TestModel>] = .create(count: 5)
        let storer = PageStorer<TestModel>()

        // Run test:
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages.count, 1)
        XCTAssertEqual(storer.pages, [Page<TestModel>(index: 0, edges: edges)])

        storer.reset(to: [])
        XCTAssertEqual(storer.pages.count, 0)

        storer.ingest(edges: edges, from: .tail)
        XCTAssertEqual(storer.pages.count, 1)
        XCTAssertEqual(storer.pages, [Page<TestModel>(index: 0, edges: edges)])
    }

    func testHeadPageIndicesGoUp() throws {

        // Create test data:
        let edges: [Edge<TestModel>] = .create(count: 5)
        let storer = PageStorer<TestModel>()

        // Run test:
        for i in 0..<5 {
            storer.ingest(edges: edges, from: .head)
            XCTAssertEqual(storer.pages.count, i + 1)

            let managerPages = storer.pages
            let ingestedPage = managerPages[i]
            let testPage = Page<TestModel>(index: i, edges: edges)

            XCTAssertEqual(ingestedPage, testPage)
        }
    }

    func testTailPageIndicesGoDown() throws {

        // Create test data:
        let edges: [Edge<TestModel>] = .create(count: 5)
        let storer = PageStorer<TestModel>()

        // Run test:
        for i in 0..<5 {
            storer.ingest(edges: edges, from: .tail)
            XCTAssertEqual(storer.pages.count, i + 1)

            let managerPages = storer.pages
            let ingestedPage = managerPages[managerPages.count - i - 1]
            let testPage = Page<TestModel>(index: -1 * i, edges: edges)

            XCTAssertEqual(ingestedPage, testPage)
        }
    }

    func testAlternatingPages() throws {

        // Create test data:
        let edges: [Edge<TestModel>] = .create(count: 5)
        let storer = PageStorer<TestModel>()

        // Insert initial page (initial end doesn't matter):
        storer.ingest(edges: edges, from: .head)
        XCTAssertEqual(storer.pages.count, 1)
        XCTAssertEqual(storer.pages, [Page<TestModel>(index: 0, edges: edges)])

        // Insert 10 alternating pages from the head and tail when index is even or odd respectively:
        var headPagesInserted = 0
        var tailPagesInserted = 0
        for i in 0..<10 {
            let end: End = i % 2 == 0 ? .head : .tail

            storer.ingest(edges: edges, from: end)
            XCTAssertEqual(storer.pages.count, i + 2)

            let pageIndex: Int
            let insertedPage: Page<TestModel>
            switch end {
            case .head:
                tailPagesInserted += 1
                pageIndex = tailPagesInserted
                insertedPage = storer.pages.last!
            case .tail:
                headPagesInserted += 1
                pageIndex = -1 * headPagesInserted
                insertedPage = storer.pages.first!
            }

            let testPage = Page<TestModel>(index: pageIndex, edges: edges)
            XCTAssertEqual(insertedPage, testPage)
        }
    }
}
