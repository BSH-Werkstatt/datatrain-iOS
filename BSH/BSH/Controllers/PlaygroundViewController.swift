//
//  PlaygroundViewController.swift
//  BSH
//
//  Created by Baris Sen on 7/14/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import CUU
import SwaggerClient
import NotificationBannerSwift

class PlaygroundViewController: CUUViewController {
    private var imageData: ImageData?;
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var activityIndicatorBackground: UIView?
    private var state = 0
    
    // MARK: IBOutlets
    @IBOutlet private weak var uploadedImageView: UIImageView!
    @IBOutlet private weak var uploadButton: UIButton!
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func uploadButtonClick(_ sender: Any) {
        print("Clicked: \(state)")
        switch state {
        case 0:
            showImageAlert()
            //CUU Seed Upload Button clicked
            CUU.seed(name: "Start Upload")
            return
        case 1:
            //activityIndicator background goes milky white
            activityIndicatorBackground = UIView(frame: uploadedImageView.bounds)
            activityIndicatorBackground?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.7)
            //activityIndicator shown
            activityIndicator.center = activityIndicatorBackground!.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            activityIndicatorBackground?.addSubview(activityIndicator)
            uploadedImageView.addSubview(activityIndicatorBackground!)
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
                        // Show notification for succesful upload
                        let banner = NotificationBanner(title: "Success", subtitle: "The image is successfully uploaded. Here is the result.", style: .success)
                        banner.show()
                        
                        //CUU Seed for tracking successful uploading
                        CUU.seed(name: "Uploaded picture sucessfully in the playground")
                        
                        //activityIndicator and background hide
                        self.activityIndicator.stopAnimating()
                        self.activityIndicatorBackground?.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
                        
                        guard let url = URL(string: image.url), let data = try? Data(contentsOf: url) else {
                            return
                        }
                        self.uploadedImageView.contentMode = UIView.ContentMode.scaleAspectFit
                        self.uploadedImageView.image = UIImage(data: data)
                    })
                    self.state = 0
                    self.uploadButton.setTitle("Upload Another Image", for: .normal)
                }
            }
        default:
            print("Unknown state")
        }
    }
}

// handles everything regarding image capturing, selection and upload
extension PlaygroundViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showImageAlert() {
        let alert = UIAlertController(title: "Image Upload", message: "Would you like to take a picture or choose one from your library?", preferredStyle: .actionSheet)
        let addPhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.pickImage(showLibrary: false)
        })
        //check, whether camera is available, otherwise disable action
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            addPhotoAction.isEnabled = false
        }
        alert.addAction(addPhotoAction)
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.pickImage(showLibrary: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        uploadedImageView.image = image
        uploadedImageView.setNeedsDisplay()
        state = 1
        uploadButton.setTitle("Submit Image", for: .normal)
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    private func pickImage(showLibrary: Bool) {
        var pickerMode: UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.camera) && !showLibrary {
            pickerMode = .camera
            
            //CUU Seed for tracking photo taking
            CUU.seed(name: "Upload: Take Photo")
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = pickerMode;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        
        //CUU Seed for tracking choosing photo from library
        CUU.seed(name: "Upload: Choose Photo")
    }
}
