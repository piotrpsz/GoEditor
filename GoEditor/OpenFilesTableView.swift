//
//  OpenFilesTableView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesTableView: TableView {
	private let column: NSTableColumn = {
		let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("data"))
		col.isEditable = false
		return col
	}()
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		addTableColumn(column)
		delegate = self
		dataSource = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension OpenFilesTableView: NSTableViewDelegate {
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		if !onReload {
			var editor: TextEditor?
			EditorsContainer.mutex.sync {
				editor = EditorsContainer.editors[self.selectedRow]
			}
			Event.userDidSelectEditor.dispatch(["editor":editor as Any])
		}
	}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("OpenFilesRowView"), owner: nil) as? OpenFilesRowView
		if rowView == nil {
			rowView = OpenFilesRowView()
			rowView?.identifier = NSUserInterfaceItemIdentifier("OpenFilesRowView")
		}
		return rowView
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("OpenFilesCellView"), owner: nil) as? OpenFilesCellView
		if cellView == nil {
			cellView = OpenFilesCellView()
			cellView?.identifier = NSUserInterfaceItemIdentifier("OpenFilesCellView")
		}
		cellView?.objectValue = EditorsContainer.editors[row]
		return cellView
	}
}



extension OpenFilesTableView: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		let n = EditorsContainer.editors.count
		return n
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		guard (row >= 0) && (row < EditorsContainer.editors.count) else {
			return nil
		}
		return EditorsContainer.editors[row]
	}
}
