import ConnectionKit

enum TestParser: ModelParser {
    static func parse(node: TestNode) -> TestModel {
        return TestModel(id: node.id, createdAt: node.createdAt)
    }
}
