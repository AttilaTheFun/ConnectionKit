
public enum End: Hashable {
    /**
     The head end of the connection.
     Typically for chronological data this is the most recent end.
     Fetches from this end will use the `first` and `after` parameters per the relay cursor spec.
     */
    case head

    /**
     The tail (oldest) end of the connection.
     Typically for chronological data this is the oldest recent end.
     Fetches from this end will use the `last` and `before` parameters per the relay cursor spec.
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
