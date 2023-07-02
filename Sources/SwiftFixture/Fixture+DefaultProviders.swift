import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

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
        register(Date.self) { Date(timeIntervalSinceReferenceDate: .random(in: 0 ... Date().timeIntervalSinceReferenceDate)) }

        #if canImport(CoreGraphics)
        register(CGFloat.self) { .random(in: 0 ... 2048) }
        register(CGPoint.self) { values in
            CGPoint(
                x: try values.get("x") as CGFloat,
                y: try values.get("y") as CGFloat
            )
        }
        register(CGSize.self) { values in
            CGSize(
                width: try values.get("width") as CGFloat,
                height: try values.get("height") as CGFloat
            )
        }
        register(CGRect.self) { values in
            CGRect(
                x: try values.get("x") as CGFloat,
                y: try values.get("y") as CGFloat,
                width: try values.get("width") as CGFloat,
                height: try values.get("height") as CGFloat
            )
        }
        register(CGVector.self) { values in
            CGVector(
                dx: try values.get("dx") as CGFloat,
                dy: try values.get("dy") as CGFloat
            )
        }
        #endif
    }
}
