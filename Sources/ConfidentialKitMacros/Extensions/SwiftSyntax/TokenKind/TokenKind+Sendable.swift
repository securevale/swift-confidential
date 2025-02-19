import SwiftSyntax

#if !canImport(SwiftSyntax600)
extension TokenKind: @unchecked Swift.Sendable {}
#endif
