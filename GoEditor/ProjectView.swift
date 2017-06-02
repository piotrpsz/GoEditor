//
//  ProjectView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class ProjectView: NSView {
	private let backgroundColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
    override func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
		NSRectFill(bounds)
    }
    
}
