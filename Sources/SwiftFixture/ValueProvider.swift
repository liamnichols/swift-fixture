import Foundation

public class ValueProvider {
    private let fixture: Fixture
    private let overrides: [String: Any]
    private let targetType: Any.Type
    private var consumedOverrides: Set<String> = []

    init(fixture: Fixture, overrides: [String: Any], targetType: Any.Type) {
        self.fixture = fixture
        self.overrides = overrides
        self.targetType = targetType
    }

    public func value<T>(labelled label: String? = nil) throws -> T {
        // If an override was provided for the requested argument, try and use it
        if let label, let override = overrides[label] {
            if let value = override as? T {
                consumedOverrides.insert(label)
                return value
            } else {
                throw ResolutionError.overrideTypeMismatch(label, override, T.self)
            }
        }

        // Otherwise use the fixture value directly
        return try fixture.value(for: T.self, overrides: [:])
    }

    func ensureOverridesConsumed() throws {
        let unusedOverrides = Set(overrides.keys).subtracting(consumedOverrides)
        if let first = unusedOverrides.first {
            throw ResolutionError.unusedOverride(first, targetType)
        }
    }
}
