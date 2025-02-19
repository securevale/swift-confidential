import SwiftSyntax

extension AttributeSyntax {

    // swiftlint:disable:next identifier_name
    static var _implementationOnly: Self {
        .init(
            attributeName: IdentifierTypeSyntax(
                name: .identifier("_implementationOnly")
            )
        )
    }
}
