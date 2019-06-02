//
//  CaptureImageViewController.swift
//  BSH
//
//  Created by Susanne Winkler on 29.05.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import CUU

// MARK: - CaptureImageViewController
class CaptureImageViewController: CUUViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: IBOutlets
    var image: UIImage?
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func galleryClick(_ sender: Any) {
        let galleryImagePickerController = UIImagePickerController()
        galleryImagePickerController.delegate = self;
        galleryImagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        print("before dismiss")
        self.present(galleryImagePickerController, animated: true, completion: nil)
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
}
