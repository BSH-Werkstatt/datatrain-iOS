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
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let point = tapGestureRecognizer.location(in: tappedImage)
        print(point)
        
        // TODO: 2 taps to create the rectangle, later using dragging
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
        })
    }
    
    private func returnToCampaignInfo() {
        self.performSegue(withIdentifier: "annotateToCampaignInfo", sender: nil)
    }
    
    @IBAction func annotationButtonClick(_ sender: Any) {
        guard let activeCampaign = activeCampaign, let imageData = imageData, let image = annotatedImageView.image else {
            return
        }
        
        if annotationStage == 0 {
            annotationStage = 1
            currentAnnotation = RectangularAnnotation(topLeft: Point(x: 50, y: 50), bottomRight: Point(x: 150, y: 150), userId: 1, campaignId: activeCampaign._id, imageId: imageData._id)
            currentAnnotation?.draw(image: image, view: annotatedImageView)
        } else {
            annotationStage = 0
            currentAnnotation = nil
        }
    }
    
    @IBAction func submitButtonClick(_ sender: Any) {
        
    }
}
