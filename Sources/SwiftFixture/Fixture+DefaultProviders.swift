import Foundation

extension Fixture {
    func registerDefaults(using preferredFormat: PreferredFormat) {
        switch preferredFormat {
        case .random:
            registerRandomDefaults()
        case .constant:
            registerConstantDefaults()
        }
    }

    // TODO: Conditionally support other common types, such as CGFloat from CoreGraphics

    private func registerRandomDefaults() {
        // Standard Library
        register(Int.self)       { .random(in: 0 ... .max) }
        register(Int8.self)      { .random(in: 0 ... .max) }
        register(Int16.self)     { .random(in: 0 ... .max) }
        register(Int32.self)     { .random(in: 0 ... .max) }
        register(Int64.self)     { .random(in: 0 ... .max) }
        register(UInt.self)      { .random(in: 0 ... .max) }
        register(UInt8.self)     { .random(in: 0 ... .max) }
        register(UInt16.self)    { .random(in: 0 ... .max) }
        register(UInt32.self)    { .random(in: 0 ... .max) }
        register(UInt64.self)    { .random(in: 0 ... .max) }
        register(Float.self)     { .random(in: 0 ... .greatestFiniteMagnitude) }
        register(Double.self)    { .random(in: 0 ... .greatestFiniteMagnitude) }
        register(Bool.self)      { .random() }
        register(String.self)    { UUID().uuidString.lowercased() } 
        register(Character.self) { UUID().uuidString.first! }

        // Foundation
        register(UUID.self) { UUID() }
        register(URL.self)  { URL(string: "https://www.\(UUID().uuidString.lowercased()).com/")! }
        register(Date.self) { Date(timeIntervalSinceReferenceDate: TimeInterval.random(in: 0 ... Date().timeIntervalSinceReferenceDate)) }
    }

    private func registerConstantDefaults() {
        // Standard Library
        register(Int.self)       { 0 }
        register(Int8.self)      { 0 }
        register(Int16.self)     { 0 }
        register(Int32.self)     { 0 }
        register(Int64.self)     { 0 }
        register(UInt.self)      { 0 }
        register(UInt8.self)     { 0 }
        register(UInt16.self)    { 0 }
        register(UInt32.self)    { 0 }
        register(UInt64.self)    { 0 }
        register(Float.self)     { 0.0 }
        register(Double.self)    { 0.0 }
        register(Bool.self)      { false }
        register(String.self)    { "" }
        register(Character.self) { Character("") }

        // Foundation
        register(UUID.self) { UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")! }
        register(URL.self)  { URL(string: "https://www.example.com/")! }
        register(Date.self) { Date(timeIntervalSinceReferenceDate: 0) }
    }
}
