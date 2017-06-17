//
//  MainPackageView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class MainPackageView: NSView {
	private let backgroundColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)
	private let scrollView: NSScrollView = {
		let sv = NSScrollView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
		sv.hasHorizontalScroller = true
		sv.hasVerticalScroller = true
		sv.autoresizingMask = [.width, .height]
		sv.autoresizesSubviews = true
		sv.drawsBackground = false
		sv.focusRingType = .none
		return sv
	}()
	private let tableView = MainPackageTableView(frame: NSRect.zero)
	
	
	override var isFlipped: Bool {
		return true
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		autoresizingMask = [.width, .height]
		autoresizesSubviews = true
		scrollView.documentView = tableView
		addSubview(scrollView)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func draw(_ dirtyRect: NSRect) {
		backgroundColor.setFill()
		bounds.fill()
    }
}
