//
//  Line.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import Foundation
import UIKit

struct Segment{
    var start:CGPoint
    var second: CGPoint
    var third: CGPoint
    var end:CGPoint
    
     init(start _start: CGPoint, second _second: CGPoint, third _third: CGPoint, end _end:CGPoint) {
        start = _start
        second = _second
        third = _third
        end = _end
    }
}

class Line {
    var segments:[Segment] = []
    var drawColor:CGColor
    var width:CGFloat
    var rect:CGRect
    
    init(drawColor _drawColor:CGColor, width _width:CGFloat, rect _rect:CGRect) {
        drawColor = _drawColor
        width = _width
        rect = _rect
    }
    
    func addSegment(_start:CGPoint, _second:CGPoint, _third:CGPoint, _end: CGPoint){
        let newSegment = Segment(start: _start, second: _second, third: _third, end: _end)
        self.segments.append(newSegment)
    }
    
    func clearPath(){
        segments.removeAll()
    }

}
