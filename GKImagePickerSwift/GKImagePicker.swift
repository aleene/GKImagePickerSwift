//
//  GKImagePicker.swift
//  GKImagePickerSwift
//
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift 3.0 by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

open class GKImagePicker: NSObject {

    var imagePickerController: UIImagePickerController? = nil {
        didSet {
            self.imagePickerController?.delegate = self
            // self.imagePickerController?.sourceType = .photoLibrary
        }
    }

    var cropSize = CGSize.zero
    
    var delegate: GKImagePickerDelegate? = nil
    
    var hasResizeableCropArea = false
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
            imagePickerController?.dismiss(animated: animated, completion: nil)
    }
}

// MARK: - UIImagePickerDelegate Methods


extension GKImagePicker: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        delegate?.imagePicker(self, cropped:croppedImage!)
    }
}


// These delegates are called when the user has selected an image from the library.

extension GKImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.imagePickerDidCancel(self)
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if image != nil {
            let cropController = GKImageCropViewController.init()
            
            cropController.view.frame = self.imagePickerController!.view!.bounds
            // cropController.preferredContentSize = picker.preferredContentSize;
            cropController.sourceImage = image
            cropController.hasResizableCropArea = self.hasResizeableCropArea;
            cropController.cropSize = self.cropSize;
            cropController.delegate = self;

            picker.pushViewController(cropController, animated: true)
        }
    }

}
