import ConnectionKit

struct TestModel: Hashable {
    let id: String
    let createdAt: Date
}

extension TestModel {
    init(testNode: TestNode) {
        self.id = testNode.id
        self.createdAt = testNode.createdAt
    }
}

struct TestNode: Hashable {
    let id: String
    let createdAt: Date
}

struct TestEdge: Hashable, ConnectionEdge {
    let cursor: String
    let node: TestNode
}

extension TestEdge {
    init(node: TestNode) {
        self.cursor = node.id
        self.node = node
    }
}

struct TestPageInfo: Hashable, ConnectionPageInfo {
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

struct TestConnection: Hashable, ConnectionProtocol {
    let pageInfo: TestPageInfo
    let edges: [TestEdge]
}

struct FetchConfig: Hashable {
    let end: End
    let limit: Int
    let cursor: String?

    init(first: Int, after: String? = nil) {
        self.end = .head
        self.limit = first
        self.cursor = after
    }

    init(last: Int, before: String? = nil) {
        self.end = .tail
        self.limit = last
        self.cursor = before
    }
}
