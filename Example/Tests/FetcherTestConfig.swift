@testable import ConnectionKit

final class FetcherTestConfig {

    let testEdges: [TestEdge]
    let connectionEdges: [Edge<TestModel>]
    let models: [TestModel]
    let fetcher: TestFetcher

    init(edgeCount: Int) {
        self.testEdges = .create(count: edgeCount)
        self.connectionEdges = self.testEdges.map { Edge<TestModel>(node: TestParser.parse(node: $0.node), cursor: $0.cursor) }
        self.models = self.connectionEdges.map { $0.node }
        self.fetcher = TestFetcher(allEdges: self.testEdges)
    }
}
