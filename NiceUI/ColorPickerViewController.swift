//
//  ColorPickerViewController.swift
//  Median
//
//  Created by Vojtech Rinik on 22/03/2017.
//  Copyright © 2017 Vojtech Rinik. All rights reserved.
//

import Cocoa
import Cartography
import NiceKit
import Hue

class ColorPickerViewController: NSViewController {
    
    
    @IBOutlet weak var stackRows: NSStackView!
    
    var colorViews = [ColorView]()
    
    var colors = [NSColor]()
    
    @IBOutlet weak var autoButton: NSButton?
    
    var onSelect: ((NSColor?) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let rows = 2
        let columns = 4
        
        var rowViews = [NSView]()
        
        var i = 0
        
        for _ in 0...(rows - 1) {
            var cellViews = [NSView]()
            
            for _ in 0...(columns - 1) {
                let view = ColorView()
                
                if let color = colors.at(i) {
                    view.color = color
                }
                
                view.onSelect = self.handleSelect
                view.onConfirm = self.handleConfirm
                
                cellViews.append(view)
                colorViews.append(view)
                
                
                i += 1
            }
            
            let rowStack = NSStackView()
            rowStack.spacing = 2.0
            rowStack.orientation = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.setViews(cellViews, in: .leading)
            
            rowViews.append(rowStack)
            
        }
        
        stackRows.setViews(rowViews, in: .top)
    }
    
    func handleSelect(_ view: ColorView) {
        updateUI(withColor: view.color)
    }
    
    func handleConfirm(_ view: ColorView) {
        guard let color = view.color else { return }
        
        onSelect?(color)
    }
    
    @IBAction func selectAuto(_ sender: Any) {
        updateUI(withColor: nil)
        
        onSelect?(nil)
    }
    
    func updateUI(withColor color: NSColor?) {
        for view in colorViews {
            view.isSelected = false
        }
        
        
        if let color = color {
            autoButton?.image = nil
            
            if let index = colors.index(where: { $0 == color }),
                let colorView = colorViews.at(index) {
                colorView.isSelected = true
            }
            
        } else {
            autoButton?.image = #imageLiteral(resourceName: "CheckSmall")
        }
    }
}

class ColorView: NSView {
    var color: NSColor? {
        didSet {
            update()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            update()
        }
    }
    
    var onSelect: ((ColorView) -> ())?
    var onConfirm: ((ColorView) -> ())?
    
    var checkImageView: NSImageView!

    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layer = CALayer()
        self.wantsLayer = true
        
        let checkImage = #imageLiteral(resourceName: "CheckSmall").tintedImageWithColor(color: NSColor.white)
        checkImageView = NSImageView()
        checkImageView.image = checkImage
        
        addSubview(checkImageView)
        constrain(checkImageView) { view in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY + 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        let layer = self.layer!
        
        guard let color = self.color else { return }
        
        
        layer.backgroundColor = color.cgColor
        layer.borderWidth = 1.0
        layer.borderColor = color.addHue(0, saturation: 0, brightness: -0.1, alpha: 0).cgColor
        layer.cornerRadius = 1.0
        
        checkImageView.isHidden = !isSelected
        
    }
    
    override func mouseDown(with event: NSEvent) {
        onSelect?(self)
    }
    
    override func mouseUp(with event: NSEvent) {
        onConfirm?(self)
    }
    
    
    
    /*
    override func draw(_ dirtyRect: NSRect) {
        color.set()
        NSRectFill(bounds)
    }
     */
}
