//
//  DebugBuilder.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//

@resultBuilder
public final class DebugBuilder: OperationBuilder<any Debuggable> {
}

@resultBuilder
public final class DebugRenderBuilder: OperationBuilder<any DebugRenderable> {
}

@resultBuilder
public final class RenderBuilder: OperationBuilder<any ContextRenderable> {
}

open class OperationBuilder<E> {
    public typealias Expression = E
    public typealias Component = [E]
    
    // MARK: - Expression
    public static func buildExpression(_ expression: E) -> E {
        return expression
    }
    
    // MARK: - Block overload
    public static func buildBlock(_ expressions: E...) -> Component {
        return Array(expressions)
    }
    
    public static func buildBlock(_ expressions: E?...) -> Component {
        return expressions.compactMap { $0 }
    }
    
    public static func buildBlock(_ expressions: [Component]) -> Component {
        return expressions.flatMap { $0 }
    }
    
    // MARK: - Optional overload
    public static func buildOptional(_ expression: E?) -> Component {
        return expression != nil ? [expression!] : []
    }
    
    public static func buildOptional(_ expressions: E?...) -> Component {
        return expressions.compactMap { $0 }
    }
    
    public static func buildOptional(_ component: [E]?) -> Component {
        component ?? []
    }
    // MARK: - If-else overload
    public static func buildEither(first child: Component) -> Component {
        return child
    }
    
    public static func buildEither(second child: Component) -> Component {
        return child
    }
    
    // MARK: - Array overload
    public static func buildArray(_ components: [E]) -> Component {
        return components
    }
}
