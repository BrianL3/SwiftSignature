# SwiftSignature
This is an easily-integrated way of capturing user signatures.  
It was adapted from an Objective-C project with the same purpose, seen here: http://www.mysamplecode.com/2013/05/ios-smooth-signature-capture-example.html

The purpose of this project is to have an easy signature-capture library that can be integrated into a storyboarded project.  

How to integrate: 
1. Add SignatureCaptureViewController to your project.
2. Create a ViewController in Storyboard and change the class to "SignatureCaptureViewController"
3. When you need the user to write their signature, segue to the ViewController you just made.  In the originating view controller's prepareForSegue method, set the delegate of SignatureCaptureViewController to self.
