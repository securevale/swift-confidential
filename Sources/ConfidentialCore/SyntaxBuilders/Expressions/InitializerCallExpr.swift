import SwiftSyntax
import SwiftSyntaxBuilder

struct InitializerCallExpr: ExprBuildable {

    private let argumentList: ExpressibleAsTupleExprElementList

    init(
        @TupleExprElementListBuilder argumentListBuilder: () -> ExpressibleAsTupleExprElementList = {
            TupleExprElementList([])
        }
    ) {
        self.argumentList = argumentListBuilder()
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        self
    }

    func buildExpr(format: Format, leadingTrivia: Trivia?) -> ExprSyntax {
        makeUnderlyingExpr().buildExpr(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension InitializerCallExpr {

    func makeUnderlyingExpr() -> ExprBuildable {
        FunctionCallExpr(
            calledExpression: MemberAccessExpr(dot: .period, name: .`init`.withoutTrivia()),
            leftParen: .leftParen,
            argumentList: argumentList,
            rightParen: .rightParen
        )
    }
}
