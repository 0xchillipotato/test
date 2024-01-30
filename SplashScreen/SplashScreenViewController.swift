//
//  SplashScreenViewController.swift
//  FisdomSDK
//
//  Created by Raghu Eswar on 23/06/22.
//  Copyright © 2022 Abhishek Mishra. All rights reserved.
//

import Foundation
import SDWebImage

class SplashScreenViewController: UIViewController {
    @IBOutlet var container: UIView!
    @IBOutlet var fisdomLogo: UIImageView!
    @IBOutlet var partnerLogo: UIImageView!
    @IBOutlet var fisdomLogoCenterY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let partnerLogoUrl = AppSettings.getPartnerSplashLogo()
        if partnerLogoUrl.isEmpty {
            self.partnerLogo.isHidden = true
        } else {
            if let decodedImageUrl = partnerLogoUrl.decodeUrlSafely(), let imageUrl = URL(string: decodedImageUrl) {
                partnerLogo.sd_setImage(with: imageUrl)
            }
        }
    }
}
