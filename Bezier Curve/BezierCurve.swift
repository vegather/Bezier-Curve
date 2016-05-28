//
//  BezierCurve.swift
//  Bezier Curve
//
//  Created by Vegard Solheim Theriault on 26/05/16.
//  Copyright © 2016 Vegard Solheim Theriault. All rights reserved.
//

import UIKit


extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

@IBDesignable
class BezierCurve: UIView {

    
    // -------------------------------
    // MARK: Private Variables
    // -------------------------------
    
    private let handleSize: CGFloat = 20.0
    
    private var anchor1 : HandleView!
    private var anchor2 : HandleView!
    private var control1: HandleView!
    private var control2: HandleView!
    
    private var relativeAnchor1Pos  = CGPoint(x: 0.2, y: 0.7)
    private var relativeAnchor2Pos  = CGPoint(x: 0.8, y: 0.7)
    private var relativeControl1Pos = CGPoint(x: 0.3, y: 0.3)
    private var relativeControl2Pos = CGPoint(x: 0.7, y: 0.3)
    
    
    
    
    // -------------------------------
    // MARK: Public Variables
    // -------------------------------
    
    @IBInspectable
    var numberOfLineSegments: Int = 80 {
        didSet { setNeedsDisplay() }
    }
    
    enum BezierDegree: Int {
        case Linear    = 1
        case Quadratic = 2
        case Cubic     = 3
    }
    
    var degree = BezierDegree.Cubic {
        didSet { setNeedsDisplay() }
    }
    
    
    
    
    // -------------------------------
    // MARK: Initializers
    // -------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    private func setup() {
        contentMode = .Redraw
        clipsToBounds = true
        
