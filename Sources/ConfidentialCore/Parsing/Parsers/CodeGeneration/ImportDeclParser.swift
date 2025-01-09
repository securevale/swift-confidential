import Parsing
import SwiftSyntax
import SwiftSyntaxBuilder

struct ImportDeclParser: Parser {

    func parse(_ input: inout SourceSpecification) throws -> [ExpressibleAsCodeBlockItem] {
        guard
            !(input.importAttribute == .implementationOnly) || canUseNonPublicImport(given: input.secrets)
        else {
            throw ParsingError.assertionFailed(
                description: """
                             Cannot use @_implementationOnly import when the secret(s) access \
                             level is public.
                             Either change the access level to internal, or disable \
                             @_implementationOnly import.
                             """
            )
        }

        guard
            !(input.importAttribute == .internal) || canUseNonPublicImport(given: input.secrets)
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
            attribute: input.importAttribute
        )
    }
}

private extension ImportDeclParser {

    func canUseNonPublicImport(given secrets: SourceSpecification.Secrets) -> Bool {
        !secrets
            .flatMap(\.value)
            .map(\.accessModifier)
            .contains(.public)
    }

    func makeImportDeclStatements<Namespaces: Collection>(
        from namespaces: Namespaces,
        attribute: SourceSpecification.ImportAttribute
    ) -> [ExpressibleAsImportDecl]
    where
        Namespaces.Element == SourceSpecification.Secret.Namespace
    {
        var implementationOnlyModuleNames: Set<String> = []
        var internalModuleNames: Set<String> = []
        var moduleNames: Set<String> = [C.Code.Generation.foundationModuleName]
        switch attribute {
        case .default:
            moduleNames.insert(C.Code.Generation.confidentialKitModuleName)
        case .implementationOnly:
            implementationOnlyModuleNames.insert(C.Code.Generation.confidentialKitModuleName)
        case .internal:
            internalModuleNames.insert(C.Code.Generation.confidentialKitModuleName)
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
            implementationOnlyModuleNames: implementationOnlyModuleNames.sorted(),
            internalModuleNames: internalModuleNames.sorted(),
            moduleNames: moduleNames.sorted()
        )
    }

    func makeImportDeclStatements(
        implementationOnlyModuleNames: [String],
        internalModuleNames: [String],
        moduleNames: [String]
    ) -> [ExpressibleAsImportDecl] {
        let implementationOnlyImports = implementationOnlyModuleNames
            .map { moduleName in
                ImportDecl(
                    importTok: .import.withLeadingTrivia(.spaces(1)),
                    attributesBuilder: {
                        ImplementationOnlyAttribute()
                    },
                    pathBuilder: {
                        AccessPathComponent(name: .identifier(moduleName))
                    }
                )
            }
        let internalImports = internalModuleNames
            .map { moduleName in
                ImportDecl(
                    importTok: .import.withLeadingTrivia(.spaces(1)),
                    modifiersBuilder: {
                        TokenSyntax.internal.withTrailingTrivia(.spaces(0))
                    },
                    pathBuilder: {
                        AccessPathComponent(name: .identifier(moduleName))
                    }
                )
            }
        let imports = moduleNames
            .map { moduleName in
                ImportDecl(
                    pathBuilder: {
                        AccessPathComponent(name: .identifier(moduleName))
                    }
                )
            }

        return implementationOnlyImports + internalImports + imports
    }
}
