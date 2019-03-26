
/**
 Encapsulates the possible states of an end of a connection (head or tail).
 The initial state is hasNextPage.
 The possible transitions are:
 - hasNextPage -> isFetchingNextPage
 - isFetchingNextPage -> hasNextPage
 - isFetchingNextPage -> hasFetchedLastPage
 - isFetchingNextPage -> failedToFetchNextPage
 - failedToFetchNextPage -> isFetchingNextPage
 All states could revert to hasNextPage if the connection was reset.
 */
public enum EndState: Hashable {
    // The manager has another page available from this end.
    case hasNextPage

    // The manager is actively the next page from this end.
    case isFetchingNextPage

    // The manager has fetched the last page available from this end.
    case hasFetchedLastPage

    // The manager failed to fetch a page from this end.
    case failedToFetchNextPage(ErrorWrapper)
}
