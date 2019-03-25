
protocol ConnectionProtocol {
    associatedtype ConnectedEdge: ConnectionEdge
    associatedtype ConnectedPageInfo: ConnectionPageInfo
    var pageInfo: ConnectedPageInfo { get }
    var edges: [ConnectedEdge] { get }
}
