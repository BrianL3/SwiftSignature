//
//  ViewController.swift
//  SwiftSignatureSample
//
//  Created by Brian Ledbetter on 11/9/15.
//  Copyright © 2015 Brian Ledbetter. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SignatureCaptureDelegate {

    @IBOutlet weak var signatureViewer: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func signatureButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "CAPTURE_SIGNATURE_SEGUE", sender: self)
    }
    //MARK: Signature Capture Delegate Method
    func signatureCaptured(completedSignature : UIImage) {
        self.signatureViewer.image = completedSignature
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CAPTURE_SIGNATURE_SEGUE" {
            let destinationVC = segue.destination as? SignatureCaptureViewController
            destinationVC?.delegate = self
        }

    }
}

