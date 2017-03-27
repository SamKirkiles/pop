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
    
    
    
    var savedLines:[Line] = []
    
    var drawingDelegate:ContentViewDelegate? = nil
    var zoomDelegate:ZoomDelegate? = nil
    
    var zoom:CGFloat = 1.0
    
    
    //Drawing variables
    
    var globalCounter = 0
    var lastPoint:CGPoint?
    var second:CGPoint?
    var third:CGPoint?
    var fourth:CGPoint?


    
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
    
    func addTouches(touches:Set<UITouch>, event: UIEvent){

        guard let touch = touches.first else{
            fatalError("event or touch returned nil")
        }
        
        guard let touches = event.coalescedTouches(for: touch) else{
            fatalError("touches returned nil")
        }
        
        
        
            for touch in touches{
                if self.globalCounter == 3{
                    self.globalCounter = 0;
                    self.tempLine?.addSegment(_start: lastPoint!, _second: second!, _third: third!, _end: touch.location(in: self))
                    lastPoint! = touch.location(in: self)
                    
                    print("Templline: ", tempLine!.segments.count)

                }else{
                    switch self.globalCounter {
                    case 0:
                        break;
                    case 1:
                        second = touch.location(in: self)

                        break;
                    case 2:
                        third = touch.location(in: self)

                        break;
                    case 3:

                        break;
                    default:
                        fatalError("There was a major error with touches")
                        break;
                    }
                    self.globalCounter += 1;
                    print(self.globalCounter)
                }
                
            }
        
        self.drawingDelegate?.drawLine(line: tempLine!)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        

        guard let touchEvent = event else{
            fatalError("Event was nil on Touches began in ContentView")
        }
        
        guard let touch = touches.first else{
            fatalError("Could not access first touch")
        }
        
        self.tempLine = Line(drawColor: drawColor, width: drawWidth, rect: self.frame)
        lastPoint = touch.location(in: self)
        self.globalCounter = 0;

        addTouches(touches: touches, event: touchEvent)

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchEvent = event else{
            fatalError("Event was nil on Touches began in ContentView")
        }
        addTouches(touches: touches, event: touchEvent)
        

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
        //initial setup
        
        self.layer.drawsAsynchronously = true
        guard let context = UIGraphicsGetCurrentContext() else{
            fatalError("Context returned nil on Content View")
        }

        for line in self.savedLines{
            context.setLineWidth(line.width * ((self.frame.width+self.frame.height)/(line.rect.width+line.rect.height)))
            context.setLineCap(.round)
            context.setStrokeColor(line.drawColor)
            self.contentScaleFactor = 2

            var count = 0;
            
            for segment in line.segments{
                

                //get startpoint and endpoint of the lines we want to use and make sure the points are in the correct coordinate space
                let startPoint = CGPoint(x: (segment.start.x * self.frame.width)/line.rect.width, y: (segment.start.y * self.frame.height)/line.rect.height)
                let secondPoint = CGPoint(x: (segment.second.x * self.frame.width)/line.rect.width , y: (segment.second.y * self.frame.height)/line.rect.height)
                let thirdPoint = CGPoint(x: (segment.third.x * self.frame.width)/line.rect.width , y: (segment.third.y * self.frame.height)/line.rect.height)
                let endPoint = CGPoint(x:(segment.end.x * self.frame.width)/line.rect.width, y: (segment.end.y * self.frame.height)/line.rect.height)
                
                count += 1;
                
                context.move(to: startPoint)
                context.addCurve(to: endPoint, control1: secondPoint, control2: thirdPoint)
            }
        }
        context.strokePath()
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    
    
//    override func draw(_ rect: CGRect) {
//        
//        self.layer.drawsAsynchronously = true
//        
//        guard let context = UIGraphicsGetCurrentContext() else{
//            fatalError("context returned nil!")
//        }
//        
//        //Loop through all the lines in the saved lines array
//        for line in self.savedLines{
//            //Set the line settings
//            context.setLineWidth(line.width * ((self.frame.width+self.frame.height)/(line.rect.width+line.rect.height)))
//            context.setLineCap(.round)
//            context.setStrokeColor(line.drawColor)
//            self.contentScaleFactor = 2
//            var count = 0
//            var previous = count - 1
//
//            //Go through each segment in the line segments
//            for segment in line.segments{
//                
//                var startx = (segment.start.x * self.frame.width)/line.rect.width
//                var starty = (segment.start.y * self.frame.height)/line.rect.height
//                
//                var startpoint = CGPoint(x: startx, y: starty)
//                
//                let endx = (segment.end.x * self.frame.width)/line.rect.width
//                let endy = (segment.end.y * self.frame.height)/line.rect.height
//                
//                var endpoint = CGPoint(x:endx, y: endy)
//                
//                //the end of this curve and the beginning of the next have to be the same
//                
//                count += 1
//                previous =  count - 1
//                
//                if count < line.segments.count{
//                    
//                    let nextSegment = line.segments[count]
//                    
//                    let nextstartx = (nextSegment.start.x * self.frame.width)/line.rect.width
//                    let nextstarty = (nextSegment.start.y * self.frame.height)/line.rect.height
//                    
//                    
//                    var nextendx = (nextSegment.end.x * self.frame.width)/line.rect.width
//                    var nextendy = (nextSegment.end.y * self.frame.height)/line.rect.height
//                    
//                    if previous >= 0{
//                        let previousSegment = line.segments[previous]
//                        
//                        let previousstartx = (previousSegment.start.x * self.frame.width)/line.rect.width
//                        let previousstarty = (previousSegment.start.y * self.frame.height)/line.rect.height
//                        
//                        
//                        //this is going to be the midpoint between the two tanjents
//                        
//                        startx = (previousstartx+endx)/2.0
//                        starty = (previousstarty+endy)/2.0
//                        
//                    }
//                    
//                    if count + 1 < line.segments.count{
//                        let nextlinebegin = line.segments[count + 1]
//                        
//                        
//                        let nextlinebeginendx = (nextlinebegin.start.x * self.frame.width)/line.rect.width
//                        let nextlinebeginendy = (nextlinebegin.start.y * self.frame.height)/line.rect.height
//                        nextendx = (nextstartx + nextlinebeginendx)/2
//                        nextendy = (nextstarty + nextlinebeginendy)/2
//
//                    }
//                    context.move(to: CGPoint(x: startx, y: starty))
//
//                    context.addCurve(to: CGPoint(x:nextendx, y:nextendy), control1: CGPoint(x: endx, y: endy), control2: CGPoint(x: nextstartx, y: nextstarty))
//
//                }
//            }
//            context.strokePath()
//        }
//    }
    
    
    
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
