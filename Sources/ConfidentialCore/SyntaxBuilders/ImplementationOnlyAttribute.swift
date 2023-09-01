import SwiftSyntax
import SwiftSyntaxBuilder

struct ImplementationOnlyAttribute: SyntaxBuildable, ExpressibleAsAttribute {

    private let leadingTrivia: Trivia?

    init(leadingTrivia: Trivia? = .none) {
        self.leadingTrivia = leadingTrivia
    }

    func buildSyntax(format: Format, leadingTrivia: Trivia?) -> Syntax {
        createAttribute().buildSyntax(format: format, leadingTrivia: leadingTrivia)
    }

    func createAttribute() -> Attribute {
        .init(
            atSignToken: .atSign.withLeadingTrivia(leadingTrivia ?? .zero),
            attributeName: .identifier("_implementationOnly"),
            tokenList: .none
        )
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        self
    }
}
