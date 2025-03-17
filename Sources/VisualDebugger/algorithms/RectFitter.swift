//
//  RectFitter.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/9.
//

import Foundation

typealias FitConfig = RectFitter.Config

struct RectFitter {
    
    static func fit(
        rect source: CGRect,
        to target: CGRect,
        config: Config = .aspectFillInside
    ) -> CGAffineTransform {
        Self.fit(
            rect: source,
            to: target,
            align: config.align,
            scale: config.scale
        )
    }

    static func fit(
        rect source: CGRect,
        to target: CGRect,
        align: Align,
        scale: Scale
    ) -> CGAffineTransform {

        let x1 = source.origin.x
        let y1 = source.origin.y
        let w1 = source.size.width
        let h1 = source.size.height

        let w2 = target.size.width
        let h2 = target.size.height

        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1

        switch scale {
        case .none:
            break
        case .aspect(let match):
            let useWidth: Bool = switch match {
            case .width: true
            case .height: false
            case .minEdge: w1 / h1 > w2 / h2
            case .maxEdge: w1 / h1 < w2 / h2
            }
            scaleX = useWidth ? w2 / w1 : h2 / h1
            scaleY = scaleX
        case .stretch(let match):
            if match.contains(.width) {
                scaleX = w2 / w1
            }
            if match.contains(.height) {
                scaleY = h2 / h1
            }
        }
        // scaled rect
        let rect1 = CGRect(
            x: scaleX * x1 - x1,
            y: scaleY * y1 - y1,
            width: w1 * scaleX,
            height: h1 * scaleY
        )
        // match anchor based on alignment
        let anchor1 = rect1.getPoint(align.anchor)
        let anchor2 = target.getPoint(align.anchor)
        let tx = anchor2.x - anchor1.x - x1
        let ty = anchor2.y - anchor1.y - y1

        return CGAffineTransform(a: scaleX, b: 0, c: 0, d: scaleY, tx: tx, ty: ty)
    }
}

extension RectFitter {
    enum HAlign: Int, Sendable {
        case left = 1   // 1 << 0
        case center = 2 // 1 << 1
        case right = 4  // 1 << 2
        
        var ratio: Double {
            switch self {
            case .left: 0
            case .center: 0.5
            case .right: 1
            }
        }
    }
}

extension RectFitter {
    enum VAlign: Int, Sendable {
        case top = 8  // 1 << 3
        case center = 16  // 1 << 4
        case bottom = 32  // 1 << 5
        
        var ratio: Double {
            switch self {
            case .top: 0
            case .center: 0.5
            case .bottom: 1
            }
        }
    }
}

extension RectFitter {
    enum Align: Int, Sendable {
        case topLeft = 9  //VAlign.top.rawValue | HAlign.left.rawValue
        case topCenter = 10  //VAlign.top.rawValue | HAlign.center.rawValue
        case topRight = 12  //VAlign.top.rawValue | HAlign.right.rawValue

        case midLeft = 17  //VAlign.center.rawValue | HAlign.left.rawValue
        case midCenter = 18  //VAlign.center.rawValue | HAlign.center.rawValue
        case midRight = 20  //VAlign.center.rawValue | HAlign.right.rawValue

        case btmLeft = 33  //VAlign.bottom.rawValue | HAlign.left.rawValue
        case btmCenter = 34  //VAlign.bottom.rawValue | HAlign.center.rawValue
        case btmRight = 36  //VAlign.bottom.rawValue | HAlign.right.rawValue
        
        var hAlign: HAlign {
            switch self {
            case .topLeft, .midLeft, .btmLeft: .left
            case .topCenter, .midCenter, .btmCenter: .center
            case .topRight, .midRight, .btmRight: .right
            }
        }
        
        var vAlign: VAlign {
            switch self {
            case .topLeft, .topCenter, .topRight: .top
            case .midLeft, .midCenter, .midRight: .center
            case .btmLeft, .btmCenter, .btmRight: .bottom
            }
        }
        
        var anchor: CGPoint {
            CGPoint(x: hAlign.ratio, y: vAlign.ratio)
        }

        init(hAlign: HAlign, vAlign: VAlign) {
            self.init(rawValue: hAlign.rawValue | vAlign.rawValue)!
        }
    }
}

extension RectFitter {
    enum Scale: Sendable {
        enum Length: Sendable {
            case width, height, minEdge, maxEdge
        }
        struct Edge: OptionSet, Sendable {
            let rawValue: Int
            init(rawValue: Int) {
                self.rawValue = rawValue
            }
            static let width = Self(rawValue: 1 << 0)
            static let height = Self(rawValue: 1 << 1)
            static let all: Self = [width, height]
        }
        case none
        case aspect(match: Length)
        case stretch(match: Edge)
    }
}

extension RectFitter {
    struct Config: Sendable {
        var align: Align
        var scale: Scale
        
        init(align: Align, scale: Scale) {
            self.align = align
            self.scale = scale
        }
    }
}

extension RectFitter.Config {
    static let aspectFillInside: Self = .init(align: .midCenter, scale: .aspect(match: .minEdge))
    static let aspectFillOutside: Self = .init(align: .midCenter, scale: .aspect(match: .maxEdge))
    static let stretchFill: Self = .init(align: .midCenter, scale: .stretch(match: .all))
    static let alignCenter: Self = .init(align: .midCenter, scale: .none)
}

extension CGRect {
    fileprivate func getPoint(_ anchor: CGPoint) -> CGPoint {
        return CGPoint(
            x: self.origin.x + self.size.width * anchor.x,
            y: self.origin.y + self.size.height * anchor.y
        )
    }
}
