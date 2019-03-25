
public struct Page<F> where F: ConnectionFetcher {
    public let index: Int
    public let edges: [Edge<F>]
}

extension Page: Equatable where
    F.FetchedConnection.ConnectedPageInfo : Equatable,
    F.FetchedConnection.ConnectedEdge: Equatable
{}

extension Page: Hashable where
    F.FetchedConnection.ConnectedPageInfo : Hashable,
    F.FetchedConnection.ConnectedEdge: Hashable
{}
