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
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet private weak var undoButton: UIBarButtonItem!
    @IBOutlet private weak var redoButton: UIBarButtonItem!
    @IBAction func undoButtonClick(_ sender: Any) {
        undoManager?.undo()
        redoButton.isEnabled = true
        if !(undoManager?.canUndo ?? false) {
            undoButton.isEnabled = false
        }
    }
    
    @IBAction func redoButtonClick(_ sender: Any) {
        undoManager?.redo()
        undoButton.isEnabled = true
        if !(undoManager?.canRedo ?? false) {
            redoButton.isEnabled = false
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var magnifyView: MagnifyView?
    private var annotationViews: [AnnotationView] = []
    private var currentAnnotationView: AnnotationView?
    private(set) var drawingEnabled: Bool = false
    private var imageLoaded = false
    private var selectedAnnotationView: AnnotationView?
    private var imageView: UIImageView!
    var activeCampaign: Campaign?
    var imageData: ImageData?
    private var originalImage: UIImage?
    private var mainViewInitialY: CGFloat!
    
    private var offsetX: CGFloat = -1.0
    private var offsetY: CGFloat = -1.0
    private var sizeImageX: CGFloat = -1.0
    private var sizeImageY: CGFloat = -1.0

    private var nextImage: Data?
    private var nextImageData: ImageData?

    private func initializeAnnotationView(userId: String, campaignId: String, imageId: String, point: CGPoint) {
        drawingEnabled = true
        let annotationView = AnnotationView()
        annotationView.delegate = self
        annotationView.frame = view.bounds
        annotationView.backgroundColor = UIColor.clear
        annotationView.isOpaque = false
        
        imageLayerContainer.addSubview(annotationView)
        let annotation = Annotation(userId: userId, campaignId: campaignId, imageId: imageId)
        annotationView.annotation = annotation
        annotation.annotationView = annotationView // Set the delegate view
        annotationView.annotation?.addPoint(point: point)
        
        annotationViews.append(annotationView)
        currentAnnotationView = annotationView
        currentAnnotationView?.setNeedsDisplay()
        
        selectedAnnotationView?.selected = false
        selectedAnnotationView?.setNeedsDisplay()
        selectedAnnotationView = nil
    }
    
    private func undoInitializeAnnotationView(annotationView: AnnotationView) {
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.imageLayerContainer.addSubview(annotationView)
            target.annotationViews.append(annotationView)
            target.currentAnnotationView = annotationView
            target.currentAnnotationView?.setNeedsDisplay()
            target.selectedAnnotationView?.selected = false
            target.selectedAnnotationView?.setNeedsDisplay()
            target.selectedAnnotationView = nil
        })
        annotationView.removeFromSuperview()
        currentAnnotationView = nil
    }
    
    private func addPointToAnnotationView(point: CGPoint, magnifierPoint: CGPoint) {
        let point = bringPointInsideImageBounds(point: point)
        if let lastPoint = currentAnnotationView?.annotation?.points.last {
            if (point.x - lastPoint.x > 7 || point.y - lastPoint.y > 7 || point.x - lastPoint.x < -7 || point.y - lastPoint.y < -7) {
                addPoint(point: point)
                if magnifyView == nil {
                    magnifyView = MagnifyView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                    magnifyView!.viewToMagnify = self.view.superview
                    magnifyView!.minY = imageLayerContainer.bounds.minY
                    self.view.superview?.addSubview(magnifyView!)
                    magnifyView!.setTouchPoint(pt: magnifierPoint)
                }
            }
        }
        magnifyView?.setTouchPoint(pt: magnifierPoint)
        magnifyView?.setNeedsDisplay()
        currentAnnotationView?.annotation?.temporaryPoint = point
        currentAnnotationView?.setNeedsDisplay()
    }
    
    private func addPoint(point: CGPoint) {
        currentAnnotationView?.annotation?.addPoint(point: point)
        currentAnnotationView?.annotation?.temporaryPoint = point
        currentAnnotationView?.setNeedsDisplay()
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.undoAddPoint()
        })
        undoButton.isEnabled = true
    }
    
    private func undoAddPoint() {
        if let removedPoint = currentAnnotationView?.annotation?.points.popLast() {
            currentAnnotationView?.annotation?.temporaryPoint = nil
            currentAnnotationView?.annotation?.temporaryPoint = currentAnnotationView?.annotation?.endPoint
            drawingEnabled = false
            currentAnnotationView?.setNeedsDisplay()
            if let currentAnnotationView = currentAnnotationView, currentAnnotationView.annotation?.points.count ?? 1 == 1 {
                undoInitializeAnnotationView(annotationView: currentAnnotationView)
            }
            undoManager?.registerUndo(withTarget: self, handler: { (target) in
                target.addPoint(point: removedPoint)
            })
        }
    }
    
    private func completeAnnotationPath() {
        if let currentAnnotationView = currentAnnotationView {
            undoManager?.registerUndo(withTarget: self, handler: { (target) in
                target.undoCompleteAnnotationPath(annotationView: currentAnnotationView)
            })
            undoButton.isEnabled = true
            currentAnnotationView.annotation?.completed = true
            currentAnnotationView.setNeedsDisplay()
            labelButton.setTitle("Select Label", for: .normal)
            selectedAnnotationView?.selected = false
            selectedAnnotationView?.setNeedsDisplay()
            selectedAnnotationView = currentAnnotationView
            currentAnnotationView.selected = true
            self.currentAnnotationView = nil
            removeButton.isEnabled = true
            drawingEnabled = false
        }
    }
    
    private func undoCompleteAnnotationPath(annotationView: AnnotationView) {
        drawingEnabled = true
        annotationView.annotation?.completed = false
        annotationView.selected = false
        annotationView.setNeedsDisplay()
        selectedAnnotationView = nil
        currentAnnotationView = annotationView
        removeButton.isEnabled = true
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.completeAnnotationPath()
        })
    }
    
    private func removeLastAnnotatation() {
        if let selectedAnnotationView = selectedAnnotationView {
            undoManager?.registerUndo(withTarget: self, handler: { (target) in
                target.undoRemoveLastAnnotatation(annotationView: selectedAnnotationView)
            })
            selectedAnnotationView.removeFromSuperview()
            self.selectedAnnotationView = nil
        } else if let currentAnnotationView = currentAnnotationView {
            undoManager?.registerUndo(withTarget: self, handler: { (target) in
                target.undoRemoveLastAnnotatation(annotationView: currentAnnotationView)
            })
            currentAnnotationView.removeFromSuperview()
            self.currentAnnotationView = nil
        }
        undoButton.isEnabled = true
        labelButton.setTitle("Show Labels", for: .normal)
        removeButton.isEnabled = false
    }
    
    private func undoRemoveLastAnnotatation(annotationView: AnnotationView) {
        if annotationView.annotation?.completed ?? false {
            selectedAnnotationView = annotationView
        } else {
            currentAnnotationView = annotationView
        }
        imageLayerContainer.addSubview(annotationView)
        annotationView.setNeedsDisplay()
        if let label = annotationView.annotation?.label, label != "" {
            labelButton.setTitle(label, for: .normal)
        } else {
            labelButton.setTitle("Set Label", for: .normal)
        }
        removeButton.isEnabled = true
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.removeLastAnnotatation()
        })
    }
    
    private func changeAnnotationLabel(labelView: UILabel, labelText: String, selectedAnnotationView: AnnotationView) {
        guard let annotation = selectedAnnotationView.annotation else {
            return
        }
        let oldLabelText = annotation.label
        annotation.label = labelText
        labelView.text = labelText
        labelView.frame = CGRect(x: selectedAnnotationView.surroundingRect.bounds.minX,
                             y: selectedAnnotationView.surroundingRect.bounds.maxY,
                             width: labelView.intrinsicContentSize.width + 15, height: labelView.intrinsicContentSize.height + 3)
        labelView.setNeedsDisplay()
        self.labelButton.setTitle(labelText, for: .normal)
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.changeAnnotationLabel(labelView: labelView, labelText: oldLabelText, selectedAnnotationView: selectedAnnotationView)
        })
        undoButton.isEnabled = true
    }
    
    private func selectAnnotation(subview: AnnotationView) {
        selectedAnnotationView?.selected = false
        selectedAnnotationView?.setNeedsDisplay()
        removeButton.isEnabled = true
        subview.selected = true
        subview.setNeedsDisplay()
        selectedAnnotationView = subview
        labelButton.setTitle(subview.annotation!.label == "" ? "Select Label" : subview.annotation!.label, for: .normal)
    }
    
    // TODO: This should be refactored as deleteButtonClick
    @IBAction func deleteButtonClick(_ sender: Any) {
        removeLastAnnotatation()
    }
    
    @IBAction func handlePanGesturesWithOneFinger(panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            if !imageLoaded || !isPointInsideImage(point: panGestureRecognizer.location(in: imageView)) {
                return
            }
            guard let imageData = imageData, let activeCampaign = activeCampaign else {
                print("Cannot get image data or active campaign")
                return
            }
            guard let userId = UserDefaults.standard.string(forKey: "user-id") else {
                let banner = NotificationBanner(title: "Invalid user id", subtitle: "Please check if you are logged in correctly", style: .success)
                banner.show()
                return
            }

            // If there is already a current annotation view, we have to check if we touched in the endPoint
            if let currentAnnotationView = currentAnnotationView, let endPoint = currentAnnotationView.annotation?.endPoint,
                currentAnnotationView.annotation?.getLargePointRect(point: endPoint)?.contains(panGestureRecognizer.location(in: imageView)) ?? false  {
                drawingEnabled = true
                return
            }
            
            // There is no current annotation view, we will create a new one
            if currentAnnotationView != nil {
                return
            }
            initializeAnnotationView(userId: userId, campaignId: activeCampaign._id, imageId: imageData._id, point: panGestureRecognizer.location(in: imageView))
        case .changed:
            // If there is no uncompleted annotation, return
            guard let completed = currentAnnotationView?.annotation?.completed, !completed, drawingEnabled else {
                return
            }
            let point = panGestureRecognizer.location(in: imageView)
            let magnifierPoint = panGestureRecognizer.location(in: self.view.superview)
            addPointToAnnotationView(point: point, magnifierPoint: magnifierPoint)
        case .ended:
            currentAnnotationView?.setNeedsDisplay()
            // If there is no uncompleted annotation, return
            guard let completed = currentAnnotationView?.annotation?.completed, !completed else {
                return
            }
            if magnifyView != nil {
                magnifyView!.removeFromSuperview()
                magnifyView = nil
            }
            // If the end point collides with the start point, then complete the annotation,
            // else just disable drawing and wait for the user to start a new drawing from the current end point
            if let endPoint = currentAnnotationView?.annotation?.endPoint, let startPoint = currentAnnotationView?.annotation?.startPoint,
                let endPointRect = currentAnnotationView?.annotation?.getPointRect(point: endPoint),
                let startPointRect = currentAnnotationView?.annotation?.getPointRect(point: startPoint),
                endPointRect.intersects(startPointRect)  {
                completeAnnotationPath()
                return
            }
            drawingEnabled = false
        case .cancelled:
            drawingEnabled = false
            if magnifyView != nil {
                magnifyView!.removeFromSuperview()
                magnifyView = nil
            }
            // If there is no uncompleted annotation, return
            guard let completed = currentAnnotationView?.annotation?.completed, !completed else {
                return
            }
            if let count = currentAnnotationView?.annotation?.points.count, count <= 1 {
                // TODO(b.sen): Undo instead of deleting it
                currentAnnotationView?.annotation = nil
                currentAnnotationView?.removeFromSuperview()
                return
            }
            currentAnnotationView = nil
        default:
            return
        }
        
    }
    
    @IBAction func handlePanGesturesWithTwoFingers(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: self.view)
        if let view = panGestureRecognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        panGestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        
        // Animate pan gesture with two fingers
        if panGestureRecognizer.state == UIGestureRecognizer.State.ended {
            // 1
            let velocity = panGestureRecognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")

            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:panGestureRecognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:panGestureRecognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)

            // 5
            UIView.animate(withDuration: Double(slideFactor * 2),
                           delay: 0,
                           // 6
                options: UIView.AnimationOptions.curveEaseOut,
                animations: {panGestureRecognizer.view!.center = finalPoint },
                completion: nil)
        }
    }
    
    @IBAction func handlePinchGestures(pinchGestureRecognizer: UIPinchGestureRecognizer) {
        if let view = pinchGestureRecognizer.view {
            switch pinchGestureRecognizer.state {
            case .changed:
                if 1.0 / (AnnotationView.viewScale / pinchGestureRecognizer.scale) > 5 ||
                    1.0 / (AnnotationView.viewScale / pinchGestureRecognizer.scale) < 1 {
                    return
                }
                AnnotationView.viewScale /= pinchGestureRecognizer.scale
                let pinchCenter = CGPoint(x: pinchGestureRecognizer.location(in: view).x - view.bounds.midX,
                                          y: pinchGestureRecognizer.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                view.transform = transform
                pinchGestureRecognizer.scale = 1
                imageLayerContainer.subviews.forEach({ (subview: UIView) -> Void in subview.setNeedsDisplay() })
            default:
                return
            }
        }
    }
    
    @IBAction func handleLongPressGestures(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            if magnifyView == nil {
                magnifyView = MagnifyView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                magnifyView!.viewToMagnify = self.view.superview
                self.view.superview?.addSubview(magnifyView!)
                magnifyView!.setTouchPoint(pt: longPressGestureRecognizer.location(in: self.view.superview))
            }
        }
    }
    
    @IBAction func handleRotationGestures(rotationGestureRecognizer: UIRotationGestureRecognizer) {
        if let view = rotationGestureRecognizer.view {
            view.transform = view.transform.rotated(by: rotationGestureRecognizer.rotation)
            rotationGestureRecognizer.rotation = 0
        }
    }

    
    @IBAction func handleTapGestures(tapGestureRecognizer: UITapGestureRecognizer) {
        if let _ = currentAnnotationView, imageLayerContainer.subviews.count == 0 {
            return
        }
        for index in 0...imageLayerContainer.subviews.count - 1 {
            if imageLayerContainer.subviews[imageLayerContainer.subviews.count - 1 - index] is AnnotationView {
                let subview = imageLayerContainer.subviews[imageLayerContainer.subviews.count - 1 - index] as! AnnotationView
                if (subview.annotation?.completed ?? false) && subview.isPointInsideAnnotation(point: tapGestureRecognizer.location(in: imageLayerContainer)) {
                    selectAnnotation(subview: subview)
                    return
                }
            }
        }
    }
    
    override func viewDidLoad() {
        undoButton.isEnabled = false
        redoButton.isEnabled = false
        undoManager?.levelsOfUndo = 200
        
        //activityIndicator shown
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        labelButton.disclosureButton(baseColor: #colorLiteral(red: 0.1986669898, green: 0.1339524984, blue: 0.5312184095, alpha: 1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageLayerContainer.setNeedsUpdateConstraints()
    }
    
    // MARK: - Overriden Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // intialize main view offsets because of the keyboard
        mainViewInitialY = mainView.frame.origin.y
        // load data
        // Disable moving back by swipe - They conflict with annotation gestures
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        loadActiveCampaign()
        removeButton.isEnabled = false
        getImage()
        addKeyboardShiftListner()
        AnnotationView.viewScale = 1.0
        
        //activityIndicator hidden when image is loaded
        activityIndicator.stopAnimating()
    }
}

