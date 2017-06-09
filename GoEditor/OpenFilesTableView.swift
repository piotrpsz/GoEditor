//
//  OpenFilesTableView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesTableView: NSTableView {
	private let customRowHeight = CGFloat(25.0)
	private var rowWhenSelectedSubmenu: Int?
	private let column: NSTableColumn = {
		let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("data"))
		col.isEditable = false
		return col
	}()
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		autoresizesSubviews = true
		autoresizingMask = [.width, .height]
		backgroundColor = NSColor(calibratedWhite: 0.5, alpha: 0.0)
		allowsColumnResizing = false
		allowsColumnReordering = false
		allowsMultipleSelection = false
		allowsEmptySelection = false
		allowsColumnSelection = false
		floatsGroupRows = false
		headerView = nil
		rowHeight = customRowHeight
		selectionHighlightStyle = .none
		addTableColumn(column)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
