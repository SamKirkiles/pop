//
//  DrawingLayer.swift
//  pop
//
//  Created by Sam Kirkiles on 8/16/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

class DrawingLayer: CALayer {
    
    var currentLine:Line?

    //this class will draw all of our lines in it!!!
    // this class only needs to draw our new line
    
    override func draw(in ctx: CGContext) {
        ctx.setLineCap(.round)
        ctx.setStrokeColor(UIColor.purple.cgColor)
        ctx.setLineWidth(5.0)
        ctx.addPath(currentLine!.path.cgPath)
        ctx.strokePath()
    }

}
