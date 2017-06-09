//
//  ProjectView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

enum ProjectViewIndex: Int {
	case mainPackageView = 0, openFilesView
}

class ProjectView: NSView {
	private let topSelectorMargin = CGFloat(10.0)
    private let backgroundColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)
	private let mainPackageView = MainPackageView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
	private let openFilesView = OpenFilesView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
	private let selector: NSSegmentedControl =  {
		let sc = NSSegmentedControl()
		sc.font = NSFont.systemFont(ofSize: 10.0)
		sc.segmentCount = 2
		sc.setLabel("Main package", forSegment: 0)
		sc.setLabel("Opened files", forSegment: 1)
		sc.segmentStyle = .texturedSquare
		sc.controlSize = .small
		var rect = NSRect.zero
		rect.size = sc.fittingSize
		sc.frame = rect
		return sc
	}()
	
	override var isFlipped: Bool {
		return true
	}
	
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
		autoresizingMask = [.width, .height]
		autoresizesSubviews = true
		
		addSubview(selector)
		addSubview(mainPackageView)
		addSubview(openFilesView)
		mainPackageView.isHidden = false
		openFilesView.isHidden = true
		selector.target = self
		selector.action = #selector(ProjectView.selectorDidSelect(_:))
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func resizeSubviews(withOldSize oldSize: NSSize) {
		var rect = selector.frame
		rect.origin.x = (frame.size.width - rect.size.width) / 2.0
		rect.origin.y = topSelectorMargin
		selector.frame = rect
		
		rect = bounds
		rect.origin.y = topSelectorMargin + selector.frame.size.height + topSelectorMargin
		rect.size.height -= rect.origin.y
		mainPackageView.frame = rect
		openFilesView.frame = rect
	}
	
	@objc func selectorDidSelect(_ sender: Any) {
		guard let viewIndex = ProjectViewIndex(rawValue: selector.selectedSegment) else {
			return
		}
		changeView(to: viewIndex)
	}
	
	private func changeView(to viewIndex: ProjectViewIndex) {
		switch viewIndex {
		case .mainPackageView:
			mainPackageView.isHidden = false
			openFilesView.isHidden = true
		case .openFilesView:
			mainPackageView.isHidden = true
			openFilesView.isHidden = false
		}
	}
	
    override func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
        bounds.fill()
    }
}
