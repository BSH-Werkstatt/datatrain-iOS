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
    private var imageData: ImageData?;
    
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
        guard let campaign = CampaignInfoViewController.getCampaign() else {
            return
        }
        
        if let image = uploadedImageView.image {
            // TODO: increase upload size limit at the server
            if let data = image.jpegData(compressionQuality: 0.1) {
                let filename = getDocumentsDirectory().appendingPathComponent("copy.jpg")
                try? data.write(to: filename)
                
                DefaultAPI.postImage(imageFile: filename, userToken: "5d0a6fe5a9edbb9d5cc29e10", campaignId: campaign._id, completion: { (image, error) in
                    
                    // TODO: finish handling
                    guard error == nil, let image = image else {
                        let alertController = UIAlertController(title: "Upload failed", message: "Image couldn't be sent to the campaign database. Please make sure you have an internet connection.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    // Set image Id
                    self.imageData = image
                    // Show notification for succesful upload
                    let alertController = UIAlertController(title: "Upload successful", message: "Your image is uploaded. Please annotate the image.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(
                        UIAlertAction(title: "OK", style: .default, handler: {_ in
                            self.performSegue(withIdentifier: "uploadToAnnotateSegue", sender: nil)
                        })
                    )
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let annotateViewController as AnnotateImageViewController:
            annotateViewController.imageData = self.imageData
        default:
            print("Unknown Destination View Controller")
        }
    }
}

