
/**
 The type of the page fetcher.
 */
enum PageFetcherType {
    case initial
    case head
    case tail
}

extension PageFetcherType {
    init(end: End) {
        switch end {
        case .head:
            self = .head
        case .tail:
            self = .tail
        }
    }
}
