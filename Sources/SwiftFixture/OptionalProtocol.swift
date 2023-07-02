/// Internal protocol used to provide type information about `Optional` types at runtime.
protocol OptionalProtocol {
    /// `Optional<Wrapped>.none`
    static var nilValue: Self { get }

    /// Value of `Optional.Wrapped`
    static var wrappedType: Any.Type { get }
}

extension Optional: OptionalProtocol {
    static var nilValue: Optional<Wrapped> {
        return .none
    }

    static var wrappedType: Any.Type {
        Wrapped.self
    }
}
