//
//  ColorPicker.swift
//  Median
//
//  Created by Vojtech Rinik on 22/03/2017.
//  Copyright © 2017 Vojtech Rinik. All rights reserved.
//

import Foundation
import NiceKit

public class ColorPicker: NSView {
    
    let pickerController: ColorPickerViewController = {
        let bundle = Bundle(identifier: "tech.median.NiceUI")
        return ColorPickerViewController(nibName: "ColorPickerViewController", bundle: bundle)!
    }()
    
    var popover: NSPopover?
    
    public var colors = [NSColor]() {
        didSet {
            pickerController.colors = colors
        }
    }
    
    public var selectedColor: NSColor? { didSet {
        updateColorLayer()
        updatePopover()
    } }
    var isPressed = false { didSet { updateColorLayer() } }
    public var isDisabled = false { didSet { updateColorLayer() } }
    public var wantsAuto = true
    
    var colorLayer: CALayer?
    
    public var onChange: ((NSColor?) -> ())?
    
    public override func awakeFromNib() {
        pickerController.onSelect = handleSelectColor
    }
    
    public override func viewDidMoveToWindow() {
        createLayers()
    }
    
    public override func viewDidChangeBackingProperties() {
        createLayers()
    }
    
    
    var hairline: CGFloat {
        if let window = self.window {
            let backing = window.backingScaleFactor
            return CGFloat(backing > 1.0 ? 0.5 : 1.0)
        } else {
            return 1.0
        }
    }
    
    lazy var border1: NSColor = {
        return NSColor(hexString: "B5B6B8")!
    }()
    
    lazy var border2: NSColor = {
        return NSColor(hexString: "D3D4D7")!
    }()
    
    func createLayers() {
        if window == nil {
            return
        }
        
        let layer = CAGradientLayer()
        
        self.layer = layer
        self.wantsLayer = true
        
        layer.cornerRadius = 3.0
        layer.colors = [border1.cgColor, border2.cgColor]
        layer.shadowColor = NSColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -0.5)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 0
        
        
        let layer2 = CALayer()
        layer2.cornerRadius = 3.0 - hairline
        layer2.backgroundColor = NSColor.white.cgColor
        layer2.frame = bounds.insetBy(dx: hairline, dy: hairline)
        layer.addSublayer(layer2)
        
        let layer3 = CALayer()
        layer3.frame = bounds.insetBy(dx: 3.0, dy: 3.0)
        layer3.cornerRadius = 1
        layer3.actions = [
            "backgroundColor": NSNull()
        ]
        
        layer.addSublayer(layer3)
        
        self.colorLayer = layer3
        
        updateColorLayer()
    }
    
    func updateColorLayer() {
        guard let layer = colorLayer else { return }
        
        if isDisabled {
            layer.backgroundColor = border1.cgColor
            layer.borderColor = border2.cgColor
            self.alpha = 0.5
            
            return
        }
        
        self.alpha = 1
        
        
        if let color = selectedColor {
            if isPressed {
                let pressedColor = color.addHue(0, saturation: 0, brightness: -0.1, alpha: 0)
                layer.backgroundColor = pressedColor.cgColor
                
            } else {
                layer.backgroundColor = color.cgColor
            }
            
            let borderColor = color.addHue(0, saturation: 0, brightness: -0.15, alpha: 0)
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = hairline
        } else {
            if isPressed {
                layer.backgroundColor = NSColor(hexString: "EEEEEE")!.cgColor
            } else {
                layer.backgroundColor = NSColor.white.cgColor
            }
            
            layer.borderColor = border2.cgColor
            
            layer.borderWidth = hairline
        }
    }
    
    func updatePopover() {
        pickerController.updateUI(withColor: selectedColor)
    }
    
 
    public override func mouseDown(with event: NSEvent) {
        if isDisabled {
            return
        }
        
        isPressed = true
        
        
    }
    
    public override func mouseUp(with event: NSEvent) {
        if isDisabled {
            return
        }
        
        isPressed = false
        
        showPopover()
    }
    
    func showPopover() {
        if self.popover == nil {
            let popover = NSPopover()
            popover.contentViewController = pickerController
            popover.contentSize = NSSize(width: 170, height: 76)
            popover.animates = false
            popover.behavior = .transient
            
            self.popover = popover
        }
        
        popover?.show(relativeTo: bounds, of: self, preferredEdge: .minY)
    }
    
    func handleSelectColor(_ color: NSColor?) {
        selectedColor = color
        onChange?(color)
        popover?.close()
    }
}

