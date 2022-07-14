struct TypeInfo {

    private let type: Any.Type

    init(of type: Any.Type) {
        self.type = type
    }
}

extension TypeInfo {

    var fullyQualifiedName: String {
        let name = String(reflecting: type)
        guard let typeLocationEndIndex = name.lastIndex(of: ":") else {
            return name
        }

        return .init(name.suffix(from: typeLocationEndIndex).dropFirst())
    }

    var moduleName: String {
        .init(fullyQualifiedName.prefix { $0 != "." })
    }

    var fullName: String {
        let fullyQualifiedName = fullyQualifiedName
        guard
            let index = fullyQualifiedName.firstIndex(of: "."),
            fullyQualifiedName.distance(from: index, to: fullyQualifiedName.endIndex) > 1
        else {
            fatalError("Unexpected metatype string representation")
        }

        return .init(fullyQualifiedName.suffix(from: index).dropFirst())
    }

    var name: String {
        .init(describing: type)
    }
}
