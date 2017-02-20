//
//  ViewController.swift
//  GKImagePickerSwift
//
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift 3.0 by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var customBarButtonItem: UIBarButtonItem!
    
    @IBAction func customBarButtonItemTapped(_ sender: UIBarButtonItem) {
        self.imagePicker.cropSize = CGSize.init(width: 200, height: 100)
        self.imagePicker.hasResizeableCropArea = false
        
        //
        // http://www.thomashanning.com/uipopoverpresentationcontroller/
        //
        
        self.present(self.imagePicker.imagePickerController!, animated: true, completion: nil)
        if let popoverPresentationController = self.imagePicker.imagePickerController!.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.barButtonItem = self.customBarButtonItem
        }
    }
    
    @IBOutlet weak var appleBarButtonItem: UIBarButtonItem!
    
    @IBAction func appleBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        self.present(self.ctr, animated: true, completion: nil)
        if let popoverPresentationController = self.ctr.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.barButtonItem = self.appleBarButtonItem
        }

    }
    
    @IBOutlet weak var resizableBarButtonItem: UIBarButtonItem!
    
    @IBAction func resizableBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        self.imagePicker.cropSize = CGSize.init(width: 200, height: 200)
        self.imagePicker.hasResizeableCropArea = true
        
        self.present(self.imagePicker.imagePickerController!, animated: true, completion: nil)
        if let popoverPresentationController = self.imagePicker.imagePickerController!.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.barButtonItem = self.resizableBarButtonItem
        }
    }
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.delegate = self
        picker.imagePickerController = UIImagePickerController.init()
        picker.imagePickerController!.modalPresentationStyle = .popover
        picker.sourceType = .photoLibrary

        return picker
    }()
    
    private lazy var ctr: UIImagePickerController = {
        let controller = UIImagePickerController.init()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        controller.allowsEditing = true
        controller.modalPresentationStyle = .popover
        
        return controller
    }()
    
    @IBOutlet weak var imgView: UIImageView!
    
}

extension ViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {

        self.imgView.image = image;
        
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage? = nil
        if let validImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = validImage
        } else if let validImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = validImage
        }
        self.imgView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
 
// MARK: - UIPopoverPresentationControllerDelegate Functions

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - Popover delegation functions
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
    
}

