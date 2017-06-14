//
//  OpenFilesView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesView: NSView, EventObserver {
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
	private let tableView = OpenFilesTableView(frame: CGRect.zero)
	var observers: [NSObjectProtocol] = []
	
	override var isFlipped: Bool {
		return true
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		autoresizingMask = [.width, .height]
		autoresizesSubviews = true
		tableView.delegate = self
		tableView.dataSource = self
		scrollView.documentView = tableView
		addSubview(scrollView)
		registerObservers()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		removeObservers()
	}
	
	func registerObservers() {
		registerEvent(Event.editorsContainerContentDidChange) { note in
			self.tableView.reloadData()
		}
		
		registerEvent(Event.currentEditor) { note in
			if let editor = note.userInfo?["editor"] as? TextEditor {
				var index: Int?
				EditorsContainer.mutex.sync {
					index = EditorsContainer.editors.index { $0 === editor }
				}
				self.tableView.selectRow(at: index)
			}
		}
	}
	
}

extension OpenFilesView: NSTableViewDelegate {
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		return true
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		guard tableView.onReload == false else {
			return
		}
		var editor: TextEditor?
		EditorsContainer.mutex.sync {
			editor = EditorsContainer.editors[self.tableView.selectedRow]
		}
		Event.userDidSelectEditor.dispatch(["editor":editor as Any])
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

extension OpenFilesView: NSTableViewDataSource {
	
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
