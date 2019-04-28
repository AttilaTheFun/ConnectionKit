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
    let first: Int?
    let after: String?
    let last: Int?
    let before: String?

    init(first: Int, after: String? = nil) {
        self.first = first
        self.after = after
        self.last = nil
        self.before = nil
    }

    init(last: Int, before: String? = nil) {
        self.first = nil
        self.after = nil
        self.last = last
        self.before = before
    }
}
