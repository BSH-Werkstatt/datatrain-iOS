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
import NotificationBannerSwift

// MARK: - AnnotateImageViewController
class AnnotateImageViewController: CUUViewController, UITextFieldDelegate {
    // MARK: - Overriden IBOutlets
    @IBOutlet private weak var imageLayerContainer: UIView!
    @IBOutlet private weak var annotateRectangleButton: UIButton!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var labelButton: UIButton!
    
    private var magnifyView: MagnifyView?
    private var annotationViews: [AnnotationView] = []
    private var currentAnnotationView: AnnotationView?
    private var selectedAnnotationView: AnnotationView?
    private var imageView: UIImageView!
    private var activeCampaign: Campaign?
    var imageData: ImageData?
    private var originalImage: UIImage?
    private var mainViewInitialY: CGFloat!
    private var annotationEnabled: Bool = false
    
    private var offsetX: CGFloat = -1.0
    private var offsetY: CGFloat = -1.0
    private var sizeImageX: CGFloat = -1.0
    private var sizeImageY: CGFloat = -1.0

    
    // TODO: This should be refactored as deleteButtonClick
    @IBAction func annotationButtonClick(_ sender: Any) {
        selectedAnnotationView?.annotation = nil
        selectedAnnotationView?.selected = false
        selectedAnnotationView?.removeFromSuperview()
        selectedAnnotationView = nil
        labelButton.setTitle("Select Label", for: .normal)
    }

    // MARK: - Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // intialize main view offsets because of the keyboard
        mainViewInitialY = mainView.frame.origin.y
        // load data
        // Disable moving back by swipe - They conflict with annotation gestures
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        loadActiveCampaign()
        getImage()
        addKeyboardShiftListner()
    }
}

// MARK: - Load Data Functionality
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
        imageView = UIImageView()
        guard let imageView = imageView else {
            print("Cannot initialize image view.")
            return
        }
        imageView.frame = imageLayerContainer.bounds
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = UIImage(data: data)
        imageView.center = CGPoint(x: imageLayerContainer.frame.size.width / 2, y: imageLayerContainer.frame.size.height / 2)
        self.imageLayerContainer.addSubview(imageView)
        
        let (offsetX, offsetY, imageSizeX, imageSizeY, imageScale) = calculateImageLayoutParameters()
        AnnotationView.setOffsetVariables(offsetX: offsetX, offsetY: offsetY)
        AnnotationView.setImageSize(imageSizeX: imageSizeX, imageSizeY: imageSizeY)
        AnnotationView.setImageScale(imageScale: imageScale)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectAnnotation(tapGestureRecognizer:)))
        imageLayerContainer.isUserInteractionEnabled = true
        imageLayerContainer.addGestureRecognizer(tapGestureRecognizer)
    }
}


// MARK: - Basic Layout Functionality
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
// MARK: - Touch overrides
extension AnnotateImageViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isPointInsideImage(point: touches.first!.location(in: imageView)) {
            return
        }
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
        annotation.annotationView = annotationView // Set the delegate view
        
        
        super.touchesBegan(touches, with: event)
        let touch = touches.first! as UITouch
        let point = touch.location(in: imageView)
        annotationView.annotation?.addPoint(point: point)

        annotationViews.append(annotationView)
        currentAnnotationView = annotationView
        currentAnnotationView?.setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If there is no uncompleted annotation, return
        guard let completed = currentAnnotationView?.annotation?.completed else {
            return
        }
        if completed {
            return
        }
        
        super.touchesMoved(touches, with: event)
        let touch = touches.first! as UITouch
        var point = touch.location(in: imageView)
        point = bringPointInsideImageBounds(point: point)
        
        if let lastPoint = currentAnnotationView?.annotation?.points.last {
            if ((point.x - lastPoint.x) * (point.x - lastPoint.x) +
                (point.y - lastPoint.y) * (point.y - lastPoint.y) > 100) {
                currentAnnotationView?.annotation?.addPoint(point: point)
                if magnifyView == nil {
                    magnifyView = MagnifyView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                    magnifyView!.viewToMagnify = self.view.superview
                    magnifyView!.setTouchPoint(pt: touch.location(in: self.view.superview))
                    self.view.superview?.addSubview(magnifyView!)
                }
            }
        }
        
        magnifyView?.setTouchPoint(pt: touch.location(in: self.view.superview))
        magnifyView?.setNeedsDisplay()
        
        currentAnnotationView?.annotation?.temporaryPoint = point
        currentAnnotationView?.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If there is no uncompleted annotation, return
        guard let completed = currentAnnotationView?.annotation?.completed else {
            return
        }
        if completed {
            return
        }
        super.touchesEnded(touches, with: event)
        
        if magnifyView != nil {
            magnifyView!.removeFromSuperview()
            magnifyView = nil
        }
        
        currentAnnotationView?.annotation?.completed = true
        currentAnnotationView?.setNeedsDisplay()
        labelButton.setTitle("Select Label", for: .normal)
        selectedAnnotationView?.selected = false
        selectedAnnotationView?.setNeedsDisplay()
        selectedAnnotationView = currentAnnotationView
        currentAnnotationView?.selected = true
        currentAnnotationView = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if magnifyView != nil {
            magnifyView!.removeFromSuperview()
            magnifyView = nil
        }
        // If there is no uncompleted annotation, return
        guard let completed = currentAnnotationView?.annotation?.completed else {
            return
        }
        if completed {
            return
        }
        if let count = currentAnnotationView?.annotation?.points.count, count <= 1 {
            currentAnnotationView?.annotation = nil
            currentAnnotationView?.removeFromSuperview()
            return
        }    }
    
    @objc func selectAnnotation(tapGestureRecognizer: UITapGestureRecognizer) {
        if imageLayerContainer.subviews.count == 0 {
            return
        }
        for index in 0...imageLayerContainer.subviews.count - 1 {
            if imageLayerContainer.subviews[imageLayerContainer.subviews.count - 1 - index] is AnnotationView {
                let subview = imageLayerContainer.subviews[imageLayerContainer.subviews.count - 1 - index] as! AnnotationView
                if subview.isPointInsideAnnotation(point: tapGestureRecognizer.location(in: imageLayerContainer)) {
                    selectedAnnotationView?.selected = false
                    selectedAnnotationView?.setNeedsDisplay()
                    
                    subview.selected = true
                    subview.setNeedsDisplay()
                    selectedAnnotationView = subview
                    labelButton.setTitle(subview.annotation!.label == "" ? "Select Label" : subview.annotation!.label, for: .normal)
                    return
                }
            }
        }
    }
}

