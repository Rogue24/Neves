import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private struct JPLessonDiagnostic: DiagnosticMessage {
    let message: String
    let id: String
    let severity: DiagnosticSeverity

    var diagnosticID: MessageID {
        MessageID(domain: "JPSwiftMacroLessons", id: id)
    }
}

private extension MacroExpansionContext {
    func jpDiagnose(node: some SyntaxProtocol, id: String, message: String, severity: DiagnosticSeverity = .error) {
        diagnose(Diagnostic(node: Syntax(node), message: JPLessonDiagnostic(message: message, id: id, severity: severity)))
    }
}

public struct JPStringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            context.jpDiagnose(node: node, id: "missingArgument", message: "#jpStringify 需要一个表达式")
            return "(value: (), source: \"\")"
        }

        return "(value: \(argument), source: \(literal: argument.trimmedDescription))"
    }
}

public struct JPURLMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            context.jpDiagnose(node: node, id: "missingURL", message: "#jpURL 需要一个 URL 字符串")
            return "Foundation.URL(string: \"about:blank\")!"
        }

        guard
            let literal = argument.as(StringLiteralExprSyntax.self),
            literal.segments.count == 1,
            let segment = literal.segments.first?.as(StringSegmentSyntax.self)
        else {
            context.jpDiagnose(
                node: argument,
                id: "nonLiteralURL",
                message: "#jpURL 只接受静态字符串字面量，例如 #jpURL(\"https://example.com\")"
            )
            return "Foundation.URL(string: \"about:blank\")!"
        }

        let text = segment.content.text
        guard
            let components = URLComponents(string: text),
            let scheme = components.scheme,
            ["http", "https"].contains(scheme.lowercased()),
            components.host?.isEmpty == false
        else {
            context.jpDiagnose(
                node: argument,
                id: "invalidURL",
                message: "#jpURL 需要完整的 http/https URL，例如 https://developer.apple.com"
            )
            return "Foundation.URL(string: \"about:blank\")!"
        }

        return "Foundation.URL(string: \(argument))!"
    }
}

public struct JPDebugSummaryMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.jpDiagnose(node: declaration, id: "debugSummaryOnlyStruct", message: "@JPDebugSummary 只能贴在 struct 上")
            return []
        }

        let propertyNames = storedPropertyNames(from: structDecl)
        let summaryBody = propertyNames.isEmpty
            ? ""
            : propertyNames.map { "\($0): \\(\($0))" }.joined(separator: ", ")

        return [
            DeclSyntax(stringLiteral: """
            var debugSummary: String {
                "\\(Self.self)(\(summaryBody))"
            }
            """)
        ]
    }

    private static func storedPropertyNames(from structDecl: StructDeclSyntax) -> [String] {
        structDecl.memberBlock.members.compactMap { member -> String? in
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                variable.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) == false,
                let binding = variable.bindings.first,
                binding.accessorBlock == nil,
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
            else {
                return nil
            }

            return pattern.identifier.text
        }
    }
}

public struct JPEnumDescriptionMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.jpDiagnose(node: declaration, id: "enumDescriptionOnlyEnum", message: "@JPEnumDescription 只能贴在 enum 上")
            return []
        }

        var cases: [String] = []
        for member in enumDecl.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }

            for element in caseDecl.elements {
                if element.parameterClause != nil {
                    context.jpDiagnose(
                        node: element,
                        id: "enumDescriptionAssociatedValue",
                        message: "@JPEnumDescription 这版教学宏只支持无关联值 enum"
                    )
                    return []
                }
                cases.append(element.name.text)
            }
        }

        let switchLines = cases.isEmpty
            ? "default: return \"\\(self)\""
            : cases.map { "case .\($0): return \"\($0)\"" }.joined(separator: "\n        ")

        return [
            try ExtensionDeclSyntax("""
            extension \(type): Swift.CustomStringConvertible {
                var description: Swift.String {
                    switch self {
                    \(raw: switchLines)
                    }
                }
            }
            """)
        ]
    }
}

@main
struct JPSwiftMacroLessonsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JPStringifyMacro.self,
        JPURLMacro.self,
        JPDebugSummaryMacro.self,
        JPEnumDescriptionMacro.self,
    ]
}
