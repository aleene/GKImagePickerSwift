//
//  GKResizableCropOverlayView.swift
//  GKImagePickerSwift
//
//  Created by Patrick Thonhauser on 9/21/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift 3.0 by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class GKResizeableCropOverlayView: GKImageCropOverlayView {
    
    // MARK: - Overriden
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _addContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchPoint = touch?.location(in: cropBorderView)
        
        _theAnchor = _calcuateWhichBorderHandleIsTheAnchorPointFromHere(anchorPoint: touchPoint!)
        _fillMultiplyer()
        _resizingEnabled = true
        _startPoint = touch!.location(in: superview!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !_resizingEnabled { return }
        _resizeWithTouchPoint(point: touches.first!.location(in: superview!))
    }

    override var initialSize: CGSize {
        didSet {
            contentView.frame = _contentViewFrame
            cropBorderView.frame = _cropBorderViewFrame
        }
    }
    
    // MARK: - Views

    lazy var contentView: UIView = {
        return UIView.init(frame: self._contentViewFrame)
    } ()
    
    private var _contentViewFrame: CGRect {
        get {
            return CGRect.init(
                x: self.bounds.size.width / 2 - self.initialSize.width  / 2,
                y: (self.bounds.size.height - self.toolbarSize) / 2 - self.initialSize.height / 2,
                width: self.initialSize.width,
                height: self.initialSize.height)
        }
    }
    
    lazy var cropBorderView: GKCropBorderView = {
        return GKCropBorderView.init(frame: self._cropBorderViewFrame)
    } ()
    
    private var _cropBorderViewFrame: CGRect {
        get {
            return CGRect.init(
                x: self.frame.size.width / 2 - self.initialSize.width  / 2 - self.kBorderCorrectionValue,
                y: (self.frame.size.height - self.toolbarSize) / 2 - self.initialSize.height / 2 - self.kBorderCorrectionValue,
                width: self.initialSize.width + self.kBorderCorrectionValue * 2,
                height: self.initialSize.height + self.kBorderCorrectionValue * 2)
        }
    }
    
    // MARK: - Private vars
    
    private var _resizingEnabled = false
    private var _theAnchor = CGPoint.zero
    private var _startPoint = CGPoint.zero
    private var _resizeMultiplyer = GKResizeableViewBorderMultiplyer()
    
    private var toolbarSize: CGFloat {
        get {
            return UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(0.0) : CGFloat(54.0)
        }
    }

    private let kBorderCorrectionValue = CGFloat(12.0)
    
    private struct GKResizeableViewBorderMultiplyer {
        
        var widthMultiplyer: CGFloat = 1.0
        var heightMultiplyer: CGFloat = 1.0
        var xMultiplyer: CGFloat = 1.0
        var yMultiplyer: CGFloat = 1.0
    }
    
    // MARK: - private
    
    private func _addContentViews() {
        contentView.frame = _contentViewFrame
        cropBorderView.frame = _cropBorderViewFrame
        self.addSubview(contentView)
        self.addSubview(cropBorderView)
    }

    private func _calcuateWhichBorderHandleIsTheAnchorPointFromHere(anchorPoint: CGPoint) -> CGPoint {
        let allHandles: [CGPoint] = _getAllCurrentHandlePositions()
    
        var closest = 3000.0
        var theRealAnchor: CGPoint? = nil
        for handle in allHandles {
            let xDist = handle.x - anchorPoint.x
            let yDist = handle.y - anchorPoint.y
            let distance = sqrt(Double((xDist * xDist) + (yDist * yDist)))
            closest = distance < closest ? distance : closest;
            theRealAnchor = closest == distance ? handle : theRealAnchor;
        }
        return theRealAnchor!
    }

    private func _getAllCurrentHandlePositions() -> [CGPoint] {
    
        var a: [CGPoint] = []

        //again starting with the upper left corner and then following the rect clockwise
        a.append( CGPoint.zero )
        a.append( CGPoint.init(x: cropBorderView.bounds.size.width / 2,
                               y: 0.0 ) )
        a.append( CGPoint.init(x: cropBorderView.bounds.size.width,
                               y: 0.0 ) )
        a.append( CGPoint.init(x: cropBorderView.bounds.size.width,
                               y: cropBorderView.bounds.size.height / 2 ))
        a.append( CGPoint.init(x: cropBorderView.bounds.size.width,
                               y: cropBorderView.bounds.size.height ) )
        a.append( CGPoint.init(x: cropBorderView.bounds.size.width / 2,
                               y: cropBorderView.bounds.size.height ) )
        a.append( CGPoint.init(x: 0.0,
                               y: cropBorderView.bounds.size.height ) )
        a.append( CGPoint.init(x: 0.0,
                               y: cropBorderView.bounds.size.height / 2 ) )
    
        return a
    }

    private func _resizeWithTouchPoint(point: CGPoint) {

        //prevent going offscreen...
        let border = kBorderCorrectionValue * 2
        
        var newPoint = point
        newPoint.x = point.x < border ? border : point.x;
        newPoint.y = point.y < border ? border : point.y;
        newPoint.x = point.x > self.superview!.bounds.size.width - border ? self.superview!.bounds.size.width - border : point.x;
        newPoint.y = point.y > self.superview!.bounds.size.height - border ? self.superview!.bounds.size.height - border : point.y;
    
        let heightChange = (newPoint.y - _startPoint.y) * _resizeMultiplyer.heightMultiplyer
        let widthChange = (_startPoint.x - newPoint.x) * _resizeMultiplyer.widthMultiplyer
        let xChange = -1 * widthChange * _resizeMultiplyer.xMultiplyer
        let yChange = -1 * heightChange * _resizeMultiplyer.yMultiplyer
    
        var newFrame = CGRect.init(x: cropBorderView.frame.origin.x + xChange,
                                   y: cropBorderView.frame.origin.y + yChange,
                                   width: cropBorderView.frame.size.width + widthChange,
                                   height: cropBorderView.frame.size.height + heightChange)
    
        newFrame = _preventBorderFrameFromGettingTooSmallOrTooBig(newFrame: newFrame)
        _resetFramesToThisOne(frame: newFrame)
        _startPoint = point;
}

    private func _preventBorderFrameFromGettingTooSmallOrTooBig(newFrame: CGRect) -> CGRect {
        
        var adaptedFrame = newFrame
    
        
        if (adaptedFrame.size.width < 64) {
            adaptedFrame.size.width = cropBorderView.frame.size.width
            adaptedFrame.origin.x = cropBorderView.frame.origin.x
        }
        
        if (adaptedFrame.size.height < 64) {
            adaptedFrame.size.height = cropBorderView.frame.size.height
            adaptedFrame.origin.y = cropBorderView.frame.origin.y
        }
    
        if (adaptedFrame.origin.x < 0){
            adaptedFrame.size.width = cropBorderView.frame.size.width + (cropBorderView.frame.origin.x - self.superview!.bounds.origin.x)
            adaptedFrame.origin.x = 0
        }
    
        if (adaptedFrame.origin.y < 0){
            adaptedFrame.size.height = cropBorderView.frame.size.height + (cropBorderView.frame.origin.y - self.superview!.bounds.origin.y)
            adaptedFrame.origin.y = 0
        }
    
        if (adaptedFrame.size.width + adaptedFrame.origin.x > self.frame.size.width) {
            adaptedFrame.size.width = self.frame.size.width - cropBorderView.frame.origin.x
        }
    
        if (adaptedFrame.size.height + adaptedFrame.origin.y > self.frame.size.height - toolbarSize) {
            adaptedFrame.size.height = self.frame.size.height  - cropBorderView.frame.origin.y - toolbarSize
        }
        
        return newFrame
    }

    private func _resetFramesToThisOne(frame: CGRect) {
        cropBorderView.frame = frame
        contentView.frame = frame.insetBy(dx: kBorderCorrectionValue, dy: kBorderCorrectionValue)
        cropSize = self.contentView.frame.size
        setNeedsDisplay()
        cropBorderView.setNeedsDisplay()
    }

    private func _fillMultiplyer() {
        _resizeMultiplyer.heightMultiplyer =  (_theAnchor.y == 0 ? -1 : (_theAnchor.y == cropBorderView.bounds.size.height) ? 1 : 0);
            //-1 up, 0 middle, 1 down
        _resizeMultiplyer.widthMultiplyer = (_theAnchor.x == 0 ? 1 : (_theAnchor.x == cropBorderView.bounds.size.width) ? -1 : 0);
            // 1 left, 0 middle, 0 right
        _resizeMultiplyer.xMultiplyer = (_theAnchor.x == 0 ? 1 : 0);
            // 1 up, 0 middle, 0 down
        _resizeMultiplyer.yMultiplyer = (_theAnchor.y == 0 ? 1 : 0);
    }

//  MARK: - drawing

    override func draw(_ rect: CGRect) {
        UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).set()
        UIRectFill(self.bounds);
    
        UIColor.clear.set()
        UIRectFill(self.contentView.frame);
    }
    
}
