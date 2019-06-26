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
    
   
    private var annotationViews: [AnnotationView] = []
    private var currentAnnotationView: AnnotationView?
    private var selectedAnnotationView: AnnotationView?

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
        activeCampaign = MainTabBarController.getCampaign()
    }

    private func getImage() {
        guard let activeCampaign = activeCampaign else {
            // TODO: show an alert
            self.returnToCampaignInfo()
            return
        }
        
        if self.imageData == nil {
            DefaultAPI.getRandomImage(campaignId: activeCampaign._id, completion: downloadAndDisplayImage)
        } else {
            downloadAndDisplayImage(self.imageData, nil)
        }
    }

    private func downloadAndDisplayImage(_ iData: ImageData?, _ error: Error?) {
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
//        imageView.isUserInteractionEnabled = true
        guard let imageView = imageView else {
            print("Cannot initialize image view.")
            return
        }
        imageView.frame = imageLayerContainer.bounds
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.center = CGPoint(x: imageLayerContainer.frame.size.width / 2, y: imageLayerContainer.frame.size.height / 2)
        self.imageLayerContainer.addSubview(imageView)
        
        let (offsetX, offsetY, imageSizeX, imageSizeY) = calculateOffsetOfImage()
        AnnotationView.setOffsetVariables(offsetX: offsetX, offsetY: offsetY)
        AnnotationView.setImageSize(imageSizeX: imageSizeX, imageSizeY: imageSizeY)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectAnnotation(tapGestureRecognizer:)))
        imageLayerContainer.isUserInteractionEnabled = true
        imageLayerContainer.addGestureRecognizer(tapGestureRecognizer)
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
// MARK: Touch overrides
extension AnnotateImageViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TouchesBegan")
        guard let imageData = imageData, let activeCampaign = activeCampaign else {
            print("Cannot get image data or active campaign")
            return
        }
        let annotationView = AnnotationView()
        annotationView.frame = view.bounds
        annotationView.backgroundColor = UIColor.clear
        annotationView.isOpaque = false
        
        imageLayerContainer.addSubview(annotationView)
        let annotation = PolygonAnnotation(userId: "5d0a6fe5a9edbb9d5cc29e10", campaignId: activeCampaign._id, imageId: imageData._id)
        annotationView.annotation = annotation
        
        super.touchesBegan(touches, with: event)
        let touch = touches.first as! UITouch
        let point = touch.location(in: imageView)
        annotationView.annotation?.addPoint(point: point)

        annotationViews.append(annotationView)
        currentAnnotationView = annotationView
        currentAnnotationView?.setNeedsDisplay()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TouchesMoved")
        super.touchesBegan(touches, with: event)
        let touch = touches.first as! UITouch
        let point = touch.location(in: imageView)
        if let lastPoint = currentAnnotationView?.annotation?.points.last {
            if ((point.x - lastPoint.x) * (point.x - lastPoint.x) +
                (point.y - lastPoint.y) * (point.y - lastPoint.y) > 100) {
                currentAnnotationView?.annotation?.addPoint(point: point)
            }
        }
        currentAnnotationView?.annotation?.temporaryPoint = point
        currentAnnotationView?.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TouchesEnded")
        super.touchesBegan(touches, with: event)
        let touch = touches.first as! UITouch
        let point = touch.location(in: imageView)
        currentAnnotationView?.annotation?.addPoint(point: point)
        currentAnnotationView?.annotation?.completed = true
        currentAnnotationView?.setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let count = currentAnnotationView?.annotation?.points.count, count <= 1 {
            print("Annotation is being deleted because the is only one point")
            currentAnnotationView?.annotation = nil
            currentAnnotationView?.removeFromSuperview()
            return
        }    }
    
    @objc func selectAnnotation(tapGestureRecognizer: UITapGestureRecognizer) {
        if imageLayerContainer.subviews.count == 0 {
            return
        }
        // If there is already a selected annotation, then we cannot select new ones, only deselect this one
        if let selectedAnnotation = selectedAnnotationView, selectedAnnotation.selected {
            if selectedAnnotation.isPointInsideAnnotation(point: tapGestureRecognizer.location(in: imageLayerContainer)) {
                selectedAnnotation.selected = false
                selectedAnnotation.setNeedsDisplay()
                selectedAnnotationView = nil
            }
            return
        }
        for index in 0...imageLayerContainer.subviews.count - 1 {
            if imageLayerContainer.subviews[imageLayerContainer.subviews.count - 1 - index] is AnnotationView {
                let subview = imageLayerContainer.subviews[imageLayerContainer.subviews.count - 1 - index] as! AnnotationView
                if subview.isPointInsideAnnotation(point: tapGestureRecognizer.location(in: imageLayerContainer)) {
                    subview.selected = true
                    subview.setNeedsDisplay()
                    selectedAnnotationView = subview
                    return
                }
            }
        }
    }
}

