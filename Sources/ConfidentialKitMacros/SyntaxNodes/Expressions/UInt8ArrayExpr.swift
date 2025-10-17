import SwiftSyntax

extension ArrayExprSyntax {

    static func makeUInt8ArrayExpr(from array: [UInt8]) -> Self {
        let arrayHexComponents = array.hexEncodedStringComponents(options: .numericLiteral)
        let arrayElements = arrayHexComponents
            .enumerated()
            .map { idx, component in
                ArrayElementSyntax(
                    expression: IntegerLiteralExprSyntax(literal: .identifier(component)),
                    trailingComma: idx < arrayHexComponents.endIndex - 1 ? .commaToken() : .none
                )
            }

        return .init(elements: ArrayElementListSyntax(arrayElements))
    }
}
