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
            var count = 0;
            for segment in line.segments{
                
                var startPoint = segment.start
                let secondPoint = segment.second
                let thirdPoint = segment.third
                var endPoint = segment.end
                
                if count > 0{
                    let previousThirdPoint = CGPoint(x: (line.segments[count - 1].third.x * self.frame.width)/line.rect.width, y: (line.segments[count - 1].third.y * self.frame.height)/line.rect.height)
                    //set the startpoint to the midpoint between the two points
                    startPoint = CGPoint(x: (secondPoint.x + previousThirdPoint.x)/2, y: (secondPoint.y + previousThirdPoint.y)/2)
                }
                
                
                if count + 1 < line.segments.count{
                    let nextSecondPoint = CGPoint(x: (line.segments[count + 1].second.x * self.frame.width)/line.rect.width, y: (line.segments[count + 1].second.y * self.frame.height)/line.rect.height)
                    endPoint = CGPoint(x: (thirdPoint.x+nextSecondPoint.x)/2, y: (thirdPoint.y+nextSecondPoint.y)/2)
                    
                }

                
                ctx.move(to: startPoint)
                ctx.addCurve(to: endPoint, control1: secondPoint, control2: thirdPoint)
                
                count += 1;
            }
            ctx.strokePath()
        }else{
            
            //dont worry
        }
        
    }
    
}


