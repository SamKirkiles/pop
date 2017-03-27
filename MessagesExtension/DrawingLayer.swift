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
    
    private var predictedLine:Line?
    
    func drawLine(line: Line) {
        self.drawLine = line
        self.setNeedsDisplay()
    }
    func clear(){
        self.drawLine = nil
        self.setNeedsDisplay()
    }
    
    override func draw(in ctx: CGContext) {
        self.drawsAsynchronously = true
        if let line = drawLine{
            
            ctx.clip(to: self.frame)
            ctx.beginPath()
            ctx.setStrokeColor(line.drawColor)
            ctx.setLineCap(CGLineCap.round)
            ctx.setLineWidth(line.width * ((self.frame.width+self.frame.height)/(line.rect.width+line.rect.height)))
            self.contentsScale = 2

            //draw our line
            for segment in line.segments{
                
                ctx.move(to: CGPoint(x: segment.start.x, y: segment.start.y))
                
                ctx.addCurve(to: segment.end, control1: segment.second, control2: segment.third)
                
                print("The segment we are drawing is : ", segment)
                
            }
            ctx.strokePath()
        }else{
            
            //dont worry
        }
        
    }
    
}


