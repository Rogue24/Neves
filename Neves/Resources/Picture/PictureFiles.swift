// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length line_length implicit_return

// MARK: - Files

// swiftlint:disable explicit_type_interface identifier_name
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum PictureFiles {
  /// girl.jpg
  internal static let girlJpg = PictureFile(name: "girl", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl1.jpg
  internal static let girl1Jpg = PictureFile(name: "Girl1", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl2.jpg
  internal static let girl2Jpg = PictureFile(name: "Girl2", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl3.jpg
  internal static let girl3Jpg = PictureFile(name: "Girl3", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl4.jpg
  internal static let girl4Jpg = PictureFile(name: "Girl4", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl5.jpg
  internal static let girl5Jpg = PictureFile(name: "Girl5", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl6.jpg
  internal static let girl6Jpg = PictureFile(name: "Girl6", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl7.jpg
  internal static let girl7Jpg = PictureFile(name: "Girl7", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// Girl8.jpg
  internal static let girl8Jpg = PictureFile(name: "Girl8", ext: "jpg", relativePath: "", mimeType: "image/jpeg")
  /// JPIcon.png
  internal static let jpIconPng = PictureFile(name: "JPIcon", ext: "png", relativePath: "", mimeType: "image/png")
}
// swiftlint:enable explicit_type_interface identifier_name
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

internal struct PictureFile {
  internal let name: String
  internal let ext: String?
  internal let relativePath: String
  internal let mimeType: String

  internal var url: URL {
    return url(locale: nil)
  }

  internal func url(locale: Locale?) -> URL {
    let bundle = BundleToken.bundle
    let url = bundle.url(
      forResource: name,
      withExtension: ext,
      subdirectory: relativePath,
      localization: locale?.identifier
    )
    guard let result = url else {
      let file = name + (ext.flatMap { ".\($0)" } ?? "")
      fatalError("Could not locate file named \(file)")
    }
    return result
  }

  internal var path: String {
    return path(locale: nil)
  }

  internal func path(locale: Locale?) -> String {
    return url(locale: locale).path
  }
}

// swiftlint:disable convenience_type explicit_type_interface
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type explicit_type_interface
