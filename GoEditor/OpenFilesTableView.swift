//
//  FirmyTableView.swift
//  Kadry
//
//  Created by Piotr Pszczolkowski on 15/09/16.
//  Copyright © 2016 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFielesTableView: NSTableView {
	let customRowHeight: CGFloat = 55.0
	var rowWhenSelectedSubmenu: Int?
	var observers: [NSObjectProtocol] = []
	
	let column: NSTableColumn = {
		let col = NSTableColumn(identifier: "data")
		col.isEditable = false
		return col
	}()
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		autoresizesSubviews = true
		autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
		backgroundColor = NSColor(calibratedWhite: 0.5, alpha: 0.0)
		allowsColumnReordering = false
		allowsColumnResizing = false
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

	///
	/// Wyznaczenie numeru wiersza, który zawiera wskazany punkt.
	///
	private func rowContainedPoint(point: NSPoint) -> Int {
		var response = -1
		
		enumerateAvailableRowViews { (rowView, rowIndex) in
			let yt = rowView.frame.origin.y
			let yb = rowView.frame.origin.y + rowView.frame.size.height - 1.0
			if (yb >= point.y) && (point.y >= yt) {
				response = rowIndex
				return
			}
		}
		return response
	}
	
	///
	/// Wciśnięto prawy klawisz myszy.
	/// Wyświetlenie kontekstowego submenu.
	///
	override func rightMouseDown(with event: NSEvent) {
		rowWhenSelectedSubmenu = nil
		let point = convert(event.locationInWindow, to: nil)
		let row = rowContainedPoint(point: point)
		selectRow(atIndex: row)
		
		let menu = NSMenu()
		if row != -1 {
			rowWhenSelectedSubmenu = row
			menu.insertItem(withTitle: "Usuń wybraną firmę", action: #selector(removeDidSelectInSubmenu), keyEquivalent: "", at: 0)
			menu.insertItem(withTitle: "Edytuj wybraną firmę", action: #selector(editDidSelectInSubmenu), keyEquivalent: "", at: 0)
		}
		menu.insertItem(withTitle: "Dodaj nową firmę", action: #selector(addDidSelectInSubmenu), keyEquivalent: "", at: 0)
		NSMenu.popUpContextMenu(menu, with: event, for: self)
	}

	///
	/// W submenu wybrano pozycję dodania nowej firmy.
	///
	func addDidSelectInSubmenu() {
		Event.addNewCompanyRequest.dispatch()
	}
	
	///
	/// W submenu wybrano pozycję edycji wybranej firmy.
	///
	func editDidSelectInSubmenu() {
		if let row = rowWhenSelectedSubmenu {
			if let company = dataSource?.tableView?(self, objectValueFor: nil, row: row) as? Company {
				Event.editCompanyRequest.dispatch(["id" : company.id as AnyObject])
			}
		}
	}
	
	///
	/// W submenu wybrano pozycję usunięcia wybranej firmy.
	///
	func removeDidSelectInSubmenu() {
	}
	
}
