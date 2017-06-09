//
//  EditorSplitView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class EditorSplitView: NSSplitView, EventObserver {
    private let consoleView = ConsoleView(frame: CGRect.zero)
    private let defaultDividerThickness = CGFloat(2.0)
    private let consoleScrollViewInitialHeight = CGFloat(200.0)
    private var editors: [TextEditor] = []
    private var currentEditorIndex = 0
    
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
    
    private let editorScrollView: NSScrollView = {
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
		
		let editor = TextEditor(frame: editorViewRect)
//        editorScrollView.frame = editorScrollViewRect
        consoleScrollView.frame = consoleScrollViewRect
        
        super.init(frame: frameRect)
        
        
//        editorScrollView.documentView = editors[0]
//        editors[0].lnv_setUpLineNumberView()
        consoleScrollView.documentView = consoleView
		
        
        subviews = [editor, consoleScrollView]
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
            let (editorScrollViewRect, consoleScrollViewRect) = self.rects()
            self.editorScrollView.frame = editorScrollViewRect
            self.consoleScrollView.frame = consoleScrollViewRect
        }
        
        registerEvent(Event.filesToOpenDidSelect) { note in
//            if let files = note.userInfo?["files"] as? [String] {
//                for fpath in files {
//                    let editor = EditorView(frame: self.editorScrollView.frame, filePath: fpath)
//                    self.editorScrollView.documentView = editor
//                    editor.lnv_setUpLineNumberView()
//                    self.editors.append(editor)
//                }
//            }
        }
        registerEvent(Event.saveRequest) { note in
//            self.editors.forEach {
//                $0.save()
//            }
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


