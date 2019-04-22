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
        let configuration = ConnectionControllerConfiguration(
            fetcher: self.fetcherTestConfig.fetcher,
            parser: TestParser.self,
            initialPageSize: self.initialPageSize,
            paginationPageSize: self.paginationPageSize
        )
        self.controller = ConnectionController(configuration: configuration)
    }
}
