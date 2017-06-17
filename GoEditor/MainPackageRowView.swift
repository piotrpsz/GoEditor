//
//  MainPackageRowView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 17/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class MainPackageRowView: NSTableRowView {
	let selectedStrokeColor = NSColor(calibratedWhite: 0.65, alpha: 0.5)
	let selectedFillColor = NSColor(calibratedWhite: 0.65, alpha: 0.0)
	let strokeColor = NSColor(calibratedWhite: 0.65, alpha: 0.0)
	let fillColor = NSColor(calibratedWhite: 0.65, alpha: 0.0)
	
	override var isSelected: Bool {
		willSet(newValue) {
			super.isSelected = newValue
			needsDisplay = true
		}
	}
	
	override func drawBackground(in dirtyRect: NSRect) {
		let rect = NSInsetRect(bounds, 2.5, 2.5)
		
		if isSelected {
			selectedStrokeColor.setStroke()
			selectedFillColor.setFill()
		} else {
			strokeColor.setStroke()
			fillColor.setFill()
		}
		
		let bezierPath = NSBezierPath(roundedRect: rect, xRadius: 6.0, yRadius: 6.0)
		bezierPath.fill()
		bezierPath.stroke()
	}
}
