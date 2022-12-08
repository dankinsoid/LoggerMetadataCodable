import Foundation
import SimpleCoders
import Logging

public struct LoggerMetadataDecoder: CodableDecoder {
   
    public typealias Input = Logger.Metadata.Value
    
    public var dateDecodingStrategy: AnyDecodingStrategy<Date>
    public var keyDecodingStrategy: ((CodingKey, [CodingKey]) throws -> String)?
    
    public init() {
        self.dateDecodingStrategy = AnyDecodingStrategy(.defferedToDate)
    }
    
    public init(
        dateDecodingStrategy: some DateDecodingStrategy,
        keyDecodingStrategy: some KeyEncodingStrategy
    ) {
        self.dateDecodingStrategy = AnyDecodingStrategy(dateDecodingStrategy)
        self.keyDecodingStrategy = keyDecodingStrategy.encode
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Logger.Metadata.Value) throws -> T {
        try Unboxer(input: data, decoder: self).decode(type)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Logger.Metadata) throws -> T {
        try decode(type, from: .dictionary(data))
    }
}

private extension LoggerMetadataDecoder {
    
    struct Unboxer: DecodingUnboxer {
        
        typealias Input = Logger.Metadata.Value
        
        var input: Input
        var codingPath: [CodingKey]
        var decoder: LoggerMetadataDecoder
        
        init(
            input: Input,
            path: [CodingKey],
            other unboxer: LoggerMetadataDecoder.Unboxer
        ) {
            self.input = input
            codingPath = path
            self.decoder = unboxer.decoder
        }
        
        init(input: Input, decoder: LoggerMetadataDecoder) {
            self.decoder = decoder
            codingPath = []
            self.input = input
        }
        
        func decodeNil() -> Bool {
            switch input {
            case .string("nil"), .string("NULL"), .string("null"), .string("undefined"):
                return true
            default:
                return false
            }
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            let string = try decode(String.self)
            switch string.lowercased() {
            case "true", "1", "yes":
                return true
            case "false", "0", "no":
                return false
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid boolean \(string)")
                )
            }
        }
        
        func decode(_ type: String.Type) throws -> String {
            switch input {
            case let .string(string):
                return string
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: codingPath, debugDescription: "Expected string but \(input.description) found")
                )
            }
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            guard let double = try Double(decode(String.self)) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: codingPath, debugDescription: "Expected floating point but \(input.description) found")
                )
            }
            return double
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            guard let double = try Int(decode(String.self)) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: codingPath, debugDescription: "Expected integer but \(input.description) found")
                )
            }
            return double
        }
        
        func decode(_ type: Decimal.Type) throws -> Decimal {
            guard let double = try Decimal(string: decode(String.self)) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: codingPath, debugDescription: "Expected decimal but \(input.description) found")
                )
            }
            return double
        }
        
        func decodeArray() throws -> [Input] {
            switch input {
            case let .array(array):
                return array  default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: codingPath, debugDescription: "Expected array but \(input.description) found")
                )
            }
        }
        
        func decodeDictionary() throws -> [String: Input] {
            switch input {
            case let .dictionary(dictionary):
                guard let keyStrategy = decoder.keyDecodingStrategy else {
                    return dictionary
                }
                return try Dictionary(
                    dictionary.map {
                        try (keyStrategy(PlainCodingKey($0.key), codingPath), $0.value)
                    }
                ) { _, second in
                    second
                }
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: codingPath, debugDescription: "Expected dictionary but \(input.description) found")
                )
            }
        }
        
        func contains(key: String) -> Bool {
            switch input {
            case let .dictionary(dictionary):
                let key = (try? decoder.keyDecodingStrategy?(PlainCodingKey(key), codingPath)) ?? key
                return dictionary.keys.contains(key)
            default:
                return false
            }
        }
        
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            if type == Decimal.self {
                let decimal = try decode(Decimal.self)
                guard let result = decimal as? T else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(codingPath: codingPath, debugDescription: "Expected Decimal")
                    )
                }
                return result
            }
            if type == Date.self {
                let date = try decoder.dateDecodingStrategy.decode(from: VDDecoder(unboxer: self))
                guard let result = date as? T else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(codingPath: codingPath, debugDescription: "Expected Date")
                    )
                }
                return result
            }
            return try T(from: VDDecoder(unboxer: self))
        }
    }
}
