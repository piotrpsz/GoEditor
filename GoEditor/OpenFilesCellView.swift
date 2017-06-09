//
//  OpenFilesCellView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesCellView: NSTableCellView {
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
		if let fpath = objectValue as? String {
			let url = URL(fileURLWithPath: fpath)
			let attrString = NSAttributedString(string: url.lastPathComponent, attributes: nameAttr)
			let x = margin
			let y = bounds.origin.y + (bounds.size.height - attrString.size().height) / 2.0
			attrString.draw(at: CGPoint(x: x, y: y))
		}
	}
}
