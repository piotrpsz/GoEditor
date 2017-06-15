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
	var onReload = false
	
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
		floatsGroupRows = true
		headerView = nil
		rowHeight = customRowHeight
		selectionHighlightStyle = .none
		addTableColumn(column)
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
	
	override func rightMouseDown(with event: NSEvent) {
		guard !onReload else {
			return
		}
		tr.in(self); defer { tr.out(self)}
		
		let point = convert(event.locationInWindow, to: nil)
		if let rowIndex = indexOfRowContainedPoint(point: point) {
			if let editor = EditorsContainer.editors[rowIndex].editor {
				tr.info(self, "index: \(rowIndex), path: \(editor.filePath)")
				let menu = NSMenu()
				if editor.isChanged {
					menu.addItem(withTitle: "Save", action: #selector(saveDidSelectInContextMenu(_:)), keyEquivalent: "")
				}
				menu.addItem(withTitle: "Close", action: #selector(closeDidSelectInContextMenu(_:)), keyEquivalent: "")
				menu.addItem(withTitle: "Rename", action: #selector(renameDidSelectInContextMenu(_:)), keyEquivalent: "")
				menu.addItem(withTitle: "Delete", action: #selector(deleteDidSelectInContextMenu(_:)), keyEquivalent: "")
				NSMenu.popUpContextMenu(menu, with: event, for: self)
			}
		}
	}
	
	@objc func saveDidSelectInContextMenu(_ sender: Any?) {
		
	}
	
	@objc func closeDidSelectInContextMenu(_ sender: Any?) {
		
	}
	
	@objc func renameDidSelectInContextMenu(_ sender: Any?) {
		
	}
	
	@objc func deleteDidSelectInContextMenu(_ sender: Any?) {
		
	}
	
	private func indexOfRowContainedPoint(point: CGPoint) -> Int? {
		var index: Int? = nil
		enumerateAvailableRowViews { (rowView, rowIndex) in
			let yt = rowView.frame.origin.y
			let yb = yt + rowView.frame.size.height
			if (yb >= point.y) && (point.y >= yt) {
				index = rowIndex
				return
			}
		}
		return index
	}
	
	
	func selectRow(at index: Int?) {
		guard let index = index else {
			return
		}
		self.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
		self.scrollRowToVisible(index)
	}
	
	
}
