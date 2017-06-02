//
//  Editor.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

enum KeyWords: String {
	case Break = "break"
	case Default = "default"
	case Func = "func"
	case Interface = "interface"
	case Select = "select"
	
	//case         defer        go           map          struct
	//chan         else         goto         package      switch
	//const        fallthrough  if           range        type
	//continue     for          import       return       var
}

final class EditorView: NSTextView {
	static fileprivate let keyWords = "break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var"
	static fileprivate let keyWordsRegex = try! NSRegularExpression(pattern: "\\b(\(EditorView.keyWords))\\b", options: [])
	
	fileprivate var currentFontColor = NSColor.white
	private var filePath: String?
	
	override var backgroundColor: NSColor {
		get {
			return NSColor(calibratedWhite: 0.2, alpha: 1.0)
		}
		set {
			
		}
	}

	required init(frame frameRect: NSRect, filePath: String? = nil) {
		let textContainer = NSTextContainer(containerSize: frameRect.size)
		textContainer.widthTracksTextView = true
		textContainer.heightTracksTextView = true
		let textStorage = NSTextStorage()
		let layoutManager = NSLayoutManager()
		textStorage.addLayoutManager(layoutManager)
		layoutManager.addTextContainer(textContainer)
		self.filePath = filePath
		
		super.init(frame: frameRect, textContainer: textContainer)
		
		autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
		autoresizesSubviews = true
		insertionPointColor = NSColor.white
		isEditable = true
		isSelectable = true
		isRichText = true

		maxSize = NSSize(width: CGFloat(Float.greatestFiniteMagnitude), height: CGFloat(Float.greatestFiniteMagnitude))
		delegate = self
	
		if let fpath = filePath {
			if let string = try? String(contentsOfFile: fpath) {
				self.textStorage?.append(NSAttributedString(string: string))
			}
		}
		// ustawienie koloru tekstu i fontu musi być po(!) dodaniu tekstu
		textColor = currentFontColor
		font = NSFont.systemFont(ofSize: 12.0)
		
		self.textStorage?.delegate = self
		updateGeometry()
		coloredSyntax(self.textStorage!)
		

	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func updateGeometry() {
		frame.size.height = textStorage!.size().height + font!.pointSize
	}
	
	func openFile(fpath: String) {
		guard let string = try? String(contentsOfFile: fpath) else {
			return
		}
		textStorage?.append(NSAttributedString(string: string))
		updateGeometry()
		textColor = currentFontColor
		font = NSFont.systemFont(ofSize: 12.0)
		coloredSyntax(self.textStorage!)
		filePath = fpath
	}
}

//break        default      func         interface    select
//case         defer        go           map          struct
//chan         else         goto         package      switch
//const        fallthrough  if           range        type
//continue     for          import       return       var


extension EditorView: NSTextViewDelegate {
	func textDidChange(_ notification: Notification) {
		updateGeometry()
	}
}

extension EditorView: NSTextStorageDelegate {
	func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		
	}
	
	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		self.coloredSyntax(textStorage)
	}
	
	fileprivate func coloredSyntax(_ textStorage: NSTextStorage) {
		let string = textStorage.string
		
		textStorage.beginEditing()
		
		// usuwamy wszystkie kolory
		textStorage.addAttributes([NSForegroundColorAttributeName:currentFontColor], range: NSMakeRange(0, string.characters.count))
		
		// kolorujemy słowa kluczowe
		let matches = EditorView.keyWordsRegex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
		for match in matches {
			textStorage.addAttributes([NSForegroundColorAttributeName:NSColor.red], range: match.range)
			
		}
		textStorage.endEditing()
	}
}
