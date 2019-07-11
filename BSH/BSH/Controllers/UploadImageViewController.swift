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
import NotificationBannerSwift

// MARK: - UploadImageViewController
class UploadImageViewController: CUUViewController {
    private static var image: UIImage?
    private var imageData: ImageData?;
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var activityIndicatorBackground: UIView?
    
    // MARK: IBOutlets
    @IBOutlet private weak var uploadedImageView: UIImageView!
    @IBOutlet private weak var uploadButton: UIBarButtonItem!
    
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
        
        //activityIndicator background goes milky white
        activityIndicatorBackground = UIView(frame: self.view.bounds)
        activityIndicatorBackground?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.7)
        //activityIndicator shown
        activityIndicator.center = activityIndicatorBackground!.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicatorBackground?.addSubview(activityIndicator)
        self.view.addSubview(activityIndicatorBackground!)
        activityIndicator.startAnimating()
        
        guard let campaign = MainTabBarController.getCampaign() else {
            return
        }
        guard let userId = UserDefaults.standard.string(forKey: "user-id") else {
            let banner = NotificationBanner(title: "Invalid user id", subtitle: "Please check if you are logged in correctly", style: .success)
            banner.show()
            return
        }
        
        if let image = uploadedImageView.image?.rotatedCopy {
            // TODO: increase upload size limit at the server
            if let data = image.jpegData(compressionQuality: 0.1) {
                let filename = getDocumentsDirectory().appendingPathComponent("copy.jpg")
                try? data.write(to: filename)
                
                DefaultAPI.postImage(imageFile: filename, userToken: userId, campaignId: campaign._id, completion: { (image, error) in
                    
                    // TODO: finish handling
                    guard error == nil, let image = image else {
                        let alertController = UIAlertController(title: "Upload failed", message: "Image couldn't be sent to the campaign database. Please make sure you have an internet connection.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        print(error)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    // Set image Id
                    self.imageData = image
                    // Show notification for succesful upload
                    let banner = NotificationBanner(title: "Success", subtitle: "The image is successfully uploaded. Please annotate the image.", style: .success)
                    banner.show()
                    
                    //CUU Seed for tracking successful uploading
                    CUU.seed(name: "Uploaded picture sucessfully")
                    
                    //activityIndicator and background hide
                    self.activityIndicator.stopAnimating()
                    self.activityIndicatorBackground?.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
                    self.performSegue(withIdentifier: "uploadToAnnotateSegue", sender: nil)
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

extension UIImage {
    var rotatedCopy: UIImage? {
        if (imageOrientation == UIImage.Orientation.up) {
            return self
        }
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
}
