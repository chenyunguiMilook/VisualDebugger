//: Playground - noun: a place where people can play

import UIKit
import VisualDebugger

let points3:[CGPoint] = [CGPoint(x:0.563261, y: 0.250566),
                         CGPoint(x:0.615790, y: 0.251568),
                         CGPoint(x:0.661398, y: 0.259710),
                         CGPoint(x:0.699854, y: 0.273847),
                         CGPoint(x:0.741539, y: 0.304975),
                         CGPoint(x:0.778933, y: 0.349805),
                         CGPoint(x:0.804234, y: 0.418417),
                         CGPoint(x:0.828084, y: 0.488449),
                         CGPoint(x:0.828877, y: 0.568929),
                         CGPoint(x:0.824471, y: 0.640248),
                         CGPoint(x:0.798722, y: 0.685895),
                         CGPoint(x:0.769048, y: 0.724694),
                         CGPoint(x:0.731141, y: 0.742849),
                         CGPoint(x:0.689275, y: 0.753316),
                         CGPoint(x:0.652157, y: 0.756108),
                         CGPoint(x:0.608883, y: 0.754526),
                         CGPoint(x:0.559672, y: 0.741766),
                         CGPoint(x:0.473791, y: 0.323460),
                         CGPoint(x:0.448061, y: 0.366450),
                         CGPoint(x:0.442818, y: 0.418421),
                         CGPoint(x:0.451221, y: 0.467508),
                         CGPoint(x:0.473121, y: 0.506806),
                         CGPoint(x:0.473209, y: 0.568182),
                         CGPoint(x:0.456134, y: 0.604281),
                         CGPoint(x:0.450895, y: 0.643387),
                         CGPoint(x:0.459804, y: 0.681021),
                         CGPoint(x:0.485578, y: 0.709309),
                         CGPoint(x:0.503393, y: 0.546038),
                         CGPoint(x:0.525364, y: 0.552335),
                         CGPoint(x:0.548114, y: 0.559750),
                         CGPoint(x:0.571130, y: 0.568064),
                         CGPoint(x:0.615884, y: 0.505096),
                         CGPoint(x:0.619026, y: 0.532759),
                         CGPoint(x:0.621966, y: 0.562555),
                         CGPoint(x:0.618286, y: 0.587124),
                         CGPoint(x:0.613874, y: 0.610654),
                         CGPoint(x:0.513423, y: 0.378370),
                         CGPoint(x:0.497477, y: 0.411246),
                         CGPoint(x:0.497527, y: 0.442216),
                         CGPoint(x:0.519389, y: 0.474055),
                         CGPoint(x:0.522410, y: 0.441140),
                         CGPoint(x:0.521293, y: 0.410716),
                         CGPoint(x:0.523257, y: 0.597611),
                         CGPoint(x:0.506080, y: 0.627757),
                         CGPoint(x:0.504997, y: 0.655128),
                         CGPoint(x:0.521239, y: 0.678628),
                         CGPoint(x:0.527278, y: 0.653557),
                         CGPoint(x:0.526351, y: 0.626692),
                         CGPoint(x:0.696185, y: 0.472936),
                         CGPoint(x:0.671334, y: 0.507073),
                         CGPoint(x:0.657819, y: 0.542961),
                         CGPoint(x:0.661673, y: 0.571214),
                         CGPoint(x:0.656446, y: 0.595755),
                         CGPoint(x:0.668570, y: 0.627118),
                         CGPoint(x:0.693204, y: 0.655391),
                         CGPoint(x:0.702001, y: 0.628334),
                         CGPoint(x:0.705933, y: 0.599566),
                         CGPoint(x:0.706775, y: 0.573984),
                         CGPoint(x:0.705585, y: 0.543364),
                         CGPoint(x:0.701212, y: 0.510988),
                         CGPoint(x:0.680194, y: 0.545555),
                         CGPoint(x:0.679640, y: 0.572124),
                         CGPoint(x:0.678558, y: 0.594839),
                         CGPoint(x:0.684269, y: 0.599869),
                         CGPoint(x:0.685486, y: 0.577023),
                         CGPoint(x:0.684801, y: 0.549412),
                         CGPoint(x:0.596805, y: 0.475715),
                         CGPoint(x:0.570059, y: 0.488631),
                         CGPoint(x:0.569375, y: 0.614204),
                         CGPoint(x:0.596179, y: 0.627464),
                         CGPoint(x:0.516621, y: 0.272736),
                         CGPoint(x:0.439406, y: 0.308170),
                         CGPoint(x:0.370724, y: 0.409735),
                         CGPoint(x:0.354499, y: 0.520174),
                         CGPoint(x:0.373587, y: 0.626583),
                         CGPoint(x:0.441589, y: 0.718513),
                         CGPoint(x:0.515020, y: 0.747972),
                         CGPoint(x:0.409239, y: 0.538404)]

let pnts = Points.init(points: points3, representation: .indices)
pnts.debugView

let path = UIBezierPath()
path.move(to: .zero)
path.addLine(to: CGPoint(x: 10, y: 0))
path.close()

path.debugView











