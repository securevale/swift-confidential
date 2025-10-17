import SwiftSyntax

extension LabeledExprListSyntax {

    func first(labeled label: String) -> LabeledExprSyntax? {
        first { $0.label?.trimmed.text == label }
    }
}
