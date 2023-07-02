import Foundation

extension Fixture {
    func registerDefaultProviders() {
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
        register(Data.self)      { Data((0 ..< 16).map({ _ in UInt8.random(in: .min ... .max) })) }

        // Foundation
        register(UUID.self) { UUID() }
        register(URL.self)  { URL(string: "https://www.\(UUID().uuidString.lowercased()).com/")! }
        register(Date.self) { Date(timeIntervalSinceReferenceDate: TimeInterval.random(in: 0 ... Date().timeIntervalSinceReferenceDate)) }
    }
}
