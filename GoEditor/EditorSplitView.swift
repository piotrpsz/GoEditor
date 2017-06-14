//
//  EditorSplitView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class EditorSplitView: NSSplitView, EventObserver {
    private let consoleView = ConsoleView(frame: CGRect.zero)
    private let defaultDividerThickness = CGFloat(2.0)
    private let consoleScrollViewInitialHeight = CGFloat(200.0)
	private let editorsContainer = EditorsContainer()
	
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
	
    private let consoleScrollView: NSScrollView = {
        let sv = NSScrollView(frame: CGRect.zero)
        sv.hasVerticalScroller = true
        sv.hasHorizontalScroller = true
        sv.scrollerStyle = .overlay
        sv.borderType = .noBorder
        sv.autohidesScrollers = false
        sv.autoresizingMask = [.width, .height]
        sv.autoresizesSubviews = true
        return sv
    }()

    
    override init(frame frameRect: NSRect) {
		
        let consoleScrollViewRect = CGRect(x: frameRect.origin.x,
                                           y: frameRect.height - consoleScrollViewInitialHeight,
                                           width: frameRect.width,
                                           height: consoleScrollViewInitialHeight)
        
        let editorViewRect = CGRect(x: frameRect.origin.x,
                                    y: frameRect.origin.y,
                                    width: frameRect.width,
                                    height: frameRect.height - defaultDividerThickness - consoleScrollViewRect.size.height)
		
		editorsContainer.frame = editorViewRect
		editorsContainer.newEditor()
		
        consoleScrollView.frame = consoleScrollViewRect
        super.init(frame: frameRect)
		
        consoleScrollView.documentView = consoleView
		
        
        subviews = [editorsContainer, consoleScrollView]
        dividerStyle = .thick
        arrangesAllSubviews = true
        
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
			(self.editorsContainer.frame, self.consoleScrollView.frame) = self.rects()
        }
    }
    
    private func rects() -> (CGRect, CGRect) {
        let rect = bounds
		
        let consoleScrollViewRect = CGRect(x: rect.origin.x,
                                           y: rect.height - consoleScrollViewInitialHeight,
                                           width: rect.width,
                                           height: consoleScrollViewInitialHeight)
		
        let editorScrollViewRect = CGRect(x: rect.origin.x,
                                          y: rect.origin.y,
                                          width: rect.width,
                                          height: rect.height - dividerThickness - consoleScrollViewRect.size.height)
		
        return (editorScrollViewRect, consoleScrollViewRect)
    }
	
}


