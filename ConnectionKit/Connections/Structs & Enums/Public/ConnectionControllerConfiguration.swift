
public struct ConnectionControllerConfiguration<Fetcher> where Fetcher: ConnectionFetcherProtocol {
    public let fetcher: Fetcher
    public let initialPageSize: Int
    public let paginationPageSize: Int

    public init(fetcher: Fetcher, initialPageSize: Int, paginationPageSize: Int) {
        self.fetcher = fetcher
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
    }
}
