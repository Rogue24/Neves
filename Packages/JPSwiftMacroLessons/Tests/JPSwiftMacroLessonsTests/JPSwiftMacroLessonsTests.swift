import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(JPSwiftMacroLessonsMacros)
import JPSwiftMacroLessonsMacros

let testMacros: [String: Macro.Type] = [
    "jpStringify": JPStringifyMacro.self,
    "jpURL": JPURLMacro.self,
    "JPDebugSummary": JPDebugSummaryMacro.self,
    "JPEnumDescription": JPEnumDescriptionMacro.self,
]
#endif

final class JPSwiftMacroLessonsTests: XCTestCase {
    func testStringifyMacro() {
        #if canImport(JPSwiftMacroLessonsMacros)
        assertMacroExpansion(
            """
            #jpStringify(1 + 2)
            """,
            expandedSource: """
            (value: 1 + 2, source: "1 + 2")
            """,
            macros: testMacros
        )
        #endif
    }

    func testURLMacro() {
        #if canImport(JPSwiftMacroLessonsMacros)
        assertMacroExpansion(
            """
            #jpURL("https://developer.apple.com")
            """,
            expandedSource: """
            Foundation.URL(string: "https://developer.apple.com")!
            """,
            macros: testMacros
        )
        #endif
    }

    func testURLMacroDiagnosesBadURL() {
        #if canImport(JPSwiftMacroLessonsMacros)
        assertMacroExpansion(
            """
            #jpURL("developer.apple.com")
            """,
            expandedSource: """
            Foundation.URL(string: "about:blank")!
            """,
            diagnostics: [
                DiagnosticSpec(message: "#jpURL 需要完整的 http/https URL，例如 https://developer.apple.com", line: 1, column: 8),
            ],
            macros: testMacros
        )
        #endif
    }

    func testDebugSummaryMacro() {
        #if canImport(JPSwiftMacroLessonsMacros)
        assertMacroExpansion(
            """
            @JPDebugSummary
            struct User {
                let name: String
                let level: Int
            }
            """,
            expandedSource: """
            struct User {
                let name: String
                let level: Int

                var debugSummary: String {
                    "\\(Self.self)(name: \\(name), level: \\(level))"
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testEnumDescriptionMacro() {
        #if canImport(JPSwiftMacroLessonsMacros)
        assertMacroExpansion(
            """
            @JPEnumDescription
            enum Role {
                case owner
                case learner
            }
            """,
            expandedSource: """
            enum Role {
                case owner
                case learner
            }

            extension Role: Swift.CustomStringConvertible {
                var description: Swift.String {
                    switch self {
                    case .owner:
                        return "owner"
                    case .learner:
                        return "learner"
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
