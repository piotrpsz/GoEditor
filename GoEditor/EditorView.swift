//
//  Editor.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class EditorView: NSTextView, NSTextStorageDelegate {
	static private let initialFileName = "Unknown.go"
	static fileprivate let keyWords = "break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var"
	static fileprivate let keyWordsRegex = try! NSRegularExpression(pattern: "\\b(\(EditorView.keyWords))\\b", options: [])
	
	static private let colorKey        = NSColor(calibratedRed: 1.0, green: 0.2, blue: 0.3, alpha: 0.9)
	static private let colorCommentC   = NSColor(calibratedWhite: 0.4, alpha: 0.9)
	static private let colorCommentCpp = NSColor(calibratedWhite: 0.6, alpha: 0.9)
	static private let colorString     = NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.9)
	static private let colorInt        = NSColor(calibratedRed: 0.6, green: 1.0, blue: 0.2, alpha: 0.9)
	static private let colorFloat      = NSColor(calibratedRed: 0.2, green: 1.0, blue: 0.6, alpha: 0.9)
	static private let colorOfOperation = NSColor(calibratedRed: 0.6, green: 0.6, blue: 0.0, alpha: 0.9)
	static private let colorOfType      = NSColor(calibratedRed: 0.0, green: 0.6, blue: 0.6, alpha: 0.9)

	static private let colorOfObjectName   = NSColor(calibratedRed: 0.7, green: 0.4, blue: 0.7, alpha: 0.9)
	static private let colorOfObjectMember = NSColor(calibratedRed: 0.8, green: 0.8, blue: 0.3, alpha: 0.9)

	
	private var currentFontColor = NSColor.white
	fileprivate var editOperation: EditOperation?
	fileprivate var localEditing = false
	
	var filePath: String!
	
	override var backgroundColor: NSColor {
		get {
			return NSColor(calibratedWhite: 0.2, alpha: 1.0)
		}
		set {
			
		}
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	var isEmpty: Bool {
		if let count = textStorage?.string.count {
			return (count == 0)
		}
		return true
	}
	var isChanged = false

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
			self.filePath = EditorView.initialFileName
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
        font = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .medium)
        
        self.textStorage?.delegate = self
        updateGeometry()
        coloredSyntax(self.textStorage!)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateGeometry() {
		frame.size.height = textStorage!.size().height + font!.pointSize
	}
	
	func openFile(fpath: String) {
		guard let string = try? String(contentsOfFile: fpath) else {
			tr.Info(self, info: "Can't read the file (\(fpath).")
			return
		}
        setNewContent(string: string)
		filePath = fpath
	}

    private func setNewContent(string: String) {
        after(0.1) {
            self.textStorage!.replaceCharacters(in: NSRange(location: 0, length: self.textStorage!.characters.count), with: NSAttributedString(string: string))
			self.setSelectedRange(NSMakeRange(0, 0))
            self.updateGeometry()
            self.textColor = self.currentFontColor
            self.font = NSFont.systemFont(ofSize: 12.0)
            self.coloredSyntax(self.textStorage!)
        }
    }
	
	//
	// Saves editor content to disk.
	//
	func save() {
		guard !isEmpty && isChanged else {
			return
		}
		
		var canSave = true
		if filePath == EditorView.initialFileName {
			canSave = false
			let panel = NSSavePanel()
			panel.canCreateDirectories = true
			panel.showsHiddenFiles = false
			panel.isExtensionHidden = false
			panel.nameFieldStringValue = filePath
			if let path = Shared.mainPackageDirectory {
				panel.directoryURL = URL(fileURLWithPath: path.withoutLastPathComponent())
			} else {
				panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
			}
			
			if panel.runModal() == .OK {
				if let url = panel.url {
					self.filePath = url.path
					canSave = true
				}
			}
		}
		
		guard canSave else {
			return
		}
		
		do {
			try textStorage?.string.write(toFile: filePath, atomically: true, encoding: .utf8)
			isChanged = false
			Event.editorStateDidChange.dispatch()
		}
		catch let error as NSError {
			Shared.alert(title: Shared.appName, message: "Can't save the file!", information: error.localizedDescription)
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
		let text = textStorage.string
		
		self.localEditing = true
		textStorage.beginEditing()
		textStorage.addAttributes([NSAttributedStringKey.foregroundColor:self.currentFontColor], range: NSMakeRange(0, text.count))

		let foundedTokens = Parser(text: text).run().tokens
		
		// x/crypto/bcrypt
		
		for token in foundedTokens {
//			print(token)
			let range = token.pos.range()
			switch token.type {
			case .keyword:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorKey], range: range)
			case .commentC:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorCommentC], range: range)
			case .commentCpp:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorCommentCpp], range: range)
			case .stringValue:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorString], range: range)
			case .intValue:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorInt], range: range)
			case .floatValue:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorFloat], range: range)
			case .operation:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorOfOperation], range: range)
			case .basicType:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorOfType], range: range)
			case .objectName:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorOfObjectName], range: range)
			case .objectMember:
				textStorage.addAttributes([NSAttributedStringKey.foregroundColor: EditorView.colorOfObjectMember], range: range)
			default:
				()
			}
		}
		
		
