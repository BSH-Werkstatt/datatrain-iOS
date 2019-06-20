//
//  AnnotateImageViewController.swift
//  BSH
//
//  Created by Lei, Taylor on 02.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import CUU
import SwaggerClient

// MARK: - AnnotateImageViewController
class AnnotateImageViewController: CUUViewController, UITextFieldDelegate {
    // MARK: Overriden IBOutlets
    @IBOutlet private weak var imageLayerContainer: UIView!
    @IBOutlet private weak var annotateRectangleButton: UIButton!
    @IBOutlet private weak var annotationNameTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private var mainView: UIView!
    
    private var annotationView: AnnotationView!
    private var imageView: UIImageView!
    
    private var activeCampaign: Campaign?
    var imageData: ImageData?
    private var originalImage: UIImage?
    private var mainViewInitialY: CGFloat!
    private var annotationEnabled: Bool = false
    

    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // intialize main view offsets because of the keyboard
        mainViewInitialY = mainView.frame.origin.y
        // load data
        loadActiveCampaign()
        getImage()
        addKeyboardShiftListner()
        annotationNameTextField.delegate = self
    }
}

// Load Data Functionality
extension AnnotateImageViewController {
    /// Gets the currently selected campaign from CampaignInfoViewController
    private func loadActiveCampaign() {
        activeCampaign = CampaignInfoViewController.getCampaign()
    }

    private func getImage() {
        guard let activeCampaign = activeCampaign else {
            // TODO: show an alert
            self.returnToCampaignInfo()
            return
        }
        
        if self.imageData == nil {
            DefaultAPI.getRandomImage(campaignId: activeCampaign._id, completion: downloadImage)
        } else {
            downloadImage(self.imageData, nil)
        }
    }

    private func downloadImage(_ iData: ImageData?, _ error: Error?) {
        if let error = error {
            // TODO: show an alert that an error has occured
            print(error)
            self.returnToCampaignInfo()
            return
        }

        guard let iData = iData else {
            // TODO: show an alert that no data was received
            self.returnToCampaignInfo()
            return
        }
        
        self.imageData = iData
        print(self.imageData!._id)

        // Proceed with getting the image
        let imageURL = "\(SwaggerClientAPI.basePath)/images/\(iData.campaignId)/\(iData._id).jpg"
        guard let url = URL(string: imageURL),
            let data = try? Data(contentsOf: url) else {
                // TODO: show an alert that url does not exist
                self.returnToCampaignInfo()
                return
        }
        imageView = UIImageView(image: UIImage(data: data))
        guard let imageView = imageView else {
            print("Cannot initialize image view.")
            return
        }
        imageView.frame = imageLayerContainer.bounds
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.center = CGPoint(x: imageLayerContainer.frame.size.width / 2, y: imageLayerContainer.frame.size.height / 2)
        self.imageLayerContainer.addSubview(imageView)
    }
}


// Basic Layout Functionality
extension AnnotateImageViewController {
    private func addKeyboardShiftListner() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { (notification: Notification) in

            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height

                // +70 is accounting for the tab bar
                self.mainView.frame.origin.y = self.mainViewInitialY - keyboardHeight + 80
            } else {
                self.mainView.frame.origin.y = self.mainViewInitialY - 150 // base case
                // TODO: remove later
                print("Did not detect keyboard height, moving by default value")
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notification: Notification) in
            self.mainView.frame.origin.y = self.mainViewInitialY
        }
    }
}

// Save Annotation Functionality
extension AnnotateImageViewController{
    private func returnToCampaignInfo() {
        // TODO: Handle errors
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    @IBAction func annotationButtonClick(_ sender: Any) {
        annotateRectangleButton.isEnabled = false
        annotationView = AnnotationView()
        guard let annotationView = annotationView else {
            print("Cannot initialize annotation view.")
            return
        }
        annotationView.frame = view.bounds
        annotationView.backgroundColor = UIColor.clear
        annotationView.isOpaque = false
        self.imageLayerContainer.addSubview(annotationView)
        
        let alertController = UIAlertController(title: "Start Annotation", message: "Please annotate the image with polygons by touching on the edges of the polygon that surrounds the object.", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        annotationEnabled = true
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        annotationView.isUserInteractionEnabled = true
        annotationView.addGestureRecognizer(tapGestureRecognizer)
        submitButton.setTitle("Complete Annotation", for: .normal)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if !annotationEnabled {
            return
        }
        // User tapped on the image. A new point to the Annotation View should be added.
        guard let image = imageView.image else {
            return
        }
        let point = tapGestureRecognizer.location(in: imageView)
        
//        var offsetX = CGFloat(0.0)
//        var offsetY = CGFloat(0.0)
//        let frameRatio = imageView.frame.size.width / imageView.frame.size.height
//        let imageRatio = image.size.width / image.size.height
//
//        if frameRatio < imageRatio {
//            // image is wider
//            offsetY = (imageView.frame.size.height - imageView.frame.size.width / image.size.width * image.size.height) / CGFloat(2)
//        } else {
//            // image is narrower
//            offsetX = (imageView.frame.size.width - imageView.frame.size.height / image.size.height * image.size.width) / CGFloat(2)
//        }
//
//        var x = (-offsetX + point.x) / (imageView.frame.size.width - 2 * offsetX) * image.size.width
//        if x < CGFloat(0) {
//            x = CGFloat(0)
//        } else if x > image.size.width {
//            x = image.size.width
//        }
//
//        var y = (-offsetY + point.y) / (imageView.frame.size.height - 2 * offsetY) * image.size.height
//        if y < CGFloat(0) {
//            y = CGFloat(0)
//        } else if y > image.size.height {
//            y = image.size.height
//        }
        
        self.annotationView.add(point: CGPoint(x: point.x, y: point.y), to: 0)
    }

    @IBAction func submitButtonClick(_ sender: Any) {
        if let submitButtonTitle = submitButton.title(for: .normal),
            submitButtonTitle == "Complete Annotation" {
            submitButton.setTitle("Send Annotation", for: .normal)
            annotationEnabled = false
            annotationView.complete(annotation: 0)
            annotationView.setNeedsDisplay()
            return
        }
        
        guard let label = annotationNameTextField.text,
            let imageData = imageData,
            let activeCampaign = activeCampaign else {
            return
        }

        // TODO: replace with real current annotation
        let currentAnnotation = PolygonAnnotation (
            userId: "5d0a6fe5a9edbb9d5cc29e10",
            campaignId: activeCampaign._id,
            imageId: imageData._id,
            points: annotationView.getPoints()
        )
        
        if annotationNameTextField.text?.count == 0 {
            return
        }

        // this is the mask RCNN type
        let type = "polygon"

        let request = AnnotationCreationRequest(points: currentAnnotation.getAPIPoints(), type: type, label: label, userToken: "5d0a6fe5a9edbb9d5cc29e10")
        DefaultAPI.postImageAnnotation(campaignId: activeCampaign._id, imageId: imageData._id, request: request, completion: { (annotation, error) in
            print("Annotation result", annotation, error)
            if error == nil {
                // Show notification for succesful upload
                let alertController = UIAlertController(title: "Annotation successful", message: "The annotation was saved.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        })
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}

