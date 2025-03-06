//
//  DebugBuilder.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//

@resultBuilder
public final class DebugBuilder: BaseBuilder<any Debuggable> {
}

@resultBuilder
public final class DebugRenderBuilder: BaseBuilder<any DebugRenderable> {
}

@resultBuilder
public final class RenderBuilder: BaseBuilder<any ContextRenderable> {
}

open class BaseBuilder<E> {
    public typealias Expression = E
    public typealias Component = [E]
    
    // MARK: - Expression
    public static func buildExpression(_ expression: E) -> Component {
        return [expression]
    }
    
    // MARK: - Block overload
    public static func buildBlock(_ expressions: E...) -> Component {
        return Array(expressions)
    }
    
    public static func buildBlock(_ expressions: [E]) -> Component {
        return expressions
    }
    
    public static func buildBlock(_ expressions: [E]...) -> Component {
        return expressions.flatMap { $0 }
    }
    
    // MARK: - Optional overload
    public static func buildOptional(_ expressions: [E]?) -> Component {
        return if let expressions { expressions } else { [] }
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
