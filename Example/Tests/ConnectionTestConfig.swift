@testable import ConnectionKit

final class ConnectionTestConfig {

    let initialPageSize: Int
    let paginationPageSize: Int
    let fetcherTestConfig: FetcherTestConfig
    let controller: ConnectionController<TestFetcher, TestParser>

    init(
        initialPageSize: Int,
        paginationPageSize: Int,
        edgeCount: Int)
    {

        self.initialPageSize = initialPageSize
        self.paginationPageSize = paginationPageSize
        self.fetcherTestConfig = FetcherTestConfig(edgeCount: edgeCount)
        self.controller = ConnectionController(
            fetcher: self.fetcherTestConfig.fetcher,
            parser: TestParser.self,
            initialPageSize: self.initialPageSize,
            paginationPageSize: self.paginationPageSize
        )
    }
}
