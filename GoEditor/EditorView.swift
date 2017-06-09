//
//  Editor.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class EditorView: NSTextView, NSTextStorageDelegate {
	static private let defaultFileName = "Unknown.go"
	static fileprivate let keyWords = "break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var"
	static fileprivate let keyWordsRegex = try! NSRegularExpression(pattern: "\\b(\(EditorView.keyWords))\\b", options: [])
	
	private var currentFontColor = NSColor.white
	fileprivate var editOperation: EditOperation?
	
	var filePath: String!
	
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
		
		if let fpath = filePath {
			self.filePath = fpath
		} else {
			self.filePath = EditorView.defaultFileName
		}
		
        super.init(frame: frameRect, textContainer: textContainer)
        
        autoresizingMask = [.width, .height]
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
        setNewContent(string: string)
		filePath = fpath
	}

    fileprivate func setNewContent(string: String) {
        after(0.1) {
            self.textStorage!.replaceCharacters(in: NSRange(location: 0, length: self.textStorage!.characters.count), with: NSAttributedString(string: string))
            self.updateGeometry()
            self.textColor = self.currentFontColor
            self.font = NSFont.systemFont(ofSize: 12.0)
            self.coloredSyntax(self.textStorage!)
        }
    }
    
	func save() {
		guard  filePath != "tmp.go" else {
			return
		}
		
		do {
			try textStorage?.string.write(toFile: filePath, atomically: true, encoding: .utf8)
		}
		catch let error as NSError {
			Swift.print("\(error)")
			// dialog with information
		}
	}
	
//	override func performKeyEquivalent(with event: NSEvent) -> Bool {
//		Swift.print("Perform Key: \(event)")
//		if let string = event.charactersIgnoringModifiers {
//			if let char = string.characters.first {
//				Swift.print("Perform Key: \(char)")
//			}
//		}
//		//		NSString *string = [event charactersIgnoringModifiers];
//		//		NSInteger code = (NSInteger)[string characterAtIndex:0];
//		return false
//	}
	
	private func coloredSyntax(_ textStorage: NSTextStorage) {
		let string = textStorage.string
		
		textStorage.beginEditing()
		textStorage.addAttributes([NSAttributedStringKey.foregroundColor:currentFontColor], range: NSMakeRange(0, string.characters.count))
		let matches = EditorView.keyWordsRegex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
		for match in matches {
			textStorage.addAttributes([NSAttributedStringKey.foregroundColor:NSColor.red], range: match.range)
		}
		textStorage.endEditing()
	}
	
	// MARK: - NSTextStorageDelegate
	
	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		self.coloredSyntax(textStorage)
		editOperation = nil
		
		if delta != -1 {
			let changedText = textStorage.attributedSubstring(from: editedRange).string
			if changedText == "{" {
				editOperation = EditOperation(char: "{", range: editedRange)
			} else if changedText == "(" {
				editOperation = EditOperation(char: "(", range: editedRange)
			}
		}
	}
}

extension EditorView: NSTextViewDelegate {
	
	func textDidChange(_ note: Notification) {
		guard let textStorage = textStorage else {
			return
		}
		if let editOperation = editOperation {
			switch editOperation.char {
			case "{":
				braceDidAdd()
			case "(":
				bracketDidAdd()
			default:
				()
			}
		}
		updateGeometry()
		super.lnv_textDidChange(notification: note as NSNotification)
		coloredSyntax(textStorage)
	}
	
	private func braceDidAdd() {
		guard let textStorage = textStorage, let editOperation = editOperation else {
			return
		}
		var text = textStorage.string
		var currentCursorPosition = selectedRange().location
		let prefix = prefixOfLine(withIndex: currentCursorPosition - 1, text: text)
		let prefixPlusIntendation = prefix + "\t"
		let textToInsert = "\n\(prefixPlusIntendation)\n\(prefix)}"
		let index = text.index(text.startIndex, offsetBy: editOperation.range.location + editOperation.range.length)
		text.insert(contentsOf: textToInsert, at: index)
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSMakeRange(0, textStorage.characters.count), with: text)
		textStorage.endEditing()
		
		currentCursorPosition += 1 + prefixPlusIntendation.characters.count
		setSelectedRange(NSMakeRange(currentCursorPosition, 0))
	}
	
	private func bracketDidAdd() {
		guard let textStorage = textStorage, let editOperation = editOperation else {
			return
		}
		var text = textStorage.string
		let currentCursorPosition = selectedRange().location
		let textToInsert = ")"
		let index = text.index(text.startIndex, offsetBy: editOperation.range.location + editOperation.range.length)
		text.insert(contentsOf: textToInsert, at: index)
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSMakeRange(0, textStorage.characters.count), with: text)
		textStorage.endEditing()
		
		setSelectedRange(NSMakeRange(currentCursorPosition, 0))
	}
	
	func prefixOfLine(withIndex index: Int, text: String) -> String {
		let spaces = CharacterSet.whitespaces
		var position = text.index(text.startIndex, offsetBy: index)
		var prefix = ""
		while position >= text.startIndex {
			let c = text[position]
			if c == "\n" {
				break
			}
			if spaces.contains(c.unicodeScalars.first!) {
				prefix.append(c)
			} else {
				prefix = ""
			}
			if position == text.startIndex {
				break
			}
			position = text.index(before: position)
		}
		return prefix
	}
	
	
//	func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
//		Swift.print("\(commandSelector)")
//		if commandSelector == #selector(insertNewline(_:)) {
//			gofmt()
//		}
//		return false
//	}
	
	private func gofmt() {
		let temp = FileManager.default.temporaryDirectory.appendingPathComponent("GoEditor_tmp.go")
		guard Shared.removeFile(at: temp) else {
			fatalError()
		}
		
		do {
			try self.textStorage!.string.write(to: temp, atomically: true, encoding: .utf8)
		} catch let error as NSError {
			Swift.print("\(error)")
			fatalError()
		}
		
		let (status, string) = GoTool.fmt(fpath: temp.path)
		if status == 0 {
			if let string = string {
				setNewContent(string: string)
			}
		} else {
			Event.contentForConsole.dispatch(["text":string as Any])
			updateGeometry()
			coloredSyntax(self.textStorage!)
		}
	}
}