// MARK: Save Annotation Functionality
extension AnnotateImageViewController {
    private func returnToCampaignInfo() {
        // TODO: Handle errors
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func calculateOffsetOfImage() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        guard let image = imageView.image else {
            print("Image should not be null at this point")
            return (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        }
        var offsetX = CGFloat(0.0)
        var offsetY = CGFloat(0.0)
        var imageSizeX = CGFloat(0.0)
        var imageSizeY = CGFloat(0.0)

        let frameRatio = imageView.frame.size.width / imageView.frame.size.height
        let imageRatio = image.size.width / image.size.height
        
        if frameRatio < imageRatio {
            // image is wider
            offsetY = (imageView.frame.size.height - imageView.frame.size.width / image.size.width * image.size.height) / CGFloat(2)
            imageSizeX = imageView.frame.size.width
            imageSizeY = imageSizeX / image.size.width * image.size.height
        } else {
            // image is narrower
            offsetX = (imageView.frame.size.width - imageView.frame.size.height / image.size.height * image.size.width) / CGFloat(2)
            imageSizeY = imageView.frame.size.height
            imageSizeX = imageSizeY * image.size.width / image.size.height
        }
        return (offsetX, offsetY, imageSizeX, imageSizeY)
    }

    @IBAction func annotationButtonClick(_ sender: Any) {
        selectedAnnotationView?.annotation = nil
        selectedAnnotationView?.selected = false
        selectedAnnotationView?.removeFromSuperview()
        selectedAnnotationView = nil
    }
    
    @IBAction func submitButtonClick(_ sender: Any) {
//        if let submitButtonTitle = submitButton.title(for: .normal),
//            submitButtonTitle == "Complete Annotation" {
//            submitButton.setTitle("Send Annotation", for: .normal)
//            annotationEnabled = false
//            annotationView.complete(annotation: 0)
//            annotationView.setNeedsDisplay()
//            return
//        }
//
//        guard let label = annotationNameTextField.text,
//            let imageData = imageData,
//            let activeCampaign = activeCampaign else {
//            return
//        }
//
//        // TODO: replace with real current annotation
//        let currentAnnotation = PolygonAnnotation (
//            userId: "5d0a6fe5a9edbb9d5cc29e10",
//            campaignId: activeCampaign._id,
//            imageId: imageData._id,
//            points: annotationView.getPoints()
//        )
//
//        if annotationNameTextField.text?.count == 0 {
//            return
//        }
//
//        // this is the mask RCNN type
//        let type = "polygon"
//
//        let annotationItem = AnnotationCreationRequestItem(points: currentAnnotation.getAPIPoints(), type: type, label: label)
//        let request = AnnotationCreationRequest(items: [annotationItem], userToken: "5d0a6fe5a9edbb9d5cc29e10")
//        DefaultAPI.postImageAnnotation(campaignId: activeCampaign._id, imageId: imageData._id, request: request, completion: { (annotation, error) in
//            print("Annotation result", annotation, error)
//            if error == nil {
//                // Show notification for succesful upload
//                let alertController = UIAlertController(title: "Annotation successful", message: "The annotation was saved.", preferredStyle: UIAlertController.Style.alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alertController, animated: true, completion: nil)
//            }
//        })
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}