// MARK: - Helper functions
extension AnnotateImageViewController {
    func calculateImageLayoutParameters() -> (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat) {
        guard let image = imageView.image else {
            print("Image should not be null at this point")
            return (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        }
        var offsetX = CGFloat(0.0)
        var offsetY = CGFloat(0.0)
        var imageSizeX = CGFloat(0.0)
        var imageSizeY = CGFloat(0.0)
        var imageScaleRatio = CGFloat(0.0)
        
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
        
        imageScaleRatio = imageSizeX / image.size.width
        return (offsetX, offsetY, imageSizeX, imageSizeY, imageScaleRatio)
    }
    
    func isPointInsideImage(point: CGPoint) -> Bool {
        if offsetX == -1 {
            (offsetX, offsetY, sizeImageX, sizeImageY, _) = calculateImageLayoutParameters()
        }
        if point.x < offsetX || point.y < offsetY || point.x > offsetX + sizeImageX || point.y > offsetY + sizeImageY {
            return false
        }
        return true
    }
    
    func bringPointInsideImageBounds(point: CGPoint) -> CGPoint {
        if offsetX == -1 {
            (offsetX, offsetY, sizeImageX, sizeImageY, _) = calculateImageLayoutParameters()
        }
        var x = point.x
        var y = point.y

        if point.x < offsetX {
            x = offsetX
        }
        if point.y < offsetY {
            y = offsetY
        }
        if point.x > offsetX + sizeImageX {
            x = offsetX + sizeImageX
        }
        if point.y > offsetY + sizeImageY {
            y = offsetY + sizeImageY
        }
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Choose Label Functionality
extension AnnotateImageViewController {
    @IBAction func showLabelPopup(_ sender: Any) {
        guard let activeCampaign = activeCampaign else {
            return
        }
        
        if selectedAnnotationView == nil {
            let alertController = UIAlertController(title: "Select an annotation", message: "Please select an annotation for to label.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let controller = ArrayChoiceTableViewController(activeCampaign.taxonomy.sorted()) { (label) in
            self.labelButton.setTitle(label, for: .normal)
            self.selectedAnnotationView?.annotation?.label = label
        }
        controller.preferredContentSize = CGSize(width: 300, height: 200)
        showPopup(controller, sourceView: sender as! UIView)
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
    }
}

// MARK: - Save Annotation Functionality
extension AnnotateImageViewController {
    private func returnToCampaignInfo() {
        // TODO: Handle errors
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func submitButtonClick(_ sender: Any) {
        guard let imageData = imageData,
            let activeCampaign = activeCampaign else {
            return
        }
        
        // Make sure that all annotations have labels.
        for subview in imageLayerContainer.subviews {
            if !(subview is AnnotationView) {
                continue
            }
            let subview = subview as! AnnotationView
            guard let label = subview.annotation?.label else {
                let alertController = UIAlertController(title: "Annotations missing", message: "Please make sure that all annotations have labels.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            if label == "" {
                let alertController = UIAlertController(title: "Annotations missing", message: "Please make sure that all annotations have labels.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }

        // this is the mask RCNN type
        let type = "polygon"
        var annotationItems: [AnnotationCreationRequestItem] = []
        imageLayerContainer.subviews.forEach({ (view: UIView) -> Void in
            if !(view is AnnotationView) {
                return
            }
            let view = view as! AnnotationView
            guard let annotation = view.annotation else {
                return
            }
            let annotationItem = AnnotationCreationRequestItem(points: annotation.getAPIPoints(), type: type, label: annotation.label)
            annotationItems.append(annotationItem)
        })
        if annotationItems.count == 0 {
            let alertController = UIAlertController(title: "No annotations", message: "Please make sure that there is at least one annotation.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let request = AnnotationCreationRequest(items: annotationItems, userToken: "5d0a6fe5a9edbb9d5cc29e10")
        DefaultAPI.postImageAnnotation(campaignId: activeCampaign._id, imageId: imageData._id, request: request, completion: { (annotation, error) in
            print("Annotation result", annotation, error)
            if error == nil {
                // Show notification for succesful upload
                let banner = NotificationBanner(title: "Success", subtitle: "Annotation is successfully submitted.", style: .success)
                banner.show()
            }
        })
        for view in imageLayerContainer.subviews {
            view.removeFromSuperview()
        }
        selectedAnnotationView = nil
        self.magnifyView = nil
        self.annotationViews = []
        self.imageView = nil
        self.imageData = nil
        self.originalImage = nil
        self.annotationEnabled = false
        self.offsetX = -1.0
        self.offsetY = -1.0
        self.sizeImageX = -1.0
        self.sizeImageY = -1.0
        getImage()
    }
}

