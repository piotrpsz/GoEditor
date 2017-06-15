//
//  OpenFilesCellView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesCellView: NSTableCellView {
	static private let radius = CGFloat(6.0)
	static private let changedColor = NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
	static private let normalColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
	
	let margin = CGFloat(10.0)
	let nameAttr: [NSAttributedStringKey:Any] = {
		let font = NSFont.systemFont(ofSize: 11.0)
		let color = NSColor.white
		return [NSAttributedStringKey.font:font, NSAttributedStringKey.foregroundColor:color]
	}()
		
	override var isFlipped: Bool {
		return true
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if let editor = objectValue as? TextEditor {
			let url = URL(fileURLWithPath: editor.editor.filePath)
			let attrString = NSAttributedString(string: url.lastPathComponent, attributes: nameAttr)
			let x = margin
			let y = bounds.origin.y + (bounds.size.height - attrString.size().height) / 2.0
			attrString.draw(at: CGPoint(x: x, y: y))
			
			let xc = bounds.size.width - 5.0 - OpenFilesCellView.radius
			let yc = (bounds.size.height - (2.0 * OpenFilesCellView.radius)) / 2.0
			
			let color = editor.editor.isChanged ? OpenFilesCellView.changedColor : OpenFilesCellView.normalColor
			color.setFill()
			NSBezierPath(ovalIn: CGRect(x: xc - OpenFilesCellView.radius, y: bounds.origin.y + yc, width: 2.0 * OpenFilesCellView.radius, height: 2.0 * OpenFilesCellView.radius)).fill()
		}
	}
}
