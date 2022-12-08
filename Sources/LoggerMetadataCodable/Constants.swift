import Foundation

typealias Constants = LoggerMetadataCodableConstants

public struct LoggerMetadataCodableConstants {
    
    public static var `default` = LoggerMetadataCodableConstants()
    
    public var `true`: String
    public var `false`: String
    public var `nan`: String
    public var `nil`: String
    public var infinity: String
    
    public init(
        true: String = "true",
        false: String = "false",
        nan: String = "nan",
        nil: String = "nil",
        infinity: String = "inf"
    ) {
        self.true = `true`
        self.false = `false`
        self.nan = nan
        self.nil = `nil`
        self.infinity = infinity
    }
}