extension AnnotateImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
        if imageData == nil {
            if let nextImage = nextImage {
                imageData = nextImageData
                displayImage(data: nextImage)
                nextImageData = nil
                self.nextImage = nil
                loadNextImage()
            } else {
                DefaultAPI.getRandomImage(campaignId: activeCampaign._id, completion: downloadAndDisplayImage)
            }
        } else {
            downloadAndDisplayImage(self.imageData, nil)
        }
    }
    
    private func displayImage(data: Data) {
        imageView = UIImageView()
        guard let imageView = imageView else {
            print("Cannot initialize image view.")
            return
        }
        imageView.frame = imageLayerContainer.bounds
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = UIImage(data: data)
        imageView.center = CGPoint(x: -imageLayerContainer.frame.size.width / 2, y: imageLayerContainer.frame.size.height / 2)
        self.imageLayerContainer.addSubview(imageView)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.imageView.center = CGPoint(x: self.imageLayerContainer.frame.size.width / 2, y: self.imageLayerContainer.frame.size.height / 2)
        }, completion: nil)
        imageLoaded = true
        
        let (offsetX, offsetY, imageSizeX, imageSizeY, imageScale) = calculateImageLayoutParameters()
        AnnotationView.setOffsetVariables(offsetX: offsetX, offsetY: offsetY)
        AnnotationView.setImageSize(imageSizeX: imageSizeX, imageSizeY: imageSizeY)
        AnnotationView.setImageScale(imageScale: imageScale)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestures(tapGestureRecognizer:)))
        imageLayerContainer.isUserInteractionEnabled = true
        imageLayerContainer.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func loadNextImage() {
        DispatchQueue.background(background: {
            guard let activeCampaign = self.activeCampaign, self.nextImage != nil else {
                return
            }
            DefaultAPI.getRandomImage(campaignId: activeCampaign._id, completion: { (idata, error) in
                guard let idata = idata else {
                    return
                }
                // Proceed with getting the image
                self.nextImageData = idata
                guard let url = URL(string: idata.url), let data = try? Data(contentsOf: url) else {
                    return
                }
                self.nextImage = data
            })
        })
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
        // Proceed with getting the image
        guard let url = URL(string: iData.url),
            let data = try? Data(contentsOf: url) else {
                // TODO: show an alert that url does not exist
                self.returnToCampaignInfo()
                return
        }
        displayImage(data: data)
        loadNextImage()
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
        var labelsWillBeSelectable = labelButton.titleLabel?.text == "Show Labels" ? false : true
        let controller = ArrayChoiceTableViewController(delegateViewController: self, activeCampaign.taxonomy.sorted(), selectable: labelsWillBeSelectable) { (labelText) in
            if let selectedAnnotationView = self.selectedAnnotationView {
                if selectedAnnotationView.labelView == nil {
                    let labelView = UILabel()
                    labelView.backgroundColor = AnnotationView.selectedFillColor
                    labelView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    labelView.textAlignment = .center
                    labelView.font = UIFont.systemFont(ofSize: 14)
                    
                    selectedAnnotationView.addSubview(labelView)
                    selectedAnnotationView.labelView = labelView
                    self.changeAnnotationLabel(labelView: labelView, labelText: labelText, selectedAnnotationView: selectedAnnotationView)
                } else {
                    if let labelView = selectedAnnotationView.labelView {
                        self.changeAnnotationLabel(labelView: labelView, labelText: labelText, selectedAnnotationView: selectedAnnotationView)
                    }
                }
            }
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
        
        guard let userId = UserDefaults.standard.string(forKey: "user-id") else {
            let banner = NotificationBanner(title: "Invalid user id", subtitle: "Please check if you are logged in correctly", style: .success)
            banner.show()
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
        let request = AnnotationCreationRequest(items: annotationItems, userToken: userId)
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
        self.drawingEnabled = false
        self.offsetX = -1.0
        self.offsetY = -1.0
        self.sizeImageX = -1.0
        self.sizeImageY = -1.0
        undoManager?.removeAllActions()
        undoButton.isEnabled = false
        imageLoaded = false
        AnnotationView.viewScale = 1.0
        imageLayerContainer.transform = .identity
        imageLayerContainer.setNeedsUpdateConstraints()
        getImage()
    }
}
