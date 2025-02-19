import Parsing
import SwiftSyntax

struct ImportDeclParser: Parser {

    func parse(_ input: inout SourceSpecification) throws -> [CodeBlockItemSyntax] {
        guard
            !input.internalImport || canUseInternalImport(given: input.secrets)
        else {
            throw ParsingError.assertionFailed(
                description: """
                             Cannot use internal import when the secret(s) access \
                             level is public.
                             Either change the access level to internal, or disable \
                             internal import.
                             """
            )
        }

        return makeImportDeclStatements(
            from: input.secrets.namespaces,
            experimentalMode: input.experimentalMode,
            implementationOnly: input.internalImport
        )
    }
}

private extension ImportDeclParser {

    func canUseInternalImport(given secrets: SourceSpecification.Secrets) -> Bool {
        !secrets
            .flatMap(\.value)
            .map(\.accessModifier)
            .contains(.public)
    }

    func makeImportDeclStatements<Namespaces: Collection>(
        from namespaces: Namespaces,
        experimentalMode: Bool,
        implementationOnly: Bool
    ) -> [CodeBlockItemSyntax]
    where
        Namespaces.Element == SourceSpecification.Secret.Namespace
    {
        var implementationOnlyModuleNames: Set<String> = []
        var moduleNames: Set<String> = [C.Code.Generation.foundationModuleName]
        var confidentialKitModuleNames: Set<String> = [C.Code.Generation.confidentialKitModuleName]
        if experimentalMode {
            confidentialKitModuleNames.insert(C.Code.Generation.Experimental.confidentialKitModuleName)
        }
        if implementationOnly {
            implementationOnlyModuleNames.formUnion(confidentialKitModuleNames)
        } else {
            moduleNames.formUnion(confidentialKitModuleNames)
        }

        moduleNames.formUnion(
            namespaces
                .compactMap { namespace -> String? in
                    guard
                        case let .extend(_, moduleName) = namespace,
                        let moduleName = moduleName,
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
        let implementationOnlyImports = implementationOnlyModuleNames
            .map { moduleName in
                CodeBlockItemSyntax(
                    item: .init(
                        makeImportDecl(attributes: ._implementationOnly, moduleName: moduleName)
                    )
                )
            }
        imports.insert(
            CodeBlockItemSyntax(
                item: .init(
                    IfConfigDeclSyntax.makeIfSwiftVersionOrFeatureDecl(
                        swiftVersion: 6.0,
                        featureFlag: "AccessLevelOnImport",
                        ifElements: .statements(CodeBlockItemListSyntax(internalImports)),
                        elseElements: .statements(CodeBlockItemListSyntax(implementationOnlyImports))
                    )
                )
            ),
            at: .zero
        )

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