        anchor1  = HandleView(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
        anchor2  = HandleView(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
        control1 = HandleView(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
        control2 = HandleView(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
        
        anchor1.color  = UIColor.blackColor()
        anchor2.color  = UIColor.blackColor()
        control1.color = UIColor.lightGrayColor()
        control2.color = UIColor.lightGrayColor()
        
        addSubview(anchor1)
        addSubview(anchor2)
        addSubview(control1)
        addSubview(control2)
        
        anchor1 .addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleAnchorDidPan(_:))))
        anchor2 .addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleAnchorDidPan(_:))))
        control1.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleAnchorDidPan(_:))))
        control2.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleAnchorDidPan(_:))))
        
        setHandleFramesToRelativePositions()
    }
    
    
    
    
    // -------------------------------
    // MARK: Handle Positions
    // -------------------------------
    
    override func layoutSubviews() {
        setHandleFramesToRelativePositions()
    }
    
    private func setHandleFramesToRelativePositions() {
        anchor1.frame = CGRect(
            x     : bounds.size.width  * relativeAnchor1Pos.x - handleSize / 2,
            y     : bounds.size.height * relativeAnchor1Pos.y - handleSize / 2,
            width : handleSize,
            height: handleSize
        )
        anchor2.frame = CGRect(
            x     : bounds.size.width  * relativeAnchor2Pos.x - handleSize / 2,
            y     : bounds.size.height * relativeAnchor2Pos.y - handleSize / 2,
            width : handleSize,
            height: handleSize
        )
        control1.frame = CGRect(
            x     : bounds.size.width  * relativeControl1Pos.x - handleSize / 2,
            y     : bounds.size.height * relativeControl1Pos.y - handleSize / 2,
            width : handleSize,
            height: handleSize
        )
        control2.frame = CGRect(
            x     : bounds.size.width  * relativeControl2Pos.x - handleSize / 2,
            y     : bounds.size.height * relativeControl2Pos.y - handleSize / 2,
            width : handleSize,
            height: handleSize
        )
    }
    
    func handleAnchorDidPan(panner: UIPanGestureRecognizer) {
        guard panner.state == .Changed     else { return }
        guard let pannedView = panner.view else { return }
        
        let translation = panner.translationInView(pannedView)
        pannedView.frame.origin.x += translation.x
        pannedView.frame.origin.y += translation.y
        panner.setTranslation(CGPointZero, inView: pannedView)
        
        var relativePos = CGPoint(
            x: pannedView.frame.midX / bounds.width,
            y: pannedView.frame.midY / bounds.height
        )
        if relativePos.x < 0 { relativePos.x = 0 }
        
        if      pannedView === anchor1  { relativeAnchor1Pos  = relativePos }
        else if pannedView === anchor2  { relativeAnchor2Pos  = relativePos }
        else if pannedView === control1 { relativeControl1Pos = relativePos }
        else if pannedView === control2 { relativeControl2Pos = relativePos }
        
        setNeedsDisplay()
    }

    
    
    
    // -------------------------------
    // MARK: Drawing
    // -------------------------------
    
    override func drawRect(rect: CGRect) {
        refreshControlPointsVisibleness()
        drawHandles()
        drawGraph()
    }
    
    private func refreshControlPointsVisibleness() {
        switch degree {
            case .Linear:
                control1.hidden = true
                control2.hidden = true
            case .Quadratic:
                control1.hidden = false
                control2.hidden = true
            case .Cubic:
                control1.hidden = false
                control2.hidden = false
        }
    }
    
    private func drawGraph() {
        let path = UIBezierPath()
        path.lineWidth = 3.0
        
        for i in 0...numberOfLineSegments {
            let t = Double(i) / Double(numberOfLineSegments)
            let point = bezier(t)
            
            if i == 0 { path.moveToPoint(point) }
            else      { path.addLineToPoint(point) }
        }
        
        UIColor.blackColor().setStroke()
        path.stroke()
    }
    
    private func drawHandles() {
        UIColor.lightGrayColor().setStroke()
        
        if degree.rawValue >= 2 {
            let handle1Path = UIBezierPath()
            handle1Path.moveToPoint(anchor1.frame.center)
            handle1Path.addLineToPoint(control1.frame.center)
            if degree == .Quadratic { handle1Path.addLineToPoint(anchor2.frame.center) }
            handle1Path.lineWidth = 1.0
            handle1Path.stroke()
        }
        
        if degree.rawValue >= 3 {
            let handle2Path = UIBezierPath()
            handle2Path.moveToPoint(anchor2.frame.center)
            handle2Path.addLineToPoint(control2.frame.center)
            handle2Path.lineWidth = 1.0
            handle2Path.stroke()
        }
    }
    
    
    
    // -------------------------------
    // MARK: Bezier Computation
    // -------------------------------
    
    /**
     * Calculates a point along the bezier path based on the `t` input.
     *
     * - parameter t: A value in the range [0, 1].
     * - returns: The point along the bezier curve.
     */
    private func bezier(t: Double) -> CGPoint {
        let points: [CGPoint]
        switch degree {
            case .Linear   : points = [anchor1, anchor2]                    .map() { $0.frame.center }
            case .Quadratic: points = [anchor1, control1, anchor2]          .map() { $0.frame.center }
            case .Cubic    : points = [anchor1, control1, control2, anchor2].map() { $0.frame.center }
        }
        
        var accumulatedPoint = CGPointZero
        
        let n = degree.rawValue
        for i in 0...n {
            let value = Double(nCi(n: n, i: i)) * pow(1 - t, Double(n - i)) * pow(t, Double(i))
            accumulatedPoint.x += CGFloat(value) * points[i].x
            accumulatedPoint.y += CGFloat(value) * points[i].y
        }

        return accumulatedPoint
    }
    
    // n choose i
    private func nCi(n n: Int, i: Int) -> Int {
        return fac(n) / (fac(i) * fac(n-i))
    }
    
    // Recursive factorial (n!)
    private func fac(n: Int) -> Int {
        return n <= 1 ? 1 : n * fac(n-1)
    }
}



private class HandleView: UIView {
    
    // -------------------------------
    // MARK: Initialization
    // -------------------------------
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        opaque = false
    }
    
    
    
    // -------------------------------
    // MARK: Properties
    // -------------------------------
    
    var color: UIColor = UIColor.blackColor() {
        didSet { setNeedsDisplay() }
    }
    
    
    
    // -------------------------------
    // MARK: Drawing
    // -------------------------------
    
    private override func drawRect(rect: CGRect) {
        color.setFill()
        let path = circleWithPoint(bounds.center, radius: bounds.width / 2)
        path.fill()
    }
    
    private func circleWithPoint(point: CGPoint, radius: CGFloat) -> UIBezierPath {
        return UIBezierPath(
            arcCenter: point,
            radius: radius,
            startAngle: 0.0,
            endAngle: CGFloat(M_PI * 2),
            clockwise: true
        )
    }
    
    
    
    // -------------------------------
    // MARK: Touch Handling
    // -------------------------------
    
    private let minimumHitTarget = 50.0
    
    private override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        // Ensures a hit target of at least 40x40 points
        if point.x >= CGFloat(min(0.0                  , Double(bounds.midX) - minimumHitTarget / 2)) &&
           point.x <= CGFloat(max(Double(bounds.width) , Double(bounds.midX) + minimumHitTarget / 2)) &&
           point.y >= CGFloat(min(0.0                  , Double(bounds.midY) - minimumHitTarget / 2)) &&
           point.y <= CGFloat(max(Double(bounds.height), Double(bounds.midY) + minimumHitTarget / 2))
        {
            return self
        } else {
            return nil
        }
    }
}
