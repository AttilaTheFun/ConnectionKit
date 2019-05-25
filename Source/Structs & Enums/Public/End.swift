
public enum End: Hashable {
    /**
     The head end of the connection.
     For chronological data this is oldest end.
     Fetches from this end will use the `first` and `after` parameters per the relay cursor spec.

     Example:
     head -> [1, 2, 3, 4, 5]
     */
    case head

    /**
     The tail end of the connection.
     For chronological data this is the newest end.
     Fetches from this end will use the `last` and `before` parameters per the relay cursor spec.

     Example:
     [1, 2, 3, 4, 5] <- tail
     */
    case tail
}

extension End {
    var opposite: End {
        switch self {
        case .head:
            return .tail
        case .tail:
            return .head
        }
    }
}
