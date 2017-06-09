//
//  MainPackageView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class MainPackageView: NSView {
	private let backgroundColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		autoresizingMask = [.width, .height]
		autoresizesSubviews = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func draw(_ dirtyRect: NSRect) {
		backgroundColor.setFill()
		bounds.fill()
    }
}
