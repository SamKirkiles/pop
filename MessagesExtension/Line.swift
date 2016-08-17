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
    var end:CGPoint
    
    init(start _start: CGPoint, end _end:CGPoint) {
        start = _start
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
}

extension Line{
    func addSegment(start:CGPoint, end: CGPoint){
        let newSegment = Segment(start: start, end: end)
        self.segments.append(newSegment)
    }
    
    func clearPath(){
        segments.removeAll()
    }
}
