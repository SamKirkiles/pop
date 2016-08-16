//
//  Line.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import Foundation
import UIKit

class Line {
    var path:UIBezierPath = UIBezierPath()
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
    func addPoint(point:CGPoint){
        path.addLine(to: point)
        path.move(to: point)
    }
    
    func clearPath(){
        path.removeAllPoints()
    }
}
