import Parsing
import SwiftSyntax

struct ImportDeclParser: Parser {

    func parse(_ input: inout SourceFileSpec) throws -> [CodeBlockItemSyntax] {
        guard
            !input.internalImport || canUseInternalImport(given: input.secrets)
        else {
            throw ParsingError.assertionFailed(
                description: """
                             Cannot use internal import when the secret(s) access \
                             level is package or public.
                             Either change the access level to internal, or disable \
                             internal import.
                             """
            )
        }

        return makeImportDeclStatements(
            from: input.secrets.namespaces,
            implementationOnly: input.internalImport
        )
    }
}

private extension ImportDeclParser {

    func canUseInternalImport(given secrets: SourceFileSpec.Secrets) -> Bool {
        secrets
            .flatMap(\.value)
            .map(\.accessModifier)
            .allSatisfy { $0 == .internal }
    }

    func makeImportDeclStatements<Namespaces: Collection>(
        from namespaces: Namespaces,
        implementationOnly: Bool
    ) -> [CodeBlockItemSyntax]
    where
        Namespaces.Element == SourceFileSpec.Secret.Namespace
    {
        var implementationOnlyModuleNames: Set<String> = []
        var moduleNames: Set<String> = []
        if implementationOnly {
            implementationOnlyModuleNames.insert(C.Code.Generation.confidentialKitModuleName)
        } else {
            moduleNames.insert(C.Code.Generation.confidentialKitModuleName)
        }

        moduleNames.formUnion(
            namespaces
                .compactMap { namespace -> String? in
                    guard
                        case let .extend(_, moduleName) = namespace,
                        let moduleName = moduleName,
                        moduleName != C.Code.Generation.confidentialCoreModuleName,
                        moduleName != C.Code.Generation.confidentialKitModuleName
                    else {
                        return nil
                    }

                    return moduleName
                }
        )

        return makeImportDeclStatements(
            moduleNames: moduleNames.sorted(),
            implementationOnlyModuleNames: implementationOnlyModuleNames.sorted()
        )
    }

    func makeImportDeclStatements(
        moduleNames: [String],
        implementationOnlyModuleNames: [String]
    ) -> [CodeBlockItemSyntax] {
        var imports = moduleNames
            .map { moduleName in
                CodeBlockItemSyntax(
                    item: .init(makeImportDecl(moduleName: moduleName))
                )
            }

        guard !implementationOnlyModuleNames.isEmpty else { return imports }

        let internalImports = implementationOnlyModuleNames
            .map { moduleName in
                CodeBlockItemSyntax(
                    item: .init(
                        makeImportDecl(modifiers: .internal, moduleName: moduleName)
                    )
                )
            }
        imports.insert(contentsOf: internalImports, at: .zero)

        return imports
    }

    func makeImportDecl(
        attributes: AttributeSyntax...,
        modifiers: Keyword...,
        moduleName: String
    ) -> ImportDeclSyntax {
        ImportDeclSyntax(
            attributes: AttributeListSyntax(attributes.map { .attribute($0) }),
            modifiers: DeclModifierListSyntax(modifiers.map { DeclModifierSyntax(name: .keyword($0)) }),
            path: [ImportPathComponentSyntax(name: .identifier(moduleName))]
        )
    }
}
