import Foundation

struct TestData {
    let nodes: [TestNode]

    init(nodes: [TestNode] = TestData.createNodes(count: 100)) {
        self.nodes = nodes
    }
}

extension TestData {

    /**
     Creates `count` test nodes with ascending ids from 0 to `count` - 1.
     The nodes have fake, ascending creation times which are 60s apart starting from the current time.
     */
    static func createNodes(count: Int) -> [TestNode] {
        let startDate = Date()

        var nodes = [TestNode]()
        nodes.reserveCapacity(count)
        for i in 0..<count {
            nodes.append(TestNode(id: String(i), createdAt: startDate.addingTimeInterval(TimeInterval(i) * 60)))
        }

        return nodes
    }
}

