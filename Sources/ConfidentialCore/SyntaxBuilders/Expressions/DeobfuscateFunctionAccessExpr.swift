import SwiftSyntax
import SwiftSyntaxBuilder

struct DeobfuscateFunctionAccessExpr: ExprBuildable {

    private let deobfuscationStepInitializerExpr: ExpressibleAsExprBuildable
    private let dotIndentWidth: Int

    init(_ deobfuscationStepInitializerExpr: ExpressibleAsExprBuildable, dotIndentWidth: Int) {
        self.deobfuscationStepInitializerExpr = deobfuscationStepInitializerExpr
        self.dotIndentWidth = dotIndentWidth
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        self
    }

    func buildExpr(format: Format, leadingTrivia: Trivia?) -> ExprSyntax {
        makeUnderlyingExpr().buildExpr(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension DeobfuscateFunctionAccessExpr {

    static let deobfuscateFuncName: String = "deobfuscate"

    func makeUnderlyingExpr() -> ExprBuildable {
        MemberAccessExpr(
            base: deobfuscationStepInitializerExpr,
            dot: .period(
                leadingNewlines: 1,
                followedByLeadingSpaces: dotIndentWidth
            ),
            name: .identifier(Self.deobfuscateFuncName)
        )
    }
}
