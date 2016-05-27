//
//  ViewController.swift
//  Bezier Curve
//
//  Created by Vegard Solheim Theriault on 26/05/16.
//  Copyright © 2016 Vegard Solheim Theriault. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bezierView: BezierCurve!
    @IBOutlet weak var numberOfSegmentsSlider: UISlider!
    @IBOutlet weak var numberOfSegmentsLabel: UILabel!
    @IBOutlet weak var curveSelector: UISegmentedControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        numberOfSegmentsLabel.text = "\(bezierView.numberOfLineSegments)"
        numberOfSegmentsSlider.value = Float(bezierView.numberOfLineSegments)
    }
    
    
    
    // -------------------------------
    // MARK: Actions
    // -------------------------------
    
    @IBAction func didChangeNumberOfSegments() {
        bezierView.numberOfLineSegments = Int(numberOfSegmentsSlider.value)
        numberOfSegmentsLabel.text = "\(bezierView.numberOfLineSegments)"
    }

    @IBAction func curveTypeDidChange() {
        bezierView.degree = selectedCurveType()
    }
    
    private func selectedCurveType() -> BezierCurve.BezierDegree {
        switch curveSelector.selectedSegmentIndex {
            case 0: return .Linear
            case 1: return .Quadratic
            case 2: return .Cubic
            default: return .Cubic
        }
    }

}

