import SwiftSyntax

extension TokenSyntax {

    var isWildcardToken: Bool { tokenKind == .wildcard }
}
