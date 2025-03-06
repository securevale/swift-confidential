/// A type that provides information about a metatype.
package struct TypeInfo {

    private let type: Any.Type

    /// Creates a new instance with the specified metatype value.
    ///
    /// - Parameter type: A type’s metatype value.
    @inlinable
    @inline(__always)
    package init(of type: Any.Type) {
        self.type = type
    }
}

package extension TypeInfo {

    /// The fully qualified name of the type, including its module name.
    @inlinable
    @inline(__always)
    var fullyQualifiedName: String {
        let name = String(reflecting: type)
        guard let typeLocationEndIndex = name.lastIndex(of: ":") else {
            return name
        }

        return .init(name.suffix(from: typeLocationEndIndex).dropFirst())
    }

    /// The type's defining module name.
    @inlinable
    @inline(__always)
    var moduleName: String {
        .init(fullyQualifiedName.prefix { $0 != "." })
    }

    /// The full name of the type, excluding its module name.
    @inlinable
    @inline(__always)
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

    /// The name of the type.
    @inlinable
    @inline(__always)
    var name: String {
        .init(describing: type)
    }
}
