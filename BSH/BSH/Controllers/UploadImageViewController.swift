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
    
    @IBAction func uploadButtonClick(_ sender: Any) {
        guard let image = UploadImageViewController.image, let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        DefaultAPI.postImage(_id: 1, imageFile: imageData, completion: { (image, error) in
            // TODO: finish
            print(image, error)
            self.performSegue(withIdentifier: "uploadToCampaignSegue", sender: nil)
        })
    }
}
