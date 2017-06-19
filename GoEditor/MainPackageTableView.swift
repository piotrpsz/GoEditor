//
//  MainPackageTableView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 16/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class MainPackageTableView: TableView, TableViewDelegate, EventObserver {
	private let column: NSTableColumn = {
		let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("data"))
		col.isEditable = false
		return col
	}()
	private var files: [String] = []
	var observers: [NSObjectProtocol] = []
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		addTableColumn(column)
		delegate = self
		dataSource = self
		tableViewDelegate = self
		doubleAction = #selector(doubleDidClick(_:))
		registerObservers()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		removeObservers()
	}
	
	@objc func doubleDidClick(_ sender: Any?) {
		let indexRow = selectedRow
		guard indexRow > -1 else {
			return
		}
		Event.filesToOpenRequest.dispatch(["files":[files[indexRow]] as AnyObject])
	}
	
	func registerObservers() {
		registerEvent(Event.editorsContainerContentDidChange) { note in
			self.reloadData()
		}
		
		registerEvent(Event.editorStateDidChange) { note in
			self.reloadData()
		}
		
		registerEvent(Event.mainPackageDirectoryDidChange) { note in
			self.files = []
			if let fpath = Shared.mainPackageDirectory {
				do {
					let array = try FileManager.default.contentsOfDirectory(atPath: fpath)
					for item in array where item.hasSuffix(".go") {
						let path = fpath + "/" + item
						self.files.append(path)
					}
				}
				catch let error as NSError {
					tr.info(self, "\(error.localizedDescription)")
				}
			}
			self.reloadData()
		}
	}
		
	func menuAt(rowIndex: Int) -> NSMenu? {
		return nil
	}
	
}

//####################################################################
//#                                                                  #
//#               T A B L E   V I E W   D E L E G A T E              #
//#                                                                  #
//####################################################################
// MARK: - Table View Delegate

extension MainPackageTableView: NSTableViewDelegate {
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainPackageRowView"), owner: nil) as? MainPackageRowView
		if rowView == nil {
			rowView = MainPackageRowView()
			rowView?.identifier = NSUserInterfaceItemIdentifier("MainPackageRowView")
		}
		return rowView
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainPackageCellView"), owner: nil) as? MainPackageCellView
		if cellView == nil {
			cellView = MainPackageCellView()
			cellView?.identifier = NSUserInterfaceItemIdentifier("MainPackageCellView")
		}
		return cellView
	}
}

//####################################################################
//#                                                                  #
//#               T A B L E   V I E W   D E L E G A T E              #
//#                                                                  #
//####################################################################
// MARK: - Data Source Delegate

extension MainPackageTableView: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		guard files.isNotEmpty else {
			return 1
		}
		return files.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		guard let _ = Shared.mainPackageDirectory else {
			return "Unknown main package directory"
		}
		guard files.isNotEmpty else {
			return "No files in main package"
		}
		
		guard (row >= 0) && (row < files.count) else {
			return nil
		}
		return files[row]
	}
}
