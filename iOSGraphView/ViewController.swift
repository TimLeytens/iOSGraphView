//
//  ViewController.swift
//  testpath
//
//  Created by Tim Leytens on 07/12/2018.
//  Copyright © 2018 Tim Leytens. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    private var values = [Int]()
    private var difference = 0
    private var count = 0
    private var size = CGSize.zero
    private var offsetX: Float = 0.0
    private var offsetY: Float = 0.0
    private var min = 0
    private var max = 0
    private var colorIndex = 0
    private var timer = Timer()

    @IBAction func generate(_ sender: UIButton? = nil) {
        var values = [Int]()
        for _ in 1...Int.random(in: 1 ..< 100) {
            values.append(Int.random(in: 10 ..< 20))
        }
        self.values = values
        drawGraph()
    }
    
    @IBAction func addItem(_ sender: UIButton? = nil) {
        var values = self.values
        values.remove(at: 0)
        values.append(Int.random(in: 10 ..< 20))
        self.values = values
        drawGraph()
    }
    
    @IBAction func start(_ sender: Any? = nil) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(addItem), userInfo: nil, repeats: true)
    }
    
    @IBAction func stop(_ sender: Any? = nil) {
        timer.invalidate()
    }
    
    
    @IBAction func switchColor(_ sender: UISegmentedControl) {
        colorIndex = sender.selectedSegmentIndex
        drawGraph()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generate()
    }
    
    private func drawGraph() {
        container.backgroundColor = backgroundColor(index: colorIndex)

        // Get outer values
        guard let max = values.max(), let min = values.min() else { return }
        
        self.min = min
        self.max = max
        
        // Difference between outer values
        difference = abs(min - max)
        // Total values
        count = values.count
        // Size of container view
        size = container.frame.size
        // Margin between points on x-axis
        offsetX = Float(size.width) / Float(count - 1)
        // Margin between points on y-axis
        offsetY = Float(size.height) / Float(difference)
        
        container.layer.sublayers = nil
        container.layer.addSublayer(addGraphPath(fill: true))
        container.layer.addSublayer(addGraphPath(fill: false))
    }
    
    private func addGraphPath(fill: Bool) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(origin: CGPoint.zero, size: size)
        layer.lineCap = .round
        layer.lineJoin = .round
        
        if fill {
            layer.fillColor = fillColor(index: colorIndex).cgColor
        } else {
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 1
            layer.strokeColor = UIColor.white.cgColor
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: size.height))

        for (index, _) in values.enumerated() {
            let start = pointForValue(index: index) ?? CGPoint.zero
            let end = pointForValue(index: index + 1) ?? start
            addCurvedLineSegment(start: start, end: end, path: path)
        }
        
        if fill {
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.close()
        }
        layer.path = path.cgPath
        return layer
    }
    
    private func pointForValue(index: Int) -> CGPoint? {
        if index > values.count - 1 { return nil }
        let x = offsetX * Float(index)
        let y = Float(size.height) - ((Float(values[index]) - Float(min)) * offsetY)
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    private func addCurvedLineSegment(start: CGPoint, end: CGPoint, path: UIBezierPath) {
        let difference = start.x - end.x
        var x = start.x - (difference * 0.5)
        var y = start.y
        let controlPointOne = CGPoint(x: x, y: y)
        x = end.x + (difference * 0.5)
        y = end.y
        let controlPointTwo = CGPoint(x: x, y: y)
        path.addCurve(to: end, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
    }
    
    private func backgroundColor(index: Int) -> UIColor {
        switch colorIndex {
        case 1:
            return UIColor(red:0.68, green:0.82, blue:0.45, alpha:1.0)
        case 2:
            return UIColor(red:0.86, green:0.49, blue:0.49, alpha:1.0)
        default:
            return UIColor(red:0.00, green:0.35, blue:0.61, alpha:1.0)
        }
    }
    
    private func fillColor(index: Int) -> UIColor {
        switch colorIndex {
        case 1:
            return UIColor(red:0.61, green:0.75, blue:0.36, alpha:1.0)
        case 2:
            return UIColor(red:0.81, green:0.42, blue:0.42, alpha:1.0)
        default:
            return UIColor(red:0.10, green:0.42, blue:0.65, alpha:1.0)
        }
    }
}
