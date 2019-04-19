
public struct InitialConnectionState<Connection> where Connection: ConnectionProtocol {
    let connection: Connection
    let end: End

    public init(connection: Connection, fetchedFrom end: End) {
        self.connection = connection
        self.end = end
    }
}
