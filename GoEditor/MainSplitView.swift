//
//  MainSplitView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class MainSplitView: NSSplitView, EventObserver {
	fileprivate let projectView: ProjectView
	fileprivate let editorSplitView: EditorSplitView
	fileprivate let projectViewInitialWidth = CGFloat(210.0)
	fileprivate let defaultDividerThickness = CGFloat(2.0)
	
	var observers: [NSObjectProtocol] = []
	
	override var isFlipped: Bool {
		return true
	}
	
	override var dividerThickness: CGFloat {
		return defaultDividerThickness
	}
	override var dividerColor: NSColor {
		return NSColor.darkGray
	}

	override init(frame frameRect: NSRect) {
		let projectViewRect = CGRect(x: frameRect.origin.x,
		                             y: frameRect.origin.y,
		                             width: projectViewInitialWidth,
		                             height: frameRect.size.height)
		
		let editorSplitViewRect = CGRect(x: projectViewRect.size.width + defaultDividerThickness,
		                                 y: frameRect.origin.y,
		                                 width: frameRect.size.width - defaultDividerThickness - projectViewInitialWidth,
		                                 height: frameRect.size.height)

		projectView = ProjectView(frame: projectViewRect)
		editorSplitView = EditorSplitView(frame: editorSplitViewRect)
		
		super.init(frame: frameRect)
		
		subviews = [projectView, editorSplitView]
		dividerStyle = .thick
		isVertical = true
		arrangesAllSubviews = true
		delegate = self
		
		registerObservers()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		removeObservers()
	}
	
	func registerObservers() {
		registerEvent(Event.applicationStarted) { note in
			let (projectViewRect, editorSplitViewRect) = self.rects()
			self.projectView.frame = projectViewRect
			self.editorSplitView.frame = editorSplitViewRect
		}
	}
	
	private func rects() -> (CGRect, CGRect) {
		let rect = bounds
		
		let projectViewRect = CGRect(x: bounds.origin.x,
		                             y: bounds.origin.y,
		                             width: projectViewInitialWidth,
		                             height: rect.size.height)
		
		let editorSplitViewRect = CGRect(x: projectViewRect.size.width + dividerThickness,
		                                 y: bounds.origin.y,
		                                 width: rect.size.width - dividerThickness - projectViewInitialWidth,
		                                 height: bounds.size.height)
		
		return (projectViewRect, editorSplitViewRect)
	}
}

extension MainSplitView: NSSplitViewDelegate {
	
}
