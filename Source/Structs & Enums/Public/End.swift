
public enum End: Hashable {
    /**
     The head end of the connection.
     For chronological data this is oldest end.
     Fetches from this end will use the `first` and `after` parameters per the relay cursor spec.

     Example:
     head -> [1, 2, 3, 4, 5, 6, 7, 8]

     first: 2
     [1, 2]

     first: 2 after: cursor(2)
     [3, 4]
     */
    case head

    /**
     The tail end of the connection.
     For chronological data this is the newest end.
     Fetches from this end will use the `last` and `before` parameters per the relay cursor spec.

     Example:
     [1, 2, 3, 4, 5, 6, 7, 8] <- tail

     last: 2
     [7, 8]

     last: 2 before: cursor(7)
     [5, 6]
     */
    case tail
}

extension End {
    public var opposite: End {
        switch self {
        case .head:
            return .tail
        case .tail:
            return .head
        }
    }
}
