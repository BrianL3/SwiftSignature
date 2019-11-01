//  SignatureCaptureViewController.swift
//  Created by Brian Ledbetter on 11/9/15.
//  Copyright © 2015 Brian Ledbetter. All rights reserved.
import UIKit
protocol SignatureCaptureDelegate {
    func signatureCaptured(completedSignature : UIImage)
}
class SignatureCaptureViewController: UIViewController {
    var signatureImage : UIImageView!
    //the delegate: the destination for the signature we will capture
    var delegate : SignatureCaptureDelegate?
    //touch contact
    var lastContactPoint1 : CGPoint?
    var lastContactPoint2 : CGPoint?
    var currentPoint : CGPoint?
    var fingerMoved : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rootView = UIView(frame: self.view.frame)
        var views = [String : AnyObject]()
        //the button container
        let saveButtonContainer = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height * 0.92, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.08))
        saveButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(saveButtonContainer)
        views.updateValue(saveButtonContainer, forKey: "saveButtonContainer")
        //the button
        let completionButton = UIButton(frame: saveButtonContainer.frame)
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionButton.setAttributedTitle(NSAttributedString(string: "done".uppercased(), attributes: [NSAttributedString.Key.kern : 1.5, NSAttributedString.Key.foregroundColor : UIColor.white]), for: UIControl.State.normal)
        completionButton.addTarget(self, action: Selector("completionButtonPressed"), for: UIControl.Event.touchUpInside)
//        completionButton.addTarget(self, action: #selector(SignatureCaptureViewController.completionButtonPressed(_:)), forControlEvents: UIControl.Event.touchUpInside)
        saveButtonContainer.addSubview(completionButton)
        //constraints for the completion button
        let horizontalCenteringConstraint = NSLayoutConstraint(item: completionButton, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: saveButtonContainer, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0)
        let verticalCenteringConstraint = NSLayoutConstraint(item: completionButton, attribute: .centerY, relatedBy: .equal, toItem: saveButtonContainer, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        saveButtonContainer.addConstraint(horizontalCenteringConstraint)
        saveButtonContainer.addConstraint(verticalCenteringConstraint)
        //the imageView
        signatureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.92))
        rootView.addSubview(signatureImage)
        signatureImage.translatesAutoresizingMaskIntoConstraints = false
        views.updateValue(signatureImage, forKey: "signatureImage")
        //create constraints
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[signatureImage(\(UIScreen.main.bounds.height * 0.92))][saveButtonContainer(\(UIScreen.main.bounds.height * 0.08))]|", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: views)
        let horizontalButtonContainerConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[saveButtonContainer]|", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: views)
        let horizontalSignatureImageConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[signatureImage]|", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: views)
        //add constraints to the rootview
        rootView.addConstraints(verticalConstraints)
        rootView.addConstraints(horizontalButtonContainerConstraints)
        rootView.addConstraints(horizontalSignatureImageConstraints)
        
        //coloring
        rootView.backgroundColor = UIColor.white
        signatureImage.backgroundColor = UIColor.white
        saveButtonContainer.backgroundColor = UIColor(red: 142.0/255.0, green: 195.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        // 8% screen height at the bottom dedicated to save button.
        self.view = rootView
    }
    //MARK: COMPLETION
    @objc func completionButtonPressed(sender : AnyObject) {
        guard let validDelegate = self.delegate else { return }
        guard let signature = signatureImage.image else { return }
        validDelegate.signatureCaptured(completedSignature: signature)
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: SIGNATURE METHODS
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                //did our finger move yet?
        fingerMoved = false
        guard let touch = touches.first else {return}
        
        //clear the image if the user taps twice
        if (touch.tapCount == 2) {
            signatureImage.image = nil
            return
        }
        
        //we need 3 points of contact to make our signature smooth using quadratic bezier curve
        currentPoint = touch.location(in: signatureImage)
        lastContactPoint1 = touch.location(in: signatureImage)
        lastContactPoint2 = touch.location(in: signatureImage)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //finger moved on the screen
        fingerMoved = true
        guard let touch = touches.first else {return}
        //save previous contact locations and update current
        lastContactPoint1 = touch.previousLocation(in: signatureImage)
        lastContactPoint2 = lastContactPoint1
        guard let point = self.currentPoint else { return }
        currentPoint = touch.location(in: signatureImage)
        //find mid points to be used for quadratic bezier curve
        let midpoint1 = self.midpoint(point1: lastContactPoint1!, point2: lastContactPoint2!)
        let midpoint2 = self.midpoint(point1: point, point2: lastContactPoint1!)
        
        //create a bitmap-based graphics context and makes it the current context
        let imageFrame = signatureImage.frame.size
        UIGraphicsBeginImageContextWithOptions(signatureImage.frame.size, false, 0.0)
        signatureImage.image?.draw(in: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imageFrame))
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        currentContext.setLineCap(CGLineCap.round)
        currentContext.setLineWidth(2.0)
        currentContext.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        currentContext.beginPath()
        currentContext.move(to: midpoint1) //new subpath
        currentContext.addQuadCurve(to: lastContactPoint1!, control: midpoint2) //create quadratic bezier curve from the current point using a control point an an end point
        
        currentContext.setMiterLimit(2.0)//set miter limit for the joins of the connected line
        //paint the line
        currentContext.strokePath()
        signatureImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let point = self.currentPoint else { return }
        if touch.tapCount == 2 { signatureImage.image = nil } // a double tap is the delete/restart command
        if fingerMoved { return }
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        let imageFrame = signatureImage.frame.size
        UIGraphicsBeginImageContextWithOptions(signatureImage.frame.size, false, 0.0)
        signatureImage.image?.draw(in: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imageFrame))
        currentContext.setLineCap(CGLineCap.round)
        currentContext.setLineWidth(2.0)
        currentContext.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        currentContext.move(to: point)
        currentContext.addLine(to: point)
        currentContext.strokePath()
        currentContext.flush()
        signatureImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
        
    //MARK: UTILITY FUNCTIONS
    //calculate midpoint between two points
    func midpoint(point1 : CGPoint, point2 : CGPoint) -> CGPoint {
        let midpoint = CGPoint(x: (point1.x + point2.x) / 2.0, y: (point1.y + point2.y) / 2.0)
        return midpoint
    }
}
