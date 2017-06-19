//
//  TableView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 17/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

protocol TableViewDelegate: class {
	func menuAt(rowIndex: Int?) -> NSMenu?
}

class TableView: NSTableView {
	var rowForContextMenu: Int?
	var onReload = false
	weak var tableViewDelegate: TableViewDelegate?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		autoresizesSubviews = true
		autoresizingMask = [.width, .height]
		backgroundColor = NSColor(calibratedWhite: 0.5, alpha: 0.0)
		rowHeight = 25.0
		allowsColumnResizing = false
		allowsColumnReordering = false
		allowsMultipleSelection = false
		allowsEmptySelection = false
		allowsColumnSelection = false
		floatsGroupRows = false
		headerView = nil
		selectionHighlightStyle = .none
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func reloadData() {
		let index = selectedRow
		onReload = true
		super.reloadData()
		selectRow(at: index)
		onReload = false
	}
	
	func selectRow(at index: Int?) {
		guard let index = index else {
			return
		}
		selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
		scrollRowToVisible(index)
	}
	
	override func rightMouseDown(with event: NSEvent) {
		guard !onReload else {
			return
		}
		let point = convert(event.locationInWindow, to: nil)
		let rowIndex = indexOfRowContainedPoint(point: point)
		if let menu = tableViewDelegate?.menuAt(rowIndex: rowIndex) {
			NSMenu.popUpContextMenu(menu, with: event, for: self)
		}
	}
	
	func indexOfRowContainedPoint(point: NSPoint) -> Int? {
		var index: Int?
		
		enumerateAvailableRowViews { (rowView, rowIndex) in
			if NSPointInRect(point, rowView.frame) {
				index = rowIndex
				return
			}
		}
		return index
	}
}
