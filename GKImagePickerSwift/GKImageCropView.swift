//
//  GKImageCropView.swift
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
// import QuartzCore

class GKImageCropView: UIView, UIScrollViewDelegate {
    
    private func rad(_ angle: CGFloat) -> CGFloat {
        return angle / CGFloat(180.0) * CGFloat(M_PI)
    }
    
    private func GKScaleRect(rect: CGRect, scale: CGFloat) -> CGRect {
        return CGRect.init(x: rect.origin.x * scale,
                           y: rect.origin.y * scale,
                           width: rect.size.width * scale,
                           height: rect.size.height * scale)
    }
    
    lazy var scrollView: ScrollView = {
        let view = ScrollView.init()
        view.showsHorizontalScrollIndicator = true
        view.showsVerticalScrollIndicator = true
        view.clipsToBounds = false
        view.decelerationRate = 0.0
        view.backgroundColor = UIColor.clear
        view.maximumZoomScale = 20.0
        view.setZoomScale(1.0, animated: true)

        return view
    } ()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView.init()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .black
        
        return view

    } ()
    
    var cropOverlayView: GKImageCropOverlayView? = nil
    
    var xOffset: CGFloat = 0.0
    var yOffset: CGFloat = 0.0
    
    var hasResizableCropArea = false
    
    var imageToCrop: UIImage? = nil {
        didSet {
            self.imageView.image = self.imageToCrop
        }
    }

    var cropSize: CGSize? {
        didSet {
            if hasResizableCropArea {
                self.cropOverlayView = GKResizeableCropOverlayView.init(frame: self.bounds)
                self.cropOverlayView?.initialSize = self.cropSize!
            } else {
                self.cropOverlayView = GKImageCropOverlayView.init(frame: self.bounds)
            }
            self.cropOverlayView?.cropSize = self.cropSize
            addSubview(self.cropOverlayView!)
            self.layoutSubViews()
        }
    }
    
    // MARK: - Public Methods
    
    func croppedImage() -> UIImage? {
        let image = self.imageToCrop

        //Calculate rect that needs to be cropped
        var visibleRect = self.hasResizableCropArea ? _calcVisibleRectForResizeableCropArea() : _calcVisibleRectForCropArea()
    
        //transform visible rect to image orientation
        let rectTransform: CGAffineTransform = _orientationTransformedRectOfImage(img: image!)
        
        visibleRect = visibleRect.applying(rectTransform)
    
        //finally crop image
        if let imageRef = (self.imageToCrop!.cgImage)!.cropping(to: visibleRect) {
            return UIImage.init(cgImage: imageRef, scale: self.imageToCrop!.scale, orientation: self.imageToCrop!.imageOrientation)
        } else {
            return nil
        }
    }
    
    private func _calcVisibleRectForResizeableCropArea() -> CGRect {
        if let resizableView = cropOverlayView as? GKResizeableCropOverlayView {
    
            //first of all, get the size scale by taking a look at the real image dimensions. Here it doesn't matter if you take
            //the width or the hight of the image, because it will always be scaled in the exact same proportion of the real image
            var sizeScale = self.imageView.image!.size.width / self.imageView.frame.size.width
            sizeScale *= self.scrollView.zoomScale
    
            //then get the position of the cropping rect inside the image
            
            let visibleRect = resizableView.contentView.convert(resizableView.contentView.bounds, to: imageView)
            return GKScaleRect(rect: visibleRect, scale: sizeScale)
        }
        return CGRect.zero
    }
    
    private func _calcVisibleRectForCropArea() -> CGRect {
    //scaled width/height in regards of real width to crop width
        if let validImageToCrop = imageToCrop {
            let scaleWidth = validImageToCrop.size.width / cropSize!.width
            let scaleHeight = validImageToCrop.size.height / cropSize!.height
            var scale = CGFloat(0.0)
    
            if validImageToCrop.size.width > validImageToCrop.size.height {
                scale = validImageToCrop.size.width < validImageToCrop.size.height ?
                    max(scaleWidth, scaleHeight) :
                    min(scaleWidth, scaleHeight);
            } else {
                scale = validImageToCrop.size.width < validImageToCrop.size.height ?
                    min(scaleWidth, scaleHeight) :
                    max(scaleWidth, scaleHeight);
            }
            
            //extract visible rect from scrollview and scale it
            let visibleRect = scrollView.convert(scrollView.bounds, to: imageView)
            return GKScaleRect(rect: visibleRect, scale: scale)
        }
        return CGRect.zero
    }
    
    
    private func _orientationTransformedRectOfImage(img: UIImage) -> CGAffineTransform {
    // {
        var rectTransform = CGAffineTransform()
        switch (img.imageOrientation) {
            case .left:
                rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -img.size.height);
                break
            case .right:
                rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -img.size.width, y: 0);
                break
            case .down:
                rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -img.size.width, y: -img.size.height);
                break
            default:
                rectTransform = .identity;
        }
    
        return rectTransform.scaledBy(x: img.scale, y: img.scale);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = true
        backgroundColor = UIColor.black
        
        self.scrollView.frame = self.bounds
        self.scrollView.delegate = self
        addSubview(scrollView)
    
        self.scrollView.addSubview(imageView)
    
        self.scrollView.minimumZoomScale = scrollView.frame.width / imageView.frame.width
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if hasResizableCropArea {
        
            if let resizeableCropView: GKResizeableCropOverlayView = cropOverlayView as? GKResizeableCropOverlayView {
        
                let outerFrame = resizeableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10)
                if outerFrame.contains(point) {
                    if (resizeableCropView.cropBorderView.frame.size.width < 60 || resizeableCropView.cropBorderView.frame.size.height < 60 ) {
                        return super.hitTest(point, with: event)
                    }
                    let innerTouchFrame = resizeableCropView.cropBorderView.frame.insetBy(dx: 30, dy: 30)
                    if innerTouchFrame.contains(point) {
                        return scrollView
                    }
                
                    let outBorderTouchFrame = resizeableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10)
                    if outBorderTouchFrame.contains(point) {
                        return super.hitTest(point, with: event)
                    }
            
                    return super.hitTest(point, with: event)
                }
            }
        }
        return scrollView;
    }
    
    func layoutSubViews() {
        super.layoutSubviews()
        // guard imageToCrop != nil && cropSize != nil else { return }
        
        let toolbarSize = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(0.0) : CGFloat(54.0)
        xOffset = floor((self.bounds.width - cropSize!.width) * 0.5)
        yOffset = floor((self.bounds.height - toolbarSize - cropSize!.height) * 0.5); //fixed
            
        let height = imageToCrop!.size.height
        let width = imageToCrop!.size.width
            
        var faktor = CGFloat(0.0)
        var faktoredHeight = CGFloat(0.0)
        var faktoredWidth = CGFloat(0.0)
            
        if width > height {
            faktor = width / cropSize!.width;
            faktoredWidth = cropSize!.width;
            faktoredHeight =  height / faktor;
        } else {
            faktor = height / cropSize!.height;
            faktoredWidth = width / faktor;
            faktoredHeight =  cropSize!.height;
        }
            
        cropOverlayView?.frame = self.bounds;
        scrollView.frame = CGRect.init(x: xOffset, y: yOffset, width: cropSize!.width, height: cropSize!.height)
        scrollView.contentSize = imageView.bounds.size // CGSize.init(width: cropSize!.width, height: cropSize!.height)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        imageView.frame = CGRect.init(x: 0, y: floor((cropSize!.height - faktoredHeight) * 0.5), width: faktoredWidth, height: faktoredHeight)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
