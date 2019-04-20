
/**
 Because Swift's generic Error type is not required to be hashable, this breaks hashability for objects that might
 want to wrap one. This wrapper implements Hashable and Equatable using the error's localizedDescription value.
 */
public struct ErrorWrapper {
    public let error: Error

    public init(error: Error) {
        self.error = error
    }
}

extension ErrorWrapper: Equatable {
    public static func == (lhs: ErrorWrapper, rhs: ErrorWrapper) -> Bool {
        return lhs.error.localizedDescription == rhs.error.localizedDescription
    }
}

extension ErrorWrapper: Hashable {
    public func hash(into hasher: inout Hasher) {
        self.error.localizedDescription.hash(into: &hasher)
    }
}
