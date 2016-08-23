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
        let saveButtonContainer = UIView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height * 0.92, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height * 0.08))
        saveButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(saveButtonContainer)
        views.updateValue(saveButtonContainer, forKey: "saveButtonContainer")
        //the button
        let completionButton = UIButton(frame: saveButtonContainer.frame)
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionButton.setAttributedTitle(NSAttributedString(string: "done".uppercaseString, attributes: [NSKernAttributeName : 1.5, NSForegroundColorAttributeName : UIColor.whiteColor()]), forState: UIControlState.Normal)
        completionButton.addTarget(self, action: #selector(SignatureCaptureViewController.completionButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        saveButtonContainer.addSubview(completionButton)
        //constraints for the completion button
        let horizontalCenteringConstraint = NSLayoutConstraint(item: completionButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: saveButtonContainer, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        let verticalCenteringConstraint = NSLayoutConstraint(item: completionButton, attribute: .CenterY, relatedBy: .Equal, toItem: saveButtonContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        saveButtonContainer.addConstraint(horizontalCenteringConstraint)
        saveButtonContainer.addConstraint(verticalCenteringConstraint)
        //the imageView
        signatureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height * 0.92))
        rootView.addSubview(signatureImage)
        signatureImage.translatesAutoresizingMaskIntoConstraints = false
        views.updateValue(signatureImage, forKey: "signatureImage")
        //create constraints
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[signatureImage(\(UIScreen.mainScreen().bounds.height * 0.92))][saveButtonContainer(\(UIScreen.mainScreen().bounds.height * 0.08))]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let horizontalButtonContainerConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[saveButtonContainer]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let horizontalSignatureImageConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[signatureImage]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        //add constraints to the rootview
        rootView.addConstraints(verticalConstraints)
        rootView.addConstraints(horizontalButtonContainerConstraints)
        rootView.addConstraints(horizontalSignatureImageConstraints)
        
        //coloring
        rootView.backgroundColor = UIColor.whiteColor()
        signatureImage.backgroundColor = UIColor.whiteColor()
        saveButtonContainer.backgroundColor = UIColor(red: 142.0/255.0, green: 195.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        // 8% screen height at the bottom dedicated to save button.
        self.view = rootView
    }
    //MARK: COMPLETION
    func completionButtonPressed(sender : AnyObject) {
        if let validDelegate = self.delegate {
            if let signature = signatureImage.image {
                validDelegate.signatureCaptured(signature)
            }else{
                print("No signature captured.")
            }
        }else{
            print("")
            print("There is no delegate set for the SignatureCaptureViewController!")
            print("")
        }
        if let nav = self.navigationController {
            nav.popViewControllerAnimated(true)
        }
    }
    //MARK: SIGNATURE METHODS
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //did our finger move yet?
        fingerMoved = false
        guard let touch = touches.first else {return}
        
        //clear the image if the user taps twice
        if (touch.tapCount == 2) {
            signatureImage.image = nil
            return
        }
        
        //we need 3 points of contact to make our signature smooth using quadratic bezier curve
        currentPoint = touch.locationInView(signatureImage)
        lastContactPoint1 = touch.locationInView(signatureImage)
        lastContactPoint2 = touch.locationInView(signatureImage)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //finger moved on the screen
        fingerMoved = true
        guard let touch = touches.first else {return}
        //save previous contact locations and update current
        lastContactPoint2 = lastContactPoint1
        lastContactPoint1 = touch.previousLocationInView(signatureImage)
        currentPoint = touch.locationInView(signatureImage)
        //find mid points to be used for quadratic bezier curve
        let midpoint1 = self.midpoint(lastContactPoint1!, point2: lastContactPoint2!)
        let midpoint2 = self.midpoint(currentPoint!, point2: lastContactPoint1!)
        
        //create a bitmap-based graphics context and makes it the current context
        let imageFrame = signatureImage.frame.size
        UIGraphicsBeginImageContextWithOptions(signatureImage.frame.size, false, 0.0)
        signatureImage.image?.drawInRect(CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imageFrame))
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0/255.0, 0.0/255.0, 0.0/255.0, 1.0)
        CGContextBeginPath(UIGraphicsGetCurrentContext())
        //new subpath
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), midpoint1.x, midpoint1.y)
        //create quadratic bezier curve from the current point using a control point an an end point
        CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), lastContactPoint1!.x, lastContactPoint1!.y, midpoint2.x, midpoint2.y)
        //set miter limit for the joins of the connected line
        CGContextSetMiterLimit(UIGraphicsGetCurrentContext(), 2.0)
        //paint the line
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        signatureImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if touch?.tapCount == 2 {
            signatureImage.image = nil
            return
        }
        if !fingerMoved {
            let imageFrame = signatureImage.frame.size
            UIGraphicsBeginImageContextWithOptions(signatureImage.frame.size, false, 0.0)
//            UIGraphicsBeginImageContext(imageFrame)
            signatureImage.image?.drawInRect(CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imageFrame))
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0/255.0, 0.0/255.0, 0.0/255.0, 1.0)
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), currentPoint!.x, currentPoint!.y)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint!.x, currentPoint!.y)
            CGContextStrokePath(UIGraphicsGetCurrentContext())
            CGContextFlush(UIGraphicsGetCurrentContext())
            signatureImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    //MARK: UTILITY FUNCTIONS
    //calculate midpoint between two points
    func midpoint(point1 : CGPoint, point2 : CGPoint) -> CGPoint {
        let midpoint = CGPoint(x: (point1.x + point2.x) / 2.0, y: (point1.y + point2.y) / 2.0)
        return midpoint
    }
}
