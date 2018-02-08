//
//  MemeEditorViewController.swift
//  MemeMe1.0
//
//  Created by Raphael Araújo on 2018-02-01.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import AVFoundation
class MemeEditorViewController: UIViewController {
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextConstraint: NSLayoutConstraint!

    private var image: UIImage?
    
    private var textDistanceFromImageBorder: CGFloat = 25.0

    private let defaultTopText = "TOP"
    private let defaultBottomText = "BOTTOM"
    
    private var meme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraButton.isEnabled = isCameraAccesible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        
        if let i = image {
            self.displayImage(image: i)
            self.shareButton.isEnabled = true
        } else {
            self.shareButton.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adjustTextDistanceFromBorder(forDeviceOrientation: UIDevice.current.orientation)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.adjustTextDistanceFromBorder(forDeviceOrientation: UIDevice.current.orientation)
    }
    
    private func adjustTextDistanceFromBorder(forDeviceOrientation deviceOrientation: UIDeviceOrientation) {
        DispatchQueue.main.async {
            var framePosition: CGFloat = 0
            
            if self.image != nil {
                let imageFrame = AVMakeRect(aspectRatio: self.imageView.image!.size, insideRect: self.imageView.bounds)
                
                let imageViewHeight = self.imageView.frame.size.height
                framePosition = (imageViewHeight-imageFrame.size.height)/2
            }
            if deviceOrientation.isLandscape {
                self.textDistanceFromImageBorder = 10.0
            } else {
                self.textDistanceFromImageBorder = 25.0
            }
            self.topTextConstraint.constant = -(framePosition + self.textDistanceFromImageBorder)
            self.bottomTextConstraint.constant = (framePosition + self.textDistanceFromImageBorder)
        }
    }
    
    @objc func deviceDidRotate(){
        self.adjustTextDistanceFromBorder(forDeviceOrientation: UIDevice.current.orientation)
    }
    
//MARK: -- IBAction
    @IBAction func cameraButtonTapped(sender: Any) {
        self.presentImagePicker(source: .camera, onViewController: self)
    }
    
    @IBAction func albumButtonTapped(sender: Any) {
        self.presentImagePicker(source: .photoLibrary, onViewController: self)
    }
    
    @IBAction func cancelButtonTapped(sender: Any) {
        self.resetViews()
    }
    
    @IBAction func shareButtonTapped(sender: Any) {
        if let meme = createMeme() {
            DispatchQueue.main.async {
                self.showActivityController(withMeme: meme)
            }
        }
    }
    
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
//MARK: -- Check Camera Accessibility
    private func isCameraAccesible() -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear)
    }

//MARK: -- Show image

    private func displayImage(image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
        
            let imageFrame = AVMakeRect(aspectRatio: self.imageView.image!.size, insideRect: self.imageView.bounds)

            let imageViewHeight = self.imageView.frame.size.height
            
            self.topTextConstraint.constant = -((imageViewHeight-imageFrame.size.height)/2 + self.textDistanceFromImageBorder)
            self.bottomTextConstraint.constant = ((imageViewHeight-imageFrame.size.height)/2 + self.textDistanceFromImageBorder)
        }
    }
    
    private func createMeme() -> Meme?{
        let imageFrame = AVMakeRect(aspectRatio: self.imageView.image!.size, insideRect: self.imageView.bounds)
        
        var memeTexts = [String: NSAttributedString]()
        var memeTextsPositions = [String: CGPoint]()
        if self.topTextField.text != "" {
            let topText = self.topTextField.attributedText!
            let topTextX = imageFrame.size.width/2 - self.topTextField.frame.size.width/2
            memeTexts.updateValue(topText, forKey: "top")
            memeTextsPositions.updateValue(CGPoint(x: topTextX,y:textDistanceFromImageBorder), forKey: "top")
        }
        
        if self.bottomTextField.text != ""{
            let bottomText = self.bottomTextField.attributedText!
            let bottomTextX = imageFrame.size.width/2 - self.bottomTextField.frame.size.width/2
            let bottomTextY = imageFrame.size.height - (self.bottomTextField.frame.size.height + self.textDistanceFromImageBorder)
            memeTexts.updateValue(bottomText, forKey: "bottom")
            memeTextsPositions.updateValue(CGPoint(x: bottomTextX,y:bottomTextY), forKey: "bottom")
        }
        
        let meme = Meme(texts: memeTexts, toImage: self.imageView.image!, withImageSize: imageFrame.size, atPositions: memeTextsPositions)
        return meme
    }
}

//MARK: -- UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentImagePicker(source: UIImagePickerControllerSourceType, onViewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = source
        imagePickerController.allowsEditing = true
        DispatchQueue.main.async {
            onViewController.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.image = editedImage
        } else {
            guard let i = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            self.image = i
        }
        DispatchQueue.main.async {
            self.topTextField.text = self.defaultTopText
            self.bottomTextField.text = self.defaultBottomText
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
//MARK: -- ActivityViewController Handler

extension MemeEditorViewController {
    private func showActivityController(withMeme meme: Meme) {
        let activityController = UIActivityViewController(activityItems: [meme.image!], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed || error == nil {
                self.meme = meme
            }
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
}
//MARK: -- View configuration
extension MemeEditorViewController {
    private func resetViews() {
        DispatchQueue.main.async {
            self.imageView.image = nil
            self.image = nil
           
            if UIDevice.current.orientation.isLandscape {
                self.textDistanceFromImageBorder = 10.0
            } else {
                self.textDistanceFromImageBorder = 25.0
            }
            self.topTextConstraint.constant = -self.textDistanceFromImageBorder
            self.bottomTextConstraint.constant = self.textDistanceFromImageBorder
            
            self.topTextField.text = self.defaultTopText
            self.bottomTextField.text = self.defaultBottomText
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if self.bottomTextField.isEditing {
            if let userInfo = notification.userInfo {
                let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
                let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                
                let viewOriginFrame: CGFloat!
                
                if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                    viewOriginFrame = 0
                } else {
                    viewOriginFrame = -200
                }
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: {
                                self.view.frame.origin.y = viewOriginFrame
                                self.view.layoutIfNeeded() },
                               completion: nil)
            }
        }
    }
}

extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let txtField = textField as? CustomTextField {
            textField.attributedText = txtField.strokeText()
        }
    }
}

