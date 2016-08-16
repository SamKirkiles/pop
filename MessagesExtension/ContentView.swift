//
//  ContentView.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

class ContentView: UIView {
    
    var image:UIImage?
    var editedImage:UIImage?
    
    var savedLines:[Line] = []
    var currentLine:Line?
    
    var drawImageLayer:DrawingLayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawImageLayer = DrawingLayer()
        self.drawImageLayer?.frame = self.frame
        self.drawImageLayer?.backgroundColor = UIColor.clear.cgColor
        self.layer.addSublayer(drawImageLayer!)
    }
    
    func clear(){
        self.savedLines.removeAll()
        self.setNeedsDisplay()
    }
    
    func undo(){
        self.savedLines.removeLast()
        self.setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, event = event else
        {
            fatalError("Event or touches was nil")
        }
        
        print(self.frame)
        print(drawImageLayer!.frame)
        if let coascaledTouches = event.coalescedTouches(for: touch){
            for coascaledTouch in coascaledTouches{
                currentLine = Line(drawColor: UIColor.red.cgColor, width: 4.0, rect: CGRect.zero)
                currentLine?.addPoint(point: coascaledTouch.location(in: self))
                self.drawImageLayer?.currentLine = Line(drawColor: UIColor.red.cgColor, width: 4.0, rect: CGRect.zero)
                self.drawImageLayer?.currentLine?.addPoint(point: coascaledTouch.location(in: self))
                self.drawImageLayer?.setNeedsDisplay()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, event = event else
        {
            fatalError("Event or touches was nil")
        }
        
        if let coascaledTouches = event.coalescedTouches(for: touch){
            for coascaledTouch in coascaledTouches{
                let locationInView = coascaledTouch.location(in: self)
       
                currentLine?.addPoint(point: locationInView)
                self.drawImageLayer?.currentLine?.addPoint(point: coascaledTouch.location(in: self))
                self.drawImageLayer?.setNeedsDisplay()
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        savedLines.append(currentLine!)
        self.setNeedsDisplay()
        
        drawImageLayer?.currentLine?.clearPath()
        drawImageLayer?.setNeedsDisplay()

    }
    
    override func draw(_ rect: CGRect) {
        guard let image = self.image else {
            fatalError("Content view did not have valid image assigned!")
        }
        
        image.draw(in: rect)
        
        print("update")
                
        for line in self.savedLines{
            line.path.lineWidth = line.width
            UIColor.blue.setStroke()
            line.path.lineCapStyle = .round
            line.path.stroke()

        }

    }
    
}

extension UIBezierPath{
    
}
