import SwiftSyntax

extension MemberAccessExprSyntax {

    private static let deobfuscateFuncName: String = "deobfuscate"

    static func makeDeobfuscateFunctionAccessExpr(
        _ deobfuscationStepInitializerExpr: some ExprSyntaxProtocol,
        dotIndentWidth: Int
    ) -> Self {
        .init(
            base: deobfuscationStepInitializerExpr,
            period: .periodToken(
                leadingNewlines: 1,
                followedByLeadingSpaces: dotIndentWidth
            ),
            declName: .init(baseName: .identifier(Self.deobfuscateFuncName))
        )
    }
}
