# Swift Confidential

[![CI](https://github.com/securevale/swift-confidential/actions/workflows/ci.yml/badge.svg)](https://github.com/securevale/swift-confidential/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/securevale/swift-confidential/branch/master/graph/badge.svg)](https://codecov.io/gh/securevale/swift-confidential)
[![Swift](https://img.shields.io/badge/Swift-5.6-red)](https://www.swift.org/download)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-red)]()
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)](https://github.com/apple/swift-package-manager)

A highly configurable and performant tool for obfuscating Swift literals embedded in the application code that you should protect from static code analysis, making the app more resistant to reverse engineering.

Simply integrate the tool with your Swift package, configure your own obfuscation algorithm along with the list of secret literals, and build the project 🚀

> **NOTE:** Swift Confidential is still in development and even though a lot of thought was put into API design, apart from new features, some breaking changes might still be introduced. See [Versioning](#versioning) section for more information.

## Motivation

Pretty much every single app has at least few literals embedded in code, those include: URLs, various client identifiers (e.g. API keys or API tokens), pinning data (e.g. PEM certificates or SPKI digests), Keychain item identifiers, RASP-related literals (e.g. list of suspicious dylibs or list of suspicious file paths for jailbreak detection), and many other context-specific literals. While the listed examples of code literals might seem innocent, not obfuscating them can be considered as giving a handshake to the potential threat actor. This is especially true in security-critical apps, such as mobile banking apps or 2FA authentication apps. As a responsible software engineer, you should be aware that extracting source code literals from the app package is generally easy enough that even less expirienced malicious users can accomplish this with little effort.

<p align="center">
    <img src="Resources/machoview-cstring-literals.png" alt="Mach-O C String Literals">
    <em>A sneak peek at the __TEXT.__cstring section in a sample Mach-O file reveals a lot of interesting information about the app.</em>
</p>

This tool aims to provide an elegant and maintainable solution to the above problem by introducing the composable obfuscation techniques that can be freely combined to form an algorithm for obfuscating selected Swift literals. 

> **NOTE:** While Swift Confidential certainly makes the static analysis of the code more challenging, **it is by no means the only code hardening technique that you should employ to protect your app against reverse engineering and tampering**. To achieve a decent level of security, we highly encourage you to supplement this tool's security measures with **runtime application self-protection (RASP) checks**, as well as **Swift code obfuscation**. With that said, no security measure can ever guarantee absolute security. Any motivated and skilled enough attacker will eventually bypass all security protections. For this reason, **always keep your threat models up to date**.

## Getting started

Begin by creating a `confidential.yml` YAML configuration file in the root directory of your target's sources. At minimum, the configuration must contain obfuscation algorithm and one or more secret definitions.

For example, a configuration file for the hypothetical `RASP` module could look like this:

```yaml
algorithm:
  - encrypt using aes-192-gcm
  - shuffle
defaultNamespace: extend RASP.Literals
secrets:
  - name: suspiciousDynamicLibraries
    value:
      - Substrate
      - Substitute
      - frida
      # ... other suspicious dylibs
  - name: suspiciousFilePaths
    value:
      - /.installed_unc0ver
      - /usr/sbin/frida-server
      - /private/var/lib/cydia
      # ... other suspicious file paths
```

> **WARNING:** The algorithm from the above configuration serves as example only, **do not use this particular algorithm in your production code**. Instead, compose your own algorithm from the [obfuscation techniques](#obfuscation-techniques) described below and **don't share your algorithm with anyone**. Moreover, following the [secure SDLC](https://owasp.org/www-project-integration-standards/writeups/owasp_in_sdlc/) best practices, consider not to commit the production algorithm in your repository, but instead configure your CI/CD pipeline to run a custom script (ideally just before the build step), which will modify the configuration file by replacing the algorithm value with the one retrieved from the secrets vault.

Having created the configuration file, you can use [Confidential Swift Package plugin](https://github.com/securevale/swift-confidential-plugin) (see [this section](#integrating-with-your-swiftpm-project) for details) to generate Swift code with obfuscated secret literals.

Under the hood, the Confidential plugin invokes the `confidential` CLI tool by issuing the following command:

```sh
confidential obfuscate --configuration "path/to/confidential.yml" --output "path/to/Confidential.generated.swift"
```

Upon successful command execution, the generated `Confidential.generated.swift` file will contain code similar to the following:

```swift
import ConfidentialKit
import Foundation

extension RASP.Literals {

    @ConfidentialKit.Obfuscated<Swift.Array<Swift.String>>(deobfuscateData)
    static var suspiciousDynamicLibraries: ConfidentialKit.Obfuscation.Secret = .init(data: [0x4a, 0x84, 0x89, 0x73, 0x7c, 0x81, 0x18, 0x86, 0x16, 0x5e, 0x1c, 0x41, 0xdc, 0x2e, 0xe1, 0xe4, 0x92, 0x98, 0xdc, 0xde, 0x98, 0xa5, 0xa7, 0x31, 0x6a, 0x5f, 0x4c, 0x7e, 0x5d, 0x61, 0xfd, 0x9d, 0xc1, 0xd2, 0xd4, 0xb8, 0xaf, 0xba, 0xa3, 0x46, 0xda, 0x61, 0xcb, 0xf1, 0xb7, 0xbd, 0xf9, 0xc7, 0x3a, 0x6d, 0xe8, 0x62, 0x09, 0x29, 0x6e, 0x13, 0x5b, 0x50, 0xfa, 0xde, 0x80, 0x82, 0x80, 0x7e, 0xe2, 0x3c, 0xf0, 0xf1, 0x03, 0x12, 0xf8, 0x50, 0x95, 0x03, 0xc8, 0x4e, 0xc1, 0xb3, 0xa9, 0x2c, 0xed, 0x0b, 0x1b, 0x71, 0xe8, 0xfd, 0xa2, 0x69, 0xca, 0xac, 0x4f, 0x35, 0xc6, 0x4f, 0x01, 0x36, 0x5a, 0x5d, 0x58, 0x3b, 0x37, 0x0b, 0x0c, 0x4e, 0x24, 0x1f, 0x38, 0x25, 0x33, 0x3d, 0x4c, 0x27, 0x1c, 0x20, 0x15, 0x01, 0x07, 0x26, 0x0a, 0x51, 0x1a, 0x3c, 0x11, 0x18, 0x21, 0x12, 0x1e, 0x29, 0x3f, 0x5f, 0x0e, 0x19, 0x09, 0x57, 0x31, 0x04, 0x32, 0x4f, 0x2f, 0x02, 0x35, 0x06, 0x23, 0x03, 0x08, 0x1d, 0x2c, 0x39, 0x2d, 0x10, 0x5e, 0x48, 0x05, 0x28, 0x0d, 0x52, 0x5c, 0x4d, 0x30, 0x17, 0x2e, 0x5b, 0x34, 0x1b, 0x56, 0x49, 0x22, 0x00, 0x53, 0x55, 0x16, 0x2a, 0x50, 0x13, 0x54, 0x2b, 0x59, 0x3a, 0x3e, 0x0f, 0x14])

    @ConfidentialKit.Obfuscated<Swift.Array<Swift.String>>(deobfuscateData)
    static var suspiciousFilePaths: ConfidentialKit.Obfuscation.Secret = .init(data: [0x99, 0x84, 0x89, 0x73, 0x7c, 0x81, 0x18, 0x86, 0xe0, 0x5b, 0x88, 0x65, 0xa5, 0x1f, 0x53, 0x5e, 0x3c, 0xa5, 0x58, 0x0b, 0x80, 0x06, 0xad, 0x6d, 0x5e, 0xae, 0x2d, 0x52, 0xea, 0xf1, 0xde, 0xac, 0x9d, 0x36, 0x12, 0x56, 0xf9, 0xce, 0xe4, 0x95, 0x84, 0x7e, 0x47, 0x44, 0xde, 0xd3, 0x76, 0x68, 0x67, 0x90, 0xfb, 0x30, 0x3c, 0xaf, 0x33, 0xce, 0x8e, 0x79, 0xa5, 0xdb, 0x7a, 0x97, 0x9d, 0x60, 0x58, 0x0f, 0x59, 0x5f, 0x2c, 0xe0, 0x3a, 0x4d, 0xf6, 0x38, 0x75, 0x1c, 0x2e, 0x5c, 0x94, 0x3f, 0x7c, 0x7a, 0x61, 0xca, 0xbe, 0xbf, 0x52, 0x05, 0x0d, 0xc7, 0xe3, 0xe2, 0x8e, 0x34, 0x02, 0x5f, 0x6b, 0x56, 0xb0, 0x67, 0xac, 0xf3, 0xf8, 0x3d, 0xf5, 0x26, 0xa0, 0x3b, 0x91, 0xf4, 0x88, 0x38, 0xc4, 0x5b, 0xaa, 0x7a, 0x0c, 0x2e, 0x98, 0xeb, 0xd2, 0xbd, 0x7e, 0x63, 0x53, 0xf7, 0x37, 0xb4, 0xc0, 0xb8, 0x8f, 0xb6, 0xe1, 0xd4, 0x3c, 0x89, 0x7c, 0x0f, 0xa8, 0x2a, 0xea, 0x01, 0x0c, 0x74, 0x7b, 0x65, 0x4c, 0x78, 0x14, 0x0f, 0x09, 0x60, 0x02, 0x2f, 0x1f, 0x4a, 0x2c, 0x1a, 0x52, 0x1e, 0x37, 0x98, 0x71, 0x17, 0x30, 0x34, 0x0a, 0x3c, 0x5f, 0x6a, 0x58, 0x42, 0x13, 0x39, 0x44, 0x4d, 0x79, 0x41, 0x59, 0x4b, 0x7d, 0x64, 0x20, 0x33, 0x21, 0x50, 0x5d, 0x22, 0x45, 0x28, 0x54, 0x4f, 0x66, 0x6d, 0x77, 0x03, 0x11, 0x25, 0x26, 0x08, 0x6c, 0x9d, 0x2b, 0x12, 0x6e, 0x68, 0x5e, 0x69, 0x04, 0x9e, 0x06, 0x0d, 0x3a, 0x3e, 0x63, 0x62, 0x2a, 0x19, 0x55, 0x73, 0x01, 0x24, 0x7a, 0x1c, 0x61, 0x32, 0x23, 0x2e, 0x7c, 0x35, 0x46, 0x1b, 0x5b, 0x76, 0x36, 0x4e, 0x7f, 0x16, 0x3f, 0x51, 0x7e, 0x0b, 0x27, 0x9c, 0x10, 0x57, 0x31, 0x18, 0x3b, 0x2d, 0x1d, 0x47, 0x67, 0x0e, 0x6b, 0x72, 0x6f, 0x56, 0x53, 0x40, 0x9f, 0x5c, 0x05, 0x3d, 0x49, 0x00, 0x5a, 0x15, 0x43, 0x38, 0x29, 0x75, 0x70, 0x48, 0x07])

    @inline(__always)
    private static func deobfuscateData(_ data: Foundation.Data) throws -> Foundation.Data {
        try ConfidentialKit.Obfuscation.Encryption.DataCrypter(algorithm: .aes192GCM)
            .deobfuscate(
                try ConfidentialKit.Obfuscation.Randomization.DataShuffler(nonce: 9662615372037719068)
                    .deobfuscate(data)
            )
    }
}
```

You can then, for example, iterate over a deobfuscated array of suspicious dynamic libraries in your own code using the projected value of the generated `suspiciousDynamicLibraries` property:

```swift
let suspiciousLibraries = RASP.Literals.$suspiciousDynamicLibraries
    .map { $0.lowercased() }
let checkPassed = loadedLibraries
    .allSatisfy { !suspiciousLibraries.contains(where: $0.lowercased().contains) }
```

### Integrating with your SwiftPM project

To use Swift Confidential with your SwiftPM package, add the `ConfidentialKit` library along with `Confidential` plugin to the package's dependencies and then to your target's dependencies and plugins respectively:

```swift
// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "MyLibrary",
    products: [
        .library(name: "MyLibrary", targets: ["MyLibrary"])
    ],
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/securevale/swift-confidential.git", from: "0.1.0"),
        .package(url: "https://github.com/securevale/swift-confidential-plugin.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "MyLibrary",
            dependencies: [
                // other dependencies
                .product(name: "ConfidentialKit", package: "swift-confidential")
            ],
            exclude: ["confidential.yml"],
            plugins: [
                // other plugins
                .plugin(name: "Confidential", package: "swift-confidential-plugin")
            ]
        )
    ]
)
```

Please make sure to add a path to the `confidential.yml` configuration file to target's `exclude` list to explicitly exclude this file from the target's resources.

Now simply build the `MyLibrary` target and the plugin will automatically generate a Swift source file with obfuscated secret literals. In addition, the plugin will regenerate the obfuscated secret literals every time it detects a change to `confidential.yml` configuration file or when you clean build your project.

> **NOTE:** Swift 5.6 is required in order to run the plugin. 
> Also, please make sure to use the same version requirements for both `swift-confidential` and `swift-confidential-plugin` packages.

## Configuration

Swift Confidential supports a number of configuration options, all of which are stored in a single YAML configuration file.

### YAML configuration keys

The table below lists the keys to include in the configuration file along with the type of information to include in each. Any other keys in the configuration file are ignored by the CLI tool.

| Key              | Value type               | Description                                                                       |
|------------------|--------------------------|-----------------------------------------------------------------------------------|
| algorithm        | List of strings          | The list of obfuscation techniques representing individual steps that are composed together to form the obfuscation algorithm. See [Obfuscation techniques](#obfuscation-techniques) section for usage details.<br/><sub>**Required.**</sub> |
| defaultNamespace | String                   | The default namespace in which to enclose all the generated secret literals without explicitly assigned namespace. The default value is `extend Obfuscation.Secret from ConfidentialKit`. See [Namespaces](#namespaces) section for usage details. |
| secrets          | List of objects          | The list of objects defining the secret literals to be obfuscated. See [Secrets](#secrets) section for usage details.<br/><sub>**Required.**</sub> |

<details>
<summary><strong>Example configuration</strong></summary>

```yaml
algorithm:
  - encrypt using aes-192-gcm
  - shuffle
defaultNamespace: create Secrets
secrets:
  - name: apiToken
    value: 214C1E2E-A87E-4460-8205-4562FDF54D1C
  - name: trustedSPKIDigests
    value:
      - 7a6820614ee600bbaed493522c221c0d9095f3b4d7839415ffab16cbf61767ad
      - cf84a70a41072a42d0f25580b5cb54d6a9de45db824bbb7ba85d541b099fd49f
      - c1a5d45809269301993d028313a5c4a5d8b2f56de9725d4d1af9da1ccf186f30
    namespace: extend Pinning from Crypto
```

> **WARNING:** The algorithm from the above configuration serves as example only, **do not use this particular algorithm in your production code**.
</details>

### Obfuscation techniques

The obfuscation techniques are the composable building blocks from which you can create your own obfuscation algorithm. You can compose them in any order you want, so that no one exept you knows how the secret literals are obfuscated.

#### Compression

This technique involves data compression using the algorithm of your choice. The compression technique is **non-polymorphic**, meaning that given the same input data, the same output data is produced with each run.

**Syntax**

```yaml
compress using <algorithm>
```

The supported algorithms are shown in the following table:
| Algorithm        | Description                                               |
|------------------|-----------------------------------------------------------|
| lzfse            | The LZFSE compression algorithm.                          |
| lz4              | The LZ4 compression algorithm.                            |
| lzma             | The LZMA compression algorithm.                           |
| zlib             | The zlib compression algorithm.                           |

#### Encryption

This technique involves data encryption using the algorithm of your choice. The encryption technique is **polymorphic**, meaning that given the same input data, different output data is produced with each run.

**Syntax**

```yaml
encrypt using <algorithm>
```

The supported algorithms are shown in the following table:
| Algorithm        | Description                                                                                     |
|------------------|-------------------------------------------------------------------------------------------------|
| aes-128-gcm      | The Advanced Encryption Standard (AES) algorithm in Galois/Counter Mode (GCM) with 128-bit key. |
| aes-192-gcm      | The Advanced Encryption Standard (AES) algorithm in Galois/Counter Mode (GCM) with 192-bit key. |
| aes-256-gcm      | The Advanced Encryption Standard (AES) algorithm in Galois/Counter Mode (GCM) with 256-bit key. |
| chacha20-poly    | The ChaCha20-Poly1305 algorithm.                                                                |

#### Randomization

This technique involves data randomization. The randomization technique is **polymorphic**, meaning that given the same input data, different output data is produced with each run.

> **NOTE:**  Randomization technique is best suited for secrets of which size does not exceed 256 bytes. 
> For larger secrets, the size of the obfuscated data will grow from 2N to 3N, where N is the input data size in bytes, 
> or even 5N (32-bit platform) or 9N (64-bit platform) if the size of input data is larger than 65 536 bytes.
> For this reason, the internal implementation of this technique is a subject to change in next releases.

**Syntax**

```yaml
shuffle
```

### Secrets

The configuration file utilizes YAML objects to describe the secret literals, which are to be obfuscated. The table below lists the keys to define secret literal along with the type of information to include in each.

| Key              | Value type                | Description                                                                      |
|------------------|---------------------------|----------------------------------------------------------------------------------|
| name             | String                    | The name of the generated Swift property containing obfuscated secret literal's data. This value is used as-is, without validity checking. Thus, make sure to use a valid property name.<br/><sub>**Required.**</sub> | 
| namespace        | String                    | The namespace in which to enclose the generated secret literal declaration. See [Namespaces](#namespaces) section for usage details. |
| value            | String or List of strings | The plain value of the secret literal, which is to be obfuscated. The YAML data types are mapped to `String` and `Array<String>` in Swift, respectively.<br/><sub>**Required.**</sub> |

<details>
<summary><strong>Example secret definition</strong></summary>

Supposing that you would like to obfuscate the tag used to reference the private key stored in Keychain or Secure Enclave:

```yaml
name: secretVaultKeyTag
value: com.example.app.keys.secret_vault_private_key
namespace: extend KeychainAccess.Key from Crypto
```

The above YAML secret definition will result in the following Swift code being generated:

```swift
import Crypto
// ... other imports

extension Crypto.KeychainAccess.Key {

    @ConfidentialKit.Obfuscated<Swift.String>(deobfuscateData)
    static var secretVaultKeyTag: ConfidentialKit.Obfuscation.Secret = .init(data: [/* obfuscated data */])
}
```

You may also need to obfuscate a list of related values, such as a list of trusted SPKI digests to pin against:

```yaml
name: trustedSPKIDigests
value:
  - 7a6820614ee600bbaed493522c221c0d9095f3b4d7839415ffab16cbf61767ad
  - cf84a70a41072a42d0f25580b5cb54d6a9de45db824bbb7ba85d541b099fd49f
  - c1a5d45809269301993d028313a5c4a5d8b2f56de9725d4d1af9da1ccf186f30
namespace: extend Pinning from Crypto
```

With the above YAML secret definition, the following Swift code will be generated:

```swift
import Crypto
// ... other imports

extension Crypto.Pinning {

    @ConfidentialKit.Obfuscated<Swift.Array<Swift.String>>(deobfuscateData)
    static var trustedSPKIDigests: ConfidentialKit.Obfuscation.Secret = .init(data: [/* obfuscated data */])
}
```
</details>

### Namespaces

In accordance with Swift programming best practices, Swift Confidential encapsulates generated secret literal declarations in namespaces (typically enums). The namespaces syntax allows you to either create a new namespace or extend an existing one.

**Syntax**

```yaml
create <namespace> # creates new namespace

extend <namespace> [from <module>] # extends existing namespace, optionally specifying 
                                   # the module to which this namespace belongs
```

<details>
<summary><strong>Example usage</strong></summary>

Assuming that you would like to keep the generated secret literal declaration(s) in a new namespace named `Secrets`, use the following YAML code:

```yaml
create Secrets
```

The above namespace definition will result in the following Swift code being generated:

```swift
enum Secrets {

    // Encapsulated declarations ...
}

```

> **NOTE:** The creation of the nested namespaces is currently not supported.

If, however, you would rather like to keep the generated secret literal declaration(s) in an existing namespace named `Pinning` and imported from `Crypto` module, use the following YAML code instead:

```yaml
extend Pinning from Crypto
```

With the above namespace definition, the following Swift code will be generated:

```swift
import Crypto
// ... other imports

extension Crypto.Pinning {

    // Encapsulated declarations ...
}
```
</details>

### Additional considerations for Confidential Swift Package plugin

The [Confidential Swift Package plugin](https://github.com/securevale/swift-confidential-plugin) expects the configuration file to be named `confidential.yml` or `confidential.yaml`, and it assumes a single configuration file per target. If you define multiple configuration files in different subdirectories, then the plugin will use the first one it finds, and which one is undefined.

## Versioning

This project follows [semantic versioning](https://semver.org/). While still in major version `0`, source-stability is only guaranteed within minor versions (e.g. between `0.1.0` and `0.1.1`). If you want to guard against potentially source-breaking package updates, you can specify your package dependency using version range (e.g. `"0.1.0"<.."0.2.0"`) as the requirement.

## License

This tool and code is released under Apache License v2.0 with Runtime Library Exception. 
Please see [LICENSE](LICENSE) for more information.