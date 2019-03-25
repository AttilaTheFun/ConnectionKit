
/**
 Encapsulates the possible states of an end of a connection (head or tail).
 The initial state is idle.
 The possible transitions are:
 - idle -> fetching
 - fetching -> idle
 - fetching -> error
 - error -> fetching
 All states could revert to idle if the connection was reset.
 */
enum EndState {
    // The end has not started fetching a page.
    case idle

    // The end is actively fetching a page.
    case fetching

    // The end failed to fetch a page.
    case error(Error)
}
