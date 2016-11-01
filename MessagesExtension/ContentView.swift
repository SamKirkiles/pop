//
//  ContentView.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import AVFoundation

protocol ZoomDelegate{
    func scrollViewIsZooming() -> Bool
}

protocol ContentViewDelegate {
    func drawLine(line: Line)
}

class ContentView: UIView, DrawViewControllerScrollDelegate, UIGestureRecognizerDelegate {
    
    var image:UIImage?
    
    var drawImageLayer:DrawingLayer?
    var tempLine:Line?
    
    var lastPoint:CGPoint?
    
    
    var savedLines:[Line] = []
    
    var drawingDelegate:ContentViewDelegate? = nil
    var zoomDelegate:ZoomDelegate? = nil
    
    var zoom:CGFloat = 1.0
    
    //Drawing Variables
    var drawColor:CGColor = #colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1).cgColor
    var drawWidth:CGFloat = 10.0
    
    
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action: nil)
        self.gestureRecognizers?.append(panGesture)
        
        
    }
    
    //MARK: Touch methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard let touch = touches.first, let event = event else{
            fatalError("event or touch returned nil")
        }
        lastPoint = touch.location(in: self)
        self.tempLine = Line(drawColor: drawColor, width: drawWidth, rect: self.frame)
        if let touches = event.coalescedTouches(for: touch){
            for touch in touches{
                self.tempLine?.addSegment(start: lastPoint!, end: touch.location(in: self))
                lastPoint! = touch.location(in: self)
            }
            self.drawingDelegate?.drawLine(line: tempLine!)
        }else{
            fatalError("touches returned nil")
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first, let event = event else{
            fatalError("event or touch returned nil")
        }
        
        if let touches = event.coalescedTouches(for: touch){
            for touch in touches{
                self.tempLine?.addSegment(start: lastPoint!, end: touch.location(in: self))
                lastPoint! = touch.location(in: self)
            }
            self.drawingDelegate?.drawLine(line: tempLine!)
            
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.drawImageLayer?.clear()
    }
    
    
    
    override func draw(_ rect: CGRect) {
        
        
        guard let image = self.image else {
            return
        }
        
        image.draw(in: rect)
        
        self.layer.drawsAsynchronously = true
        
        guard let context = UIGraphicsGetCurrentContext() else{
            fatalError("context returned nil!")
        }
        
        for line in self.savedLines{
            context.setLineWidth(line.width * ((self.frame.width+self.frame.height)/(line.rect.width+line.rect.height)))
            context.setLineCap(.round)
            context.setStrokeColor(line.drawColor)
            self.contentScaleFactor = 2
            var count = 0
            var previous = count - 1

            for segment in line.segments{
                
                var startx = (segment.start.x * self.frame.width)/line.rect.width
                var starty = (segment.start.y * self.frame.height)/line.rect.height
                
                let endx = (segment.end.x * self.frame.width)/line.rect.width
                let endy = (segment.end.y * self.frame.height)/line.rect.height
                
                //the end of this curve and the beginning of the next have to be the same
                
                count += 1
                previous =  count - 1
                
                if count < line.segments.count{
                    
                    let nextSegment = line.segments[count]
                    
                    let nextstartx = (nextSegment.start.x * self.frame.width)/line.rect.width
                    let nextstarty = (nextSegment.start.y * self.frame.height)/line.rect.height
                    
                    var nextendx = (nextSegment.end.x * self.frame.width)/line.rect.width
                    var nextendy = (nextSegment.end.y * self.frame.height)/line.rect.height
                    
                    if previous >= 0{
                        let previousSegment = line.segments[previous]
                        
                        let previousstartx = (previousSegment.start.x * self.frame.width)/line.rect.width
                        let previousstarty = (previousSegment.start.y * self.frame.height)/line.rect.height
                        
                        
                        //this is going to be the midpoint between the two tanjents
                        
                        startx = (previousstartx+endx)/2.0
                        starty = (previousstarty+endy)/2.0
                        
                    }
                    
                    if count + 1 < line.segments.count{
                        let nextlinebegin = line.segments[count + 1]
                        
                        
                        let nextlinebeginendx = (nextlinebegin.start.x * self.frame.width)/line.rect.width
                        let nextlinebeginendy = (nextlinebegin.start.y * self.frame.height)/line.rect.height
                        nextendx = (nextstartx + nextlinebeginendx)/2
                        nextendy = (nextstarty + nextlinebeginendy)/2

                    }
                    context.move(to: CGPoint(x: startx, y: starty))

                    context.addCurve(to: CGPoint(x:nextendx, y:nextendy), control1: CGPoint(x: endx, y: endy), control2: CGPoint(x: nextstartx, y: nextstarty))

                }
            }
                        context.strokePath()
        }
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let delegate = self.zoomDelegate else{
            fatalError("zoom delegate was nil")
        }
        
        let iszoom = delegate.scrollViewIsZooming()
        
        return !iszoom
    }
    
    func undo(){
        if self.savedLines.count > 0{
            self.savedLines.removeLast()
            self.setNeedsDisplay()
        }
    }
    
    func changeColor(color:CGColor){
        self.drawColor = color
    }
    
    func changeWidth(width:CGFloat){
        self.drawWidth = width
    }
    
    func zoomChanged(value: CGFloat) {
        // the user is zooming in
        self.zoom = value
    }
    
}
