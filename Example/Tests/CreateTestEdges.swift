import Foundation

extension Array where Element == TestEdge {

    /**
     Creates `count` test edges.
     Each edge has a node with ascending ids from 0 to `count` - 1.
     The nodes have fake, ascending creation times which are 60s apart starting from the current time.
     The edges cursors are equal to the nodes' ids.
     */
    static func create(count: Int) -> [TestEdge] {
        let startDate = Date()

        var edges = [TestEdge]()
        edges.reserveCapacity(count)
        for i in 0..<count {
            let node = TestNode(id: String(i), createdAt: startDate.addingTimeInterval(TimeInterval(i) * 60))
            edges.append(TestEdge(node: node))
        }

        return edges
    }
}

