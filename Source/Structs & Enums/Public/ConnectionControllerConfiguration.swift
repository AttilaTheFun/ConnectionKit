
public struct ConnectionControllerConfiguration<Fetcher, Storer>
    where Fetcher: ConnectionFetcherProtocol, Storer: EdgeStorable
{
    public let fetcher: Fetcher
    public let storerType: Storer.Type
    public let initialPageSize: Int
    public let paginationPageSize: Int

    public init(fetcher: Fetcher, storerType: Storer.Type, initialPageSize: Int, paginationPageSize: Int) {
        self.fetcher = fetcher
        self.storerType = storerType
        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
    }
}
