//
//  CampaignInfoViewController.swift
//  BSH
//
//  Created by Susanne Winkler on 29.05.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit
import CUU
import SwaggerClient

// MARK: - CampaignTableControll
class CampaignInfoViewController: CUUViewController {
    var image: UIImage?
    
    // MARK: IBOutlets
    @IBOutlet private weak var campaignInfoText: UITextView!
    @IBOutlet weak var campaignImageView: UIImageView!
    
    // MARK: IBActions
    @IBAction func startCampaignButton() {
        // what to do when Campaign starts
        // select which campaign + and Segue!
    }

    @IBAction func selectImageAction(_ sender: Any) {
        showImageAlert()
    }
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let campaign = MainTabBarController.getCampaign() {
//            campaignName.text = campaign.name
            campaignInfoText.text = campaign._description
        }

        if let image = MainTabBarController.getImage() {
            self.campaignImageView.image = image
        }
    }



    
    @IBAction func unwindToCampainInfoView(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}



// handles everything regarding image capturing, selection and upload
extension CampaignInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }

        self.image = image
        self.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "uploadImageSegue", sender: nil)
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.destination as? UploadImageViewController) != nil,
            let image = self.image {
            UploadImageViewController.setImage(image)
        }
    }

    private func pickImage(showLibrary: Bool) {
        var pickerMode: UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.camera) && !showLibrary {
            pickerMode = .camera
        }

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = pickerMode;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
}
