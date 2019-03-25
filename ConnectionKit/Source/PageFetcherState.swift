
/**
 Encapsulates the possible states of a page fetcher.
 The initial state is idle.
 The possible transitions are:
 - idle -> fetching
 - fetching -> complete
 - fetching -> error
 - error -> fetching
 */
enum PageFetcherState<F> where F: ConnectionFetcher {
    // The fetcher has not started fetching a page.
    case idle

    // The fetcher is actively fetching a page.
    case fetching

    // The fetcher completed fetching a page.
    case complete(Edges<F>, PageInfo<F>)

    // The fetcher failed to fetch a page.
    case error(Error)
}
