//
//  SegmentsCollection.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//


import Foundation

public extension Collection {
    func segments(isClosed: Bool) -> SegmentsCollection<Self> {
        SegmentsCollection(base: self, isClosed: isClosed)
    }

    func closeSegments() -> SegmentsCollection<Self> {
        SegmentsCollection(base: self, isClosed: true)
    }

    func openSegments() -> SegmentsCollection<Self> {
        SegmentsCollection(base: self, isClosed: false)
    }
}

public struct SegmentsCollection<Base: Collection> {
    internal let base: Base
    internal let isClosed: Bool

    internal init(base: Base, isClosed: Bool) {
        self.base = base
        self.isClosed = isClosed
    }
}

extension SegmentsCollection: Collection {
    public typealias Element = (start: Base.Element, end: Base.Element)
    public typealias Index = Base.Index

    public var isEmpty: Bool {
        guard !base.isEmpty else { return true }
        if !isClosed { // open
            return base.count < 2
        } else {
            return base.isEmpty
        }
    }

    public var count: Int {
        base.isEmpty ? 0 : base.count - 1
    }

    public var startIndex: Index {
        return base.startIndex
    }

    public var endIndex: Index {
        if isClosed {
            return base.endIndex
        } else {
            return base.index(base.endIndex, offsetBy: -1)
        }
    }

    public var lastIndex: Index {
        return base.index(base.endIndex, offsetBy: -1)
    }

    public subscript(position: Index) -> Element {
        let start = base[position]
        let end: Base.Element
        if position == lastIndex {
            end = base[base.startIndex]
        } else {
            end = base[base.index(after: position)]
        }
        return (start, end)
    }

    public func index(after i: Index) -> Index {
        precondition(i != endIndex, "Advancing past end index")
        return base.index(after: i)
    }
    
    public func makeIterator() -> SegmentsIterator<Base> {
        return SegmentsIterator(base: self)
    }
}

public struct SegmentsIterator<T: Collection>: IteratorProtocol {
    public typealias Base = SegmentsCollection<T>
    private var base: Base
    private var position: Base.Index

    public init(base: Base) {
        self.base = base
        self.position = base.startIndex
    }

    public mutating func next() -> Base.Element? {
        guard !self.base.isEmpty else { return nil }
        guard self.position >= base.startIndex, self.position < base.endIndex else { return nil }
        let result = base[position]
        self.position = base.index(after: position)
        return result
    }
}

extension SegmentsCollection: BidirectionalCollection where Base: BidirectionalCollection {
    public func index(before i: Index) -> Index {
        precondition(i != startIndex, "Incrementing past start index")
        return base.index(before: i)
    }
}

extension SegmentsCollection: LazySequenceProtocol, LazyCollectionProtocol where Base: LazySequenceProtocol {}
