//
//  UploadImageViewController.swift
//  BSH
//
//  Created by Lei, Taylor on 30.05.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import CUU
import SwaggerClient

// MARK: - UploadImageViewController
class UploadImageViewController: CUUViewController {
    private static var image: UIImage?
    
    // MARK: IBOutlets
    @IBOutlet private weak var uploadedImageView: UIImageView!
    @IBOutlet private weak var uploadButton: UIButton!
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uploadedImageView.image = UploadImageViewController.image
    }
    
    public static func setImage(_ image: UIImage) {
        self.image = image
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func uploadButtonClick(_ sender: Any) {
        /*guard let image = UploadImageViewController.image, let imageData = image.jpegData(compressionQuality: 1) else {
         return
         }*/
        
        
        if let image = uploadedImageView.image {
            // TODO: increase upload size limit at the server
            if let data = image.jpegData(compressionQuality: 0.1) {
                let filename = getDocumentsDirectory().appendingPathComponent("copy.jpg")
                try? data.write(to: filename)
                
                DefaultAPI.postImage(imageFile: filename, campaignId: 1, completion: { (image, error) in
                    // TODO: finish handling
                    print(image, error)
                    //self.performSegue(withIdentifier: "uploadToCampaignSegue", sender: nil)
                })
                self.performSegue(withIdentifier: "uploadToCampaignSegue", sender: nil)
                // Show notification for succesful upload
                let alertController = UIAlertController(title: "Upload successful", message: "Image was sent to campaign database.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

