import SwiftSyntax

extension ArrayExprSyntax {

    init<C>(
        _ elements: C,
        transformingElementsWith transform: (C.Element) throws -> any ExprSyntaxProtocol
    ) rethrows where C: Collection, C.Index == Int {
        self = ArrayExprSyntax(
            elements: .init(
                try elements
                    .enumerated()
                    .map { idx, element in
                        ArrayElementSyntax(
                            expression: try transform(element),
                            trailingComma: idx < elements.endIndex - 1 ? .commaToken() : .none
                        )
                    }
            )
        )
    }
}
