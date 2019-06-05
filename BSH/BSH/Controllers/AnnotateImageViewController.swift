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
class AnnotateImageViewController: CUUViewController {
    // MARK: Overriden IBOutlets
    @IBOutlet private weak var annotatedImageView: UIImageView!
    @IBOutlet private weak var annotateRectangleButton: UIButton!
    @IBOutlet private weak var annotationNameTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    
    private var activeCampaign: Campaign?
    private var annotationStage: Int = 0
    private var currentAnnotation: Annotation?
    private var imageData: ImageData?
    private var originalImage: UIImage?
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadActiveCampaign()
        loadImage()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        annotatedImageView.isUserInteractionEnabled = true
        annotatedImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // TODO: implement annotation using a click and a drag
        guard let annotatedImageView = annotatedImageView, let image = annotatedImageView.image else {
            return
        }
        
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let point = tapGestureRecognizer.location(in: tappedImage)
        
        var offsetX = CGFloat(0.0)
        var offsetY = CGFloat(0.0)
        let frameRatio = annotatedImageView.frame.size.width / annotatedImageView.frame.size.height
        let imageRatio = image.size.width / image.size.height
        
        if frameRatio < imageRatio {
            // image is wider
            offsetY = (annotatedImageView.frame.size.height - annotatedImageView.frame.size.width / image.size.width * image.size.height) / CGFloat(2)
        } else {
            // image is narrower
            offsetX = (annotatedImageView.frame.size.width - annotatedImageView.frame.size.height / image.size.height * image.size.width) / CGFloat(2)
        }
        
        var x = (-offsetX + point.x) / (annotatedImageView.frame.size.width - 2 * offsetX) * image.size.width
        if x < CGFloat(0) {
            x = CGFloat(0)
        } else if x > image.size.width {
            x = image.size.width
        }
        
        var y = (-offsetY + point.y) / (annotatedImageView.frame.size.height - 2 * offsetY) * image.size.height
        if y < CGFloat(0) {
            y = CGFloat(0)
        } else if y > image.size.height {
            y = image.size.height
        }
        
        // first tap to define the top left corner
        if let currentAnnotation = self.currentAnnotation as? RectangularAnnotation {
            if annotationStage == 1 {
                currentAnnotation.setTopLeft(point: Point(x: x, y: y))
                annotationStage = 2
            } else if annotationStage == 2 {
                currentAnnotation.setBottomRight(point: Point(x: x, y: y))
                currentAnnotation.draw(image: image, view: annotatedImageView)
                annotationStage = 3
            }
        }
        
    }
    
    /// Gets the currently selected campaign from CampaignInfoViewController
    private func loadActiveCampaign() {
        activeCampaign = CampaignInfoViewController.getCampaign()
    }
    
    private func loadImage() {
        guard let activeCampaign = activeCampaign else {
            // TODO: show an alert
            self.returnToCampaignInfo()
            return
        }
        
        DefaultAPI.getRandomImage(campaignId: activeCampaign._id, completion: {iData, error in
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
            
            // Proceed with getting the image
            
            let imageURL = "\(SwaggerClientAPI.basePath)/images/\(iData.campaignId)/\(iData._id).jpg"
            
            guard let url = URL(string: imageURL),
                let data = try? Data(contentsOf: url)else {
                    // TODO: show an alert that url does not exist
                    self.returnToCampaignInfo()
                    return
            }
            
            self.annotatedImageView.image = UIImage(data: data)
            self.originalImage = self.annotatedImageView.image
        })
    }
    
    private func returnToCampaignInfo() {
        self.performSegue(withIdentifier: "annotateToCampaignInfo", sender: nil)
    }
    
    @IBAction func annotationButtonClick(_ sender: Any) {
        guard let activeCampaign = activeCampaign, let imageData = imageData, let image = annotatedImageView.image else {
            return
        }
        
        let size = image.size
        if annotationStage == 0 {
            annotationStage = 1
            annotateRectangleButton.backgroundColor = UIColor(displayP3Red: CGFloat(248.0/255.0), green: CGFloat(158/255.0), blue: CGFloat(53/255.0), alpha: CGFloat(0.5))
            
            currentAnnotation = RectangularAnnotation(
                topLeft: Point(x: 0.0, y: 0.0),
                bottomRight: Point(x: size.width, y: size.height),
                userId: 1,
                campaignId: activeCampaign._id,
                imageId: imageData._id
            )
        } else {
            annotationStage = 0
            annotateRectangleButton.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            currentAnnotation = nil
            self.resetImage()
        }
    }
    
    private func resetImage() {
        guard let view = annotatedImageView, let image = originalImage else {
            return
        }
        
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        image.draw(at: CGPoint.zero)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.image = newImage
    }
    
    @IBAction func submitButtonClick(_ sender: Any) {
        guard let label = annotationNameTextField.text,
            let imageData = imageData,
            let currentAnnotation = currentAnnotation,
            let activeCampaign = activeCampaign else {
            return
        }
        
        if annotationNameTextField.text?.count == 0 || currentAnnotation == nil {
            return
        }
        
        var type = "polygon"
        
        let request = AnnotationCreationRequest(points: currentAnnotation.getAPIPoints(), type: type, label: label, userId: 1)
        DefaultAPI.postImageAnnotation(campaignId: activeCampaign._id, imageId: imageData._id, request: request, completion: { (annotation, error) in
            print(annotation, error)
        })
        
        self.performSegue(withIdentifier: "annotateToCampaignInfo", sender: nil)
    }
}

