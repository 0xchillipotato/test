//
//  Signature.swift
//  Fisdom
//
//  Created by Arpitha Dudi on 2/25/16.
//  Copyright © 2016 finwzard. All rights reserved.
//

import Foundation
import UIKit

class Signature: UIView {
    
    // MARK: - Public properties
    open var lineWidth: CGFloat = 2.0 {
        didSet {
            self.path.lineWidth = lineWidth
        }
    }
    open var strokeColor: UIColor = UIColor.black
    open var signatureBackgroundColor: UIColor = UIColor.clear
    
    // MARK: - Private properties
    fileprivate var path = UIBezierPath()
    fileprivate var pts = [CGPoint](repeating: CGPoint(), count: 5)
    fileprivate var ctr = 0
    
    var didSign : Bool = false
    
    // MARK: - Init
    required public init?(coder aDecoder: NSCoder) {

   
        super.init(coder: aDecoder)
        
        self.backgroundColor = self.signatureBackgroundColor
        self.path.lineWidth = self.lineWidth
    }
    
    // MARK: - Draw
    override open func draw(_ rect: CGRect) {
        self.strokeColor.setStroke()
        self.path.stroke()
    }
    
    // MARK: - Touch handling functions
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didSign = true
        if let firstTouch = touches.first{
            let touchPoint = firstTouch.location(in: self)
            self.ctr = 0
            self.pts[0] = touchPoint
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first{
            let touchPoint = firstTouch.location(in: self)
            self.ctr += 1
            self.pts[self.ctr] = touchPoint
            if (self.ctr == 4) {
                self.pts[3] = CGPoint(x: (self.pts[2].x + self.pts[4].x)/2.0, y: (self.pts[2].y + self.pts[4].y)/2.0)
                self.path.move(to: self.pts[0])
                self.path.addCurve(to: self.pts[3], controlPoint1:self.pts[1], controlPoint2:self.pts[2])
                
                self.setNeedsDisplay()
                self.pts[0] = self.pts[3]
                self.pts[1] = self.pts[4]
                self.ctr = 1
            }
            
            self.setNeedsDisplay()
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.ctr == 0{
            let touchPoint = self.pts[0]
            self.path.move(to: CGPoint(x: touchPoint.x-1.0,y: touchPoint.y))
            self.path.addLine(to: CGPoint(x: touchPoint.x+1.0,y: touchPoint.y))
            self.setNeedsDisplay()
        } else {
            self.ctr = 0
        }
    }
    
    // MARK: - Helpers
    // MARK: Clear the Signature View
    open func clearSignature() {
        didSign = false
        self.path.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    // MARK: Save the Signature as an UIImage
    open func getSignature() ->UIImage {
       // self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0001)
        
       // self.backgroundColor = UIColor.clearColor()
       
        
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false , 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
       // self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let signature: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return signature
    }
}
