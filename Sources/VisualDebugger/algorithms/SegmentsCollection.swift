//
//  SegmentsCollection.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//


import Foundation

extension Collection {
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

struct SegmentsCollection<Base: Collection> {
    internal let base: Base
    internal let isClosed: Bool

    internal init(base: Base, isClosed: Bool) {
        self.base = base
        self.isClosed = isClosed
    }
}

extension SegmentsCollection: Collection {
    typealias Element = (start: Base.Element, end: Base.Element)
    typealias Index = Base.Index

    var isEmpty: Bool {
        guard !base.isEmpty else { return true }
        if !isClosed { // open
            return base.count < 2
        } else {
            return base.isEmpty
        }
    }

    var count: Int {
        base.isEmpty ? 0 : base.count - 1
    }

    var startIndex: Index {
        return base.startIndex
    }

    var endIndex: Index {
        if isClosed {
            return base.endIndex
        } else {
            return base.index(base.endIndex, offsetBy: -1)
        }
    }

    var lastIndex: Index {
        return base.index(base.endIndex, offsetBy: -1)
    }

    subscript(position: Index) -> Element {
        let start = base[position]
        let end: Base.Element
        if position == lastIndex {
            end = base[base.startIndex]
        } else {
            end = base[base.index(after: position)]
        }
        return (start, end)
    }

    func index(after i: Index) -> Index {
        precondition(i != endIndex, "Advancing past end index")
        return base.index(after: i)
    }
    
    func makeIterator() -> SegmentsIterator<Base> {
        return SegmentsIterator(base: self)
    }
}

struct SegmentsIterator<T: Collection>: IteratorProtocol {
    typealias Base = SegmentsCollection<T>
    private var base: Base
    private var position: Base.Index

    init(base: Base) {
        self.base = base
        self.position = base.startIndex
    }

    mutating func next() -> Base.Element? {
        guard !self.base.isEmpty else { return nil }
        guard self.position >= base.startIndex, self.position < base.endIndex else { return nil }
        let result = base[position]
        self.position = base.index(after: position)
        return result
    }
}

extension SegmentsCollection: BidirectionalCollection where Base: BidirectionalCollection {
    func index(before i: Index) -> Index {
        precondition(i != startIndex, "Incrementing past start index")
        return base.index(before: i)
    }
}

extension SegmentsCollection: LazySequenceProtocol, LazyCollectionProtocol where Base: LazySequenceProtocol {}
