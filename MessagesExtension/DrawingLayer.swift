//
//  DrawingLayer.swift
//  pop
//
//  Created by Sam Kirkiles on 8/16/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

class DrawingLayer: CALayer, ContentViewDelegate {
    
    private var drawLine:Line?
    
    func drawLine(line: Line) {
        self.drawLine = line
        self.setNeedsDisplay()
    }
    
    func clear(){
        self.drawLine = nil
        self.setNeedsDisplay()
    }
    
    override func draw(in ctx: CGContext) {
        if let line = drawLine{
            ctx.clip(to: self.frame)
            ctx.beginPath()
            ctx.setStrokeColor(UIColor.blue.cgColor)
            ctx.setLineCap(CGLineCap.round)
            ctx.setLineWidth(5.0)

            //draw our line
            for segment in line.segments{
                ctx.moveTo(x: segment.start.x, y: segment.start.y)
                ctx.addLineTo(x: segment.end.x, y: segment.end.y)
            }
            ctx.strokePath()
            //ctx.stroke(self.frame)
        }else{
            print("tried to draw line but it was nil so moving on without fatalerror")
        }
                
    }
    
}


