//
//  ContentView.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import AVFoundation

protocol ContentViewDelegate {
    func drawLine(line: Line)
}

class ContentView: UIView, DrawViewControllerScrollDelegate {
    
    var image:UIImage?
    
    var drawImageLayer:DrawingLayer?
    var tempLine:Line?
    
    var lastPoint:CGPoint?
    
    var savedLines:[Line] = []
    
    var drawingDelegate:ContentViewDelegate? = nil
    
    var zoom:CGFloat = 1.0

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.startup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.startup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawImageLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func startup(){
        self.drawImageLayer = DrawingLayer()
        self.drawImageLayer?.backgroundColor = UIColor.clear.cgColor
        self.drawingDelegate = self.drawImageLayer
        self.layer.addSublayer(drawImageLayer!)

    }
    
    //MARK: Touch methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //get all touches 
        //create a new line and send to delegate
        
        
        guard let touch = touches.first else{
            fatalError("touches.first was nil")
        }
        
        lastPoint = touch.location(in: self)
        self.tempLine = Line(drawColor: UIColor.red.cgColor, width: 3.0, rect: self.frame)
        let start = touch.location(in: self)
        self.tempLine?.addSegment(start: start, end: start)
        self.drawingDelegate?.drawLine(line: tempLine!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //get all touches
        //add to temp line
        //update delegate each time
        guard let touch = touches.first, let event = event else{
            fatalError("event or touch returned nil")
        }
        
        if let touches = event.coalescedTouches(for: touch){
            for touch in touches{
                self.tempLine?.addSegment(start: lastPoint!, end: touch.location(in: self))
                lastPoint! = touch.location(in: self)
                self.drawingDelegate?.drawLine(line: tempLine!)
            }
        }else{
            fatalError("touches returned nil")
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let line = self.tempLine{
            self.savedLines.append(line)
            self.setNeedsDisplay()
            self.drawImageLayer?.clear()
        }else{
            fatalError("templine was nil!")
        }
    }
    
    
    
    override func draw(_ rect: CGRect) {
        guard let image = self.image else {
            fatalError("Content view did not have valid image assigned!")
        }
        
        image.draw(in: rect)
        
        guard let context = UIGraphicsGetCurrentContext() else{
            fatalError("context returned nil!")
        }
        
        for line in self.savedLines{
            context.setLineWidth(line.width)
            context.setLineCap(.round)
            context.setStrokeColor(line.drawColor)
            print(line.rect)
            for segment in line.segments{
                
                let startx = (segment.start.x * self.frame.width)/line.rect.width
                let starty = (segment.start.y * self.frame.height)/line.rect.height
                
                let endx = (segment.end.x * self.frame.width)/line.rect.width
                let endy = (segment.end.y * self.frame.height)/line.rect.height
                
                context.moveTo(x: startx, y: starty)
                context.addLineTo(x: endx, y: endy)
            }
            
            //context.stroke(rect)
            context.strokePath()
        }
    }
    
    func zoomChanged(value: CGFloat) {
        // the user is zooming in
    }
    
}

extension CGPoint{
    
}
