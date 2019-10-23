//: [Previous](@previous)

import Foundation
import CoreGraphics
import VisualDebugger
import UIKit

//let string = "395.857385,691.871833 416.205258,691.871833 440.74285,677.502882 464.025071,653.64645 485.086349,632.065736 502.512843,605.126383 508.983172,584.394425 513.066052,571.31223 515.034109,548.768658 515.426052,518.339778 515.608826,504.149949 515.462673,490.258903 515.048626,471.060515 515.074262,472.249217 514.769837,458.517865 514.710399,455.422465 513.454395,390.012333 460.716218,337.430968 395.857385,337.430968 331.866685,337.430968 280.263459,389.318475 276.262562,455.484204 273.900628,494.545204 276.610344,558.923859 283.498406,584.450528 289.259337,605.80013 306.223152,632.714156 327.516576,654.355108 350.507923,677.721694 375.277583,691.871833 395.857385,691.871833"
//
//let lines = string.split(separator: " ")
//var points = [String]()
//for line in lines {
//    let words = line.split(separator: ",")
//    let x = words[0]
//    let y = words[1]
//    points.append("CGPoint(x: \(x), y: \(y))")
//}
//
//print(points.joined(separator: ","))

let points: [CGPoint] = [CGPoint(x: 395.857385, y: 691.871833),CGPoint(x: 416.205258, y: 691.871833),CGPoint(x: 440.74285, y: 677.502882),CGPoint(x: 464.025071, y: 653.64645),CGPoint(x: 485.086349, y: 632.065736),CGPoint(x: 502.512843, y: 605.126383),CGPoint(x: 508.983172, y: 584.394425),CGPoint(x: 513.066052, y: 571.31223),CGPoint(x: 515.034109, y: 548.768658),CGPoint(x: 515.426052, y: 518.339778),CGPoint(x: 515.608826, y: 504.149949),CGPoint(x: 515.462673, y: 490.258903),CGPoint(x: 515.048626, y: 471.060515),CGPoint(x: 515.074262, y: 472.249217),CGPoint(x: 514.769837, y: 458.517865),CGPoint(x: 514.710399, y: 455.422465),CGPoint(x: 513.454395, y: 390.012333),CGPoint(x: 460.716218, y: 337.430968),CGPoint(x: 395.857385, y: 337.430968),CGPoint(x: 331.866685, y: 337.430968),CGPoint(x: 280.263459, y: 389.318475),CGPoint(x: 276.262562, y: 455.484204),CGPoint(x: 273.900628, y: 494.545204),CGPoint(x: 276.610344, y: 558.923859),CGPoint(x: 283.498406, y: 584.450528),CGPoint(x: 289.259337, y: 605.80013),CGPoint(x: 306.223152, y: 632.714156),CGPoint(x: 327.516576, y: 654.355108),CGPoint(x: 350.507923, y: 677.721694),CGPoint(x: 375.277583, y: 691.871833),CGPoint(x: 395.857385, y: 691.871833)]

let path = UIBezierPath()
path.move(to: points[0])
for i in stride(from: 1, to: points.count, by: 3) {
    let p1 = points[i]
    let p2 = points[i+1]
    let p3 = points[i+2]
    path.addCurve(to: p3, controlPoint1: p1, controlPoint2: p2)
}
path.debugView

let bounds = points.bounds
var newPoints = [CGPoint]()
for point in points {
    let offseted = CGPoint(x: point.x - bounds.origin.x, y: point.y - bounds.origin.y)
    let scaled = CGPoint(x: offseted.x * (1/bounds.width), y: offseted.y * (1/bounds.height))
    newPoints.append(scaled)
}

let final = newPoints.map{
    return "\($0.x), \($0.y)"
}.joined(separator: "\n")
print(final)

