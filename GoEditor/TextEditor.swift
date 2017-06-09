//
//  TextEditor.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class TextEditor: NSScrollView {
	var editor: EditorView!
	
	override var isFlipped: Bool {
		return true
	}
	
	required init(frame frameRect: CGRect, fpath: String? = nil) {
		super.init(frame: frameRect)
		hasVerticalScroller = true
		hasHorizontalScroller = true
		scrollerStyle = .overlay
		borderType = .noBorder
		autohidesScrollers = false
		autoresizingMask = [.width, .height]
		autoresizesSubviews = true
		
		editor = EditorView(frame: frameRect, filePath: fpath)
		documentView = editor
		editor.lnv_setUpLineNumberView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
