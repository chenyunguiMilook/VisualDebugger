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
public final class RenderBuilder: OperationBuilder<any ContextRenderable> {
}

open class OperationBuilder<E> {
    public typealias Expression = E
    public typealias Component = [E]
    
    // If Component were "any Collection of HTML", we could have this return
    // CollectionOfOne to avoid an array allocation.

    // 添加直接处理单个表达式的方法
    public static func buildBlock(_ expression: Expression) -> Component {
        return [expression]
    }
    
    // Build a combined result from a list of partial results by concatenating.
    //
    // If Component were "any Collection of HTML", we could avoid some unnecessary
    // reallocation work here by just calling joined().
    public static func buildBlock(_ children: Component...) -> Component {
      return children.flatMap { $0 }
    }

    // We can provide this overload as a micro-optimization for the common case
    // where there's only one partial result in a block.  This shows the flexibility
    // of using an ad-hoc builder pattern.
    public static func buildBlock(_ component: Component) -> Component {
      return component
    }
    
    public static func buildBlock(_ expresss: Expression...) -> Component {
        return Array(expresss)
    }
    
    // Handle optionality by turning nil into the empty list.
    public static func buildOptional(_ children: Component?) -> Component {
      return children ?? []
    }

    // Handle optionally-executed blocks.
    public static func buildEither(first child: Component) -> Component {
      return child
    }
    
    // Handle optionally-executed blocks.
    public static func buildEither(second child: Component) -> Component {
      return child
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap{ $0 }
    }
}
