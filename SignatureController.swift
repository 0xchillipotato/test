//
//  SignatureController.swift
//  Fisdom
//
//  Created by Arpitha Dudi on 2/25/16.
//  Copyright © 2016 finwzard. All rights reserved.
//

import Foundation
import UIKit

protocol SignatureControllerDelegate{
    func controllerDismissed()
    func didSign(image: UIImage)
}


class DashedLine : UIView{
    
    override func draw(_ rect:CGRect)
    
    {
        let thickness = 2.0 as CGFloat
        let cx = UIGraphicsGetCurrentContext();
        cx?.setLineWidth(thickness);
        cx?.setStrokeColor(UIColor.lightGray.cgColor)
        let dashes: [CGFloat] = [4, 2]
        //CGContextSetLineDash(cx, 0.0, dashes, 2) // nb "2" == ra count
        cx?.setLineDash(phase: 0.0, lengths: dashes)
        cx?.move(to: CGPoint(x: 0, y: thickness*0.5))
        cx?.addLine(to: CGPoint(x: self.bounds.size.width, y: thickness*0.5));
        cx?.strokePath();
    }

}

class SignatureController: UIViewController {
    func didReceiveAuthUrl() {
        
    }
    
    @IBOutlet weak var signaturePad: Signature!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var dashedLine: DashedLine!
    @IBOutlet weak var signLabel: UILabel!
    var delegate : SignatureControllerDelegate?
    var spinnerView : FullScreenProgressView?

    var isPresented = true
    var isMandateSign = false
    var myAccountOrLaunch = false
    
    convenience init() {
        self.init(nibName: "SignatureController", bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Signature"
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        clearBtn.isHidden=false
        confirmBtn.isHidden=false
    }
        
    override func viewDidLoad() {
        setupBtnView()
    }
    
    @IBAction func clearBtnClicked(_ sender: UIButton) {
        self.signaturePad.clearSignature()
        isPresented = false
    }
    
    @IBAction func confirmBtnClicked(_ sender: UIButton) {
        // Getting the Signature Image from self.signaturePad using the method getSignature().
        if(self.signaturePad.didSign){
            signLabel.isHidden = true
            dashedLine.isHidden = true
            confirmBtn.isHidden = true
            clearBtn.isHidden = true
            let signatureImage: UIImage = self.signaturePad.getSignature()
            delegate?.didSign(image: signatureImage)
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.dismiss(animated: true, completion: nil)
            //let imageData: Data =   AppConstant.getCompressedData(signatureImage)
        }else{
            let alertController = UIAlertController(title: "", message: "Please sign to confirm", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
            }
            alertController.addAction(okAction)
            // TODO: iOS 13 presentation handling
            self.present(alertController, animated: true, completion: nil)
        }
    }
    


    //Setup for the ButtonView.
    fileprivate func setupBtnView(){
        clearBtn.setTitle("Clear", for: UIControl.State())
        confirmBtn.setTitle("Confirm", for: UIControl.State())
        confirmBtn.backgroundColor = UIColor.white
        clearBtn.backgroundColor = UIColor.white

    }
    
    override func viewDidDisappear(_ animated: Bool) {
         isPresented = false
        self.delegate?.controllerDismissed()
       // self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showSpinner() {
        if spinnerView == nil {
            spinnerView = FullScreenProgressView()
        }
        spinnerView?.showSpinner()
    }
    
    func hideSpinner() {
        spinnerView?.hideSpinner()
    }

    func didRecieveError(message : String) {
        hideSpinner()
        //self.navigationController?.view.makeToast(message)
    }
    
    func showAlert() {
        //let appname = CofigurationHandler.sharedInstance.targetName
        let alertController = UIAlertController(title: "", message: "We request you to provide your signature which is similar to your bank signature. Your bank will verify the same before approving the OTM.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        // TODO: iOS 13 presentation handling

        self.present(alertController, animated: true, completion: nil)
    }
}
