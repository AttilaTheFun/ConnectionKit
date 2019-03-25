import ConnectionKit

struct TestNode: Equatable {
    let id: String
    let createdAt: Date
}

struct TestEdge: Equatable, ConnectionEdge {
    let cursor: String
    let node: TestNode
}

extension TestEdge {
    init(node: TestNode) {
        self.cursor = node.id
        self.node = node
    }
}

struct TestPageInfo: Equatable, ConnectionPageInfo {
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

struct TestConnection: Equatable, ConnectionProtocol {
    let pageInfo: TestPageInfo
    let edges: [TestEdge]
}

