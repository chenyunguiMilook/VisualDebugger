//
//  Test.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Testing
@testable import VisualDebugger
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct Test {

    @MainActor
    @Test func testPointDebug() {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let view = DebugView(elements: [
            DebugPoints(points: [
                .init(x: 10, y: 10),
                .init(x: 10, y: 23),
                .init(x: 23, y: 67)
            ])
        ], coordinateSystem: .yUp)
        
        print(view)
    }
}
