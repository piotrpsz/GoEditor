//
//  FirmyTableCell.swift
//  Kadry
//
//  Created by Piotr Pszczolkowski on 16/09/16.
//  Copyright © 2016 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesTableCell: NSTableCellView {
	let margin     = CGFloat(10.0)
	let nameAttr: [String:Any] = {
		let font = NSFont.boldSystemFont(ofSize: 14.0)
		let color = NSColor.black
		return [NSFontAttributeName:font, NSForegroundColorAttributeName:color]
	}()
	let shortcutAttr: [String:Any] = {
		let font = NSFont.boldSystemFont(ofSize: 9.0)
		let color = NSColor.black
		return [NSFontAttributeName:font, NSForegroundColorAttributeName:color]
	}()
	let cityAttr: [String:Any] = {
		let font = NSFont.boldSystemFont(ofSize: 10.0)
		let color = NSColor.black
		return [NSFontAttributeName:font, NSForegroundColorAttributeName:color]
	}()
	let completeNameAttr: [String:Any] = {
		let font = NSFont.systemFont(ofSize: 11.0)
		let color = NSColor(calibratedWhite: 0.15, alpha: 1.0)
		return [NSFontAttributeName:font, NSForegroundColorAttributeName:color]
	}()
	let nipAttr: [String:Any] = {
		let font = NSFont.systemFont(ofSize: 10.0)
		let color = NSColor.black
		return [NSFontAttributeName:font, NSForegroundColorAttributeName:color]
	}()
	
	override var isFlipped: Bool {
		get {
			return true
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if let company = objectValue as? Company {
			
			let nameAttrString = NSAttributedString(string: company.name, attributes: nameAttr)
			nameAttrString.draw(at: NSMakePoint(margin, margin))
			
			let shortcutAttrString = NSAttributedString(string: "\(company.shortcut!)", attributes: shortcutAttr)
			let y = margin + (nameAttrString.size().height - shortcutAttrString.size().height) - 1.0
			shortcutAttrString.draw(at: NSMakePoint(margin + nameAttrString.size().width + margin, y))
			
			if let cityName = company.cityName {
				let cityAttrString = NSAttributedString(string: cityName, attributes: cityAttr)
				cityAttrString.draw(at: NSMakePoint(frame.size.width - margin - cityAttrString.size().width, margin))
			}
			
			if let completeName = company.completeName {
				let completeNameAttrString = NSAttributedString(string: completeName, attributes: completeNameAttr)
				completeNameAttrString.draw(at: NSMakePoint(margin, frame.size.height - margin - completeNameAttrString.size().height))
			}

			if let nip = company.nip {
				let nipAttrString = NSAttributedString(string: "NIP: \(nip)", attributes: nipAttr)
				nipAttrString.draw(at: NSMakePoint(frame.size.width - margin - nipAttrString.size().width, frame.size.height - margin - nipAttrString.size().height))
			}
		}
	}
}
