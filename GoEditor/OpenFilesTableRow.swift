//
//  FirmyTableRow.swift
//  Kadry
//
//  Created by Piotr Pszczolkowski on 16/09/16.
//  Copyright © 2016 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesTableRow: NSTableRowView {
	let selectedStrokeColor = NSColor(calibratedWhite: 0.65, alpha: 0.5)
	let selectedFillColor = NSColor(calibratedWhite: 1.0, alpha: 0.5)
	let strokeColor = NSColor(calibratedWhite: 0.65, alpha: 0.5)
	let fillColor = NSColor(calibratedWhite: 0.82, alpha: 0.0)
	
	override var isSelected: Bool {
		willSet(newValue) {
			super.isSelected = newValue;
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
		
		let bezierPath = NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6)
		bezierPath.fill()
		bezierPath.stroke()
	}
}
