
struct PageInfo: Hashable {
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

extension PageInfo {
    init<P>(connectionPageInfo: P) where P: ConnectionPageInfo {
        self.hasNextPage = connectionPageInfo.hasNextPage
        self.hasPreviousPage = connectionPageInfo.hasPreviousPage
    }
}
