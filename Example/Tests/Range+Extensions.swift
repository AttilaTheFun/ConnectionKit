
/**
 Bound a comparable value between an upper and lower bound.
 */
public func bound<C: Comparable>(value: C, low: C, high: C) -> C {
    return min(max(value, low), high)
}

extension Range {
    static func bounded(low: Bound, high: Bound, lowest: Bound, highest: Bound) -> Range<Bound> {
        let boundedLow = bound(value: low, low: lowest, high: highest)
        let boundedHigh = bound(value: high, low: lowest, high: highest)
        if boundedLow > boundedHigh {
            return self.bounded(low: boundedHigh, high: boundedLow, lowest: lowest, highest: highest)
        }

        return boundedLow..<boundedHigh
    }
}


