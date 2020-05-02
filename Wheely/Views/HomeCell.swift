//
//  HomeCell.swift
//  Wheely
//
//  Created by Student on 2020-04-05.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class HomeCell: BaseCell {
    
    var shapeLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    var pulsatingLayer = CAShapeLayer()
    var nrOfReadyConnections = Int(0)
    
    var running = false
    
    let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        return label
    }()
    
    var home: HomeModel? {
        didSet {
            if(home?.ready == true) {
                changeColorToReadyGreen()
            } else {
                changeColorToNotReadyRed()
            }
            
            reloadInputViews()
        }
    }
    
    let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        // Enable autolayout.
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return view
    }()
    
    
    
    override func setupViews() {
        
        buttonView.frame = self.frame
    
        // Setup circular pulsating button.
        
        setupCircleLayers()
        
        // Setup progress label.
        
        setupProgressLabel()
        
        // Gesture recognizer.
        
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapStart)))
        
        addSubview(buttonView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: buttonView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: buttonView)
        
    }
    
    private func setupProgressLabel() {
        // Progress label.
        
        progressLabel.frame = buttonView.frame
        progressLabel.center = center
        buttonView.addSubview(progressLabel)
    }
    
    private func setupCircleLayers() {
        // Pulsating layer.
        
        let viewLayer = buttonView.layer
        
        pulsatingLayer = createShapeLayer(strokeColor: .clear, lineWidth: 10, fillColor: UIColor.rgb(red: 102, green: 0, blue: 0))
        viewLayer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        // Track layer.
        
        trackLayer = createShapeLayer(strokeColor: UIColor.rgb(red: 64, green: 64, blue: 64), lineWidth: 10, fillColor: .clear)
        viewLayer.addSublayer(trackLayer)
        
        
        // Setup shape layer.
        
        shapeLayer = createShapeLayer(strokeColor: UIColor.rgb(red: 204, green: 0, blue: 0), lineWidth: 10, fillColor: .systemGray5)
        shapeLayer.strokeEnd = 0
        viewLayer.addSublayer(shapeLayer)
    }
    
    private func createShapeLayer(strokeColor: UIColor, lineWidth: CGFloat, fillColor: UIColor) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 70, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        layer.path = circularPath.cgPath
        
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = CAShapeLayerLineCap.round
        layer.fillColor = fillColor.cgColor
        layer.position = buttonView.center
        
        return layer
    }
    
    func animatePulsatingLayer() {
        let basicAnimation = CABasicAnimation(keyPath: "transform.scale")
        basicAnimation.toValue = 1.2
        basicAnimation.duration = 1
        basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        basicAnimation.autoreverses = true
        basicAnimation.repeatCount = Float.infinity
        basicAnimation.isRemovedOnCompletion = false
        pulsatingLayer.add(basicAnimation, forKey: "pulsating")
    }
    
    func animateCircle() {
        
        CATransaction.begin()
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        CATransaction.setCompletionBlock {
            
            if(self.running) {
                self.running = false
                self.homeController?.endSession()
                self.progressLabel.text = "Start"
            } else {
                self.running = true
                self.homeController?.startSession()
                self.progressLabel.text = "Connecting"
            }

        }
        
        shapeLayer.add(basicAnimation, forKey: "hello")
        CATransaction.commit()
    }

    func changeColorToReadyGreen() {
        shapeLayer.strokeColor = UIColor.rgb(red: 0, green: 255, blue: 0).cgColor
        self.progressLabel.text = "Running"
    }
    
    func changeColorToNotReadyRed() {
        shapeLayer.strokeColor = UIColor.rgb(red: 204, green: 0, blue: 0).cgColor
    }
    
    @objc private func handleTapStart() {
        if(hasEnteredProfile()) {
            animateCircle()
        } else {
            self.homeController?.showUserProfile()
        }
    }
    
    fileprivate func hasEnteredProfile() -> Bool {
        return UserDefaults.standard.hasEnteredProfile()
    }
    
}
