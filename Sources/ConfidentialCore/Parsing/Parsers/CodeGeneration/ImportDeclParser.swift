import Parsing
import SwiftSyntax
import SwiftSyntaxBuilder

struct ImportDeclParser: Parser {

    func parse(_ input: inout SourceSpecification) throws -> [ExpressibleAsCodeBlockItem] {
        guard
            !input.implementationOnlyImport || canUseImplementationOnlyImport(given: input.secrets)
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

        return makeImportDeclStatements(
            from: input.secrets.namespaces,
            implementationOnly: input.implementationOnlyImport
        )
    }
}

private extension ImportDeclParser {

    func canUseImplementationOnlyImport(given secrets: SourceSpecification.Secrets) -> Bool {
        !secrets
            .flatMap(\.value)
            .map(\.accessModifier)
            .contains(.public)
    }

    func makeImportDeclStatements<Namespaces: Collection>(
        from namespaces: Namespaces,
        implementationOnly: Bool
    ) -> [ExpressibleAsImportDecl]
    where
        Namespaces.Element == SourceSpecification.Secret.Namespace
    {
        var implementationOnlyModuleNames: Set<String> = []
        var moduleNames: Set<String> = [C.Code.Generation.foundationModuleName]
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
                        let moduleName = moduleName
                    else {
                        return nil
                    }

                    return moduleName
                }
        )

        return makeImportDeclStatements(
            implementationOnlyModuleNames: implementationOnlyModuleNames.sorted(),
            moduleNames: moduleNames.sorted()
        )
    }

    func makeImportDeclStatements(
        implementationOnlyModuleNames: [String],
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
        let imports = moduleNames
            .map { moduleName in
                ImportDecl(
                    pathBuilder: {
                        AccessPathComponent(name: .identifier(moduleName))
                    }
                )
            }

        return implementationOnlyImports + imports
    }
}
