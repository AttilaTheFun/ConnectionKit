@testable import ConnectionKit

final class FetcherTestConfig {

    let defaultIndex: Int
    let testEdges: [TestEdge]
    let connectionEdges: [Edge<TestModel>]
    let models: [TestModel]
    let fetcher: TestFetcher

    init(defaultIndex: Int, edgeCount: Int) {
        self.testEdges = .create(count: edgeCount)
        self.connectionEdges = self.testEdges.map { Edge<TestModel>(node: TestParser.parse(node: $0.node), cursor: $0.cursor) }
        self.models = self.connectionEdges.map { $0.node }
        self.defaultIndex = defaultIndex
        self.fetcher = TestFetcher(defaultIndex: defaultIndex, edges: self.testEdges)
    }
}
