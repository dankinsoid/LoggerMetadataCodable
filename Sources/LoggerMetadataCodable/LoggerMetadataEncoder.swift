import Foundation
import SimpleCoders
import Logging

public struct LoggerMetadataEncoder: CodableEncoder {
    
    public typealias Output = Logger.Metadata.Value
    
    public var values: LoggerMetadataCodableConstants
    public var dateEncodingStrategy: AnyEncodingStrategy<Date>
    public var keyEncodingStrategy: ((CodingKey, [CodingKey]) throws -> String)?
    
    public init(
        values: LoggerMetadataCodableConstants,
        dateEncodingStrategy: some DateEncodingStrategy,
        keyEncodingStrategy: some KeyEncodingStrategy
    ) {
        self.values = values
        self.dateEncodingStrategy = AnyEncodingStrategy(dateEncodingStrategy)
        self.keyEncodingStrategy = keyEncodingStrategy.encode
    }
    
    public init() {
        self.values = .default
        self.dateEncodingStrategy = AnyEncodingStrategy(.defferedToDate)
        self.keyEncodingStrategy = nil
    }
    
    public func encode(_ value: some Encodable) throws -> Logger.Metadata.Value {
        try Boxer(encoder: self).encode(value: value)
    }
    
    public func encode(_ value: some Encodable) throws -> Logger.Metadata {
        let value: Logger.Metadata.Value = try encode(value)
        switch value {
        case let .dictionary(dictionary):
            return dictionary
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Expected metadata dictionary but found \"\(value.description)\"")
            )
        }
    }
}

public extension Logger.Metadata {
    
    static func encode<T: Encodable>(_ value: T) throws -> Logger.Metadata {
        try LoggerMetadataEncoder().encode(value)
    }
}

private extension LoggerMetadataEncoder {
    
    struct Boxer: EncodingBoxer {
        
        typealias Output = Logger.Metadata.Value
        
        var codingPath: [CodingKey]
        var encoder: LoggerMetadataEncoder
        
        init(encoder: LoggerMetadataEncoder) {
            codingPath = []
            self.encoder = encoder
        }
        
        init(path: [CodingKey], other boxer: LoggerMetadataEncoder.Boxer) {
            codingPath = path
            encoder = boxer.encoder
        }
        
        func encodeNil() throws -> Output {
            .string(encoder.values.nil)
        }
        
        func encode(_ value: Bool) throws -> Output {
            .string(value ? encoder.values.true : encoder.values.false)
        }
        
        func encode(_ value: String) throws -> Output {
            .string(value)
        }
        
        func encode(_ value: Double) throws -> Output {
            .string("\(value)")
        }
        
        func encode(_ value: Int) throws -> Output {
            .string("\(value)")
        }
        
        func encode(_ value: Decimal) throws -> Output {
            .string("\(value)")
        }
        
        func encode<T: Encodable>(value: T) throws -> Output {
            if let decimal = value as? Decimal {
               return try encode(decimal)
            }
            var encoder = VDEncoder(boxer: self)
            if let date = value as? Date {
                try self.encoder.dateEncodingStrategy.encode(date, to: encoder)
            } else {
                try value.encode(to: encoder)
            }
            return try encoder.get()
        }
        
        func encode(_ array: [Output]) throws -> Output {
            .array(array)
        }
        
        func encode(_ dictionary: [String: Output]) throws -> Output {
            guard let keyEncodingStrategy = encoder.keyEncodingStrategy else {
                return .dictionary(dictionary)
            }
            return try .dictionary(
                Dictionary(
                    dictionary.map {
                        try (keyEncodingStrategy(PlainCodingKey($0.key), codingPath), $0.value)
                    }
                ) { _, second in
                    second
                }
            )
        }
    }
}
