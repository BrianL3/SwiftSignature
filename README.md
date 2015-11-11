# SwiftSignature
This is an easily-integrated way of capturing user signatures.

It was adapted from an Objective-C project with the same purpose, seen here:

[Sample Code!](http://www.mysamplecode.com/2013/05/ios-smooth-signature-capture-example.html)

The purpose of this project is to have an easy signature-capture library that can be integrated into a storyboarded project.  

#####How to Integrate
* Add SignatureCaptureViewController to your project.
* Create a ViewController in Storyboard and change the class to "SignatureCaptureViewController". 
![Image of Changing Class to SignatureCaptureViewController](http://i.imgur.com/4PkXOu9.png)

* When you need the user to write their signature, segue to the ViewController you just made.  In the originating view controller's prepareForSegue method, set the delegate of SignatureCaptureViewController to self.
![Image of Segue](http://i.imgur.com/SXLmBKb.png)

![Image of Setting Delegate](http://i.imgur.com/Wse9Me8.png)

* When the user is done, they will press the completion button on the SignatureCaptureViewController, which calls the delegate's signatureCaptured method, passing the user's signature back to the originating view controller.

* This means that the originating ViewController must comply with the SignatureCaptureDelegate protocol, which is very easy.  Just add one method: signatureCaptured.  That method does... whatever you want to do with the captured signature.  Save it to a file?  Convert it to PDF?  Post it to your API?  Bake it in a pie?  The world is your oyster, or indeed the mollusk of your choice.
![Image of Delegate Method](http://i.imgur.com/EVQSRxU.png)

######What is the MIT license?
You can do whatever you want with this project, basically.  Here's the TLDR:

[MIT License Explained](https://tldrlegal.com/license/mit-license)