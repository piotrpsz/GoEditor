//
//  MainPackageCellView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 17/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class MainPackageCellView: NSTableCellView {
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
		if let fpath = objectValue as? String {
			let url = URL(fileURLWithPath: fpath)
			let attrString = NSAttributedString(string: url.lastPathComponent, attributes: nameAttr)
			let x = margin
			let y = bounds.origin.y + (bounds.size.height - attrString.size().height) / 2.0
			attrString.draw(at: CGPoint(x: x, y: y))
			
			var changed: Bool? = nil
			EditorsContainer.mutex.sync {
				for editor in EditorsContainer.editors {
					if editor.editor.filePath == fpath {
						changed = editor.editor.isChanged
					}
				}
			}
			
			if let changed = changed {
				let xc = bounds.size.width - 5.0 - MainPackageCellView.radius
				let yc = (bounds.size.height - (2.0 * MainPackageCellView.radius)) / 2.0
				let color = changed ? MainPackageCellView.changedColor : MainPackageCellView.normalColor
				color.setFill()
				NSBezierPath(ovalIn: CGRect(x: xc - MainPackageCellView.radius, y: bounds.origin.y + yc, width: 2.0 * MainPackageCellView.radius, height: 2.0 * MainPackageCellView.radius)).fill()
			}
		}
	}
}
