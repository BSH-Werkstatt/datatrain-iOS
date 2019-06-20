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
    @IBOutlet private weak var annotatedImageView: UIImageView!
    @IBOutlet private weak var annotateRectangleButton: UIButton!
    @IBOutlet private weak var annotationNameTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private var mainView: UIView!
    
    private var activeCampaign: Campaign?
    private var currentAnnotation: Annotation?
    var imageData: ImageData?
    private var originalImage: UIImage?
    
    private var mainViewInitialY: CGFloat!

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

// Draw Shape Functionality
extension AnnotateImageViewController {
    func drawShape() {

        let shape = CAShapeLayer()
        self.imageLayerContainer.layer.addSublayer(shape)
        shape.opacity = 0.5
        shape.lineWidth = 2
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness: 0.53, alpha: 1.0).cgColor
        shape.fillColor = UIColor(hue: 0.786, saturation: 0.15, brightness: 0.89, alpha: 1.0).cgColor

        let path = UIBezierPath()
        path.move(to: CGPoint(x:120, y:20))
        path.addLine(to: CGPoint(x:230, y:90))
        path.addLine(to: CGPoint(x:240, y:250))
        path.addLine(to: CGPoint(x:40, y:280))
        path.addLine(to: CGPoint(x:100, y:150))
        path.close()
        shape.path = path.cgPath
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
            let data = try? Data(contentsOf: url)else {
                // TODO: show an alert that url does not exist
                self.returnToCampaignInfo()
                return
        }

        let imageView = UIImageView(image: UIImage(data: data))
        imageView.frame = view.bounds
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.imageLayerContainer.addSubview(imageView)
        self.drawShape()
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
    }

    @IBAction func submitButtonClick(_ sender: Any) {
        guard let label = annotationNameTextField.text,
            let imageData = imageData,
            let activeCampaign = activeCampaign else {
                
            return
        }

        // TODO: replace with real current annotation
        let currentAnnotation = RectangularAnnotation(
            topLeft: Point(x: 0.0, y: 0.0),
            bottomRight: Point(x: 100, y: 100),
            userId: "5d0a6fe5a9edbb9d5cc29e10",
            campaignId: activeCampaign._id,
            imageId: imageData._id
        )
        
        if annotationNameTextField.text?.count == 0 {
            return
        }

        // this is the mask RCNN type
        let type = "polygon"

        let request = AnnotationCreationRequest(points: currentAnnotation.getAPIPoints(), type: type, label: label, userToken: "5d0a6fe5a9edbb9d5cc29e10")
        DefaultAPI.postImageAnnotation(campaignId: activeCampaign._id, imageId: imageData._id, request: request, completion: { (annotation, error) in
            print("annotaion result", annotation, error)
            if error == nil {
                // Show notification for succesful upload
                let alertController = UIAlertController(title: "Annotation successful", message: "the annotation was saved.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
}