//		let matches = EditorView.keyWordsRegex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count))
//		for match in matches {
//			textStorage.addAttributes([NSAttributedStringKey.foregroundColor:EditorView.keyColor], range: match.range)
//		}
		textStorage.endEditing()
		self.localEditing = false
	}
	
	// MARK: - NSTextStorageDelegate
	func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
	}
	
	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		guard !localEditing else {
			return
		}
		
		editOperation = nil
		if delta == 1 {
			let changedText = textStorage.attributedSubstring(from: editedRange).string
			if changedText == "{" {
				editOperation = EditOperation(char: "{", range: editedRange)
			}
			else if changedText == "(" {
				editOperation = EditOperation(char: "(", range: editedRange)
			}
			else if changedText == "\n" {
				editOperation = EditOperation(char: "\n", range: editedRange)
			}
		}
	}
}

extension EditorView: NSTextViewDelegate {
	
	func textDidChange(_ note: Notification) {
		guard let textStorage = textStorage else {
			return
		}
		
		if !isChanged {
			isChanged = true
			Event.editorStateDidChange.dispatch()
		}
		
		if let editOperation = editOperation {
			switch editOperation.char {
			case "{":
				braceDidAdd()
			case "(":
				bracketDidAdd()
			case "\n":
				newLineDidAdd()
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
		
		currentCursorPosition += 1 + prefixPlusIntendation.count
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
	
	private func newLineDidAdd() {
		guard let textStorage = textStorage, let editOperation = editOperation else {
			return
		}
		
		localEditing = true
		var text = textStorage.string
		var currentCursorPosition = selectedRange().location
		let prefix = prefixOfLine(withIndex: currentCursorPosition - 2, text: text)
		if let index = text.index(text.startIndex, offsetBy: editOperation.range.location + editOperation.range.length, limitedBy: text.endIndex) {
			text.insert(contentsOf: prefix, at: index)
		}
		
		textStorage.beginEditing()
		textStorage.replaceCharacters(in: NSMakeRange(0, textStorage.characters.count), with: text)
		textStorage.endEditing()
		
		currentCursorPosition += prefix.characters.count
		setSelectedRange(NSMakeRange(currentCursorPosition, 0))
		localEditing = false
	}
	
	private func prefixOfLine(withIndex index: Int, text: String) -> String {
		var prefix = ""
		if index >= 0 && index < text.count {
			let spaces = CharacterSet.whitespaces
			var position = text.index(text.startIndex, offsetBy: index)
			while (position >= text.startIndex) && (position < text.endIndex) {
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
	
//	private func gofmt() {
//		let temp = FileManager.default.temporaryDirectory.appendingPathComponent("GoEditor_tmp.go")
//		guard Shared.removeFile(at: temp) else {
//			fatalError()
//		}
//
//		do {
//			try self.textStorage!.string.write(to: temp, atomically: true, encoding: .utf8)
//		} catch let error as NSError {
//			Swift.print("\(error)")
//			fatalError()
//		}
//
//		let (status, string) = GoTool.fmt(fpath: temp.path)
//		if status == 0 {
//			if let string = string {
//				setNewContent(string: string)
//			}
//		} else {
//			Event.contentForConsole.dispatch(["text":string as Any])
//			updateGeometry()
//			coloredSyntax(self.textStorage!)
//		}
//	}
}

