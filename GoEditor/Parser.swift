//
//  Lexer.swift
//  GoEditor
//
//  Created by Piotr Pszczółkowski on 30/05/2018.
//  Copyright © 2018 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

private let keywords: Set = [
	"break",
	"default",
	"func",
	"interface",
	"select",
	"case",
	"defer",
	"go",
	"map",
	"struct",
	"chan",
	"else",
	"goto",
	"package",
	"switch",
	"const",
	"fallthrough",
	"if",
	"range",
	"type",
	"continue",
	"for",
	"import",
	"return",
	"var"]

private let types: Set = ["error", "bool", "string", "int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64", "uintptr", "byte", "rune", "float32", "float64", "complex64", "complex128"]
private let arithmeticOperators: Set = ["+", "-", "*", "/", "%", "++", "--"]
private let relationalOperators: Set = ["==", "!=", ">", "<", ">=", "<="]
private let logicalOperators: Set = ["&&", "||", "!"]
private let bitwiseOperators: Set = ["&", "|", "^", "<<", ">>"]
private let assigmentOperators: Set = ["=", ":=", "+=", "-=", "*=", "/=", "%=", "<<=", ">>=", "&=", "^=", "|="]
private let separators: Set = [" ", "\n", "\t", ",", "(", ")", "[", "]", "{", "}"]



//case keyword, variable, package, member, method
//case string, number, bool

enum ItemType {
	case unknownType
	case basicType
	case objectName
	case objectMember
	case keyword
	case stringValue
	case intValue
	case floatValue
	case boolValue
	case commentC
	case commentCpp
	case operation
}

struct Index2 {
	let idx0: String.Index
	let idx1: String.Index
}

struct Position: CustomStringConvertible {
	let offset: Int
	let len: Int
	
	init(_ text: String, _ idx0: String.Index, _ idx1: String.Index) {
		offset = text.distance(from: text.startIndex, to: idx0)
		len = text.distance(from: idx0, to: idx1)
	}
	
	var description: String {
		get {
			return "(offset: \(offset), len: \(len))"
		}
	}
	
	func range() -> NSRange {
		return NSMakeRange(offset, len)
	}
}

struct Token: CustomStringConvertible {
	let name: String
	let pos: Position
	let type: ItemType

	var description: String {
		get {
			return "(name: \(name), type: \(type), pos: \(pos)"
		}
	}
}


final class Parser {
	private let a = Character("a")
	private let A = Character("A")
	private let z = Character("z")
	private let Z = Character("Z")
	private let Digit0 = Character("0")
	private let Digit9 = Character("9")
	private let DecimalPoint = Character(".")
	private let Minus = Character("-")
	private let Underscore = Character("_")
	private let Slash = Character("/")
	private let Backslash = Character("\\")
	private let NewLine = Character("\n")
	private let Asterisk = Character("*")
	private let Quotation = Character("\"")
	
	
	private let text: String
	
	var tokens: [Token] = []
	
	init(fpath: String) {
		self.text = try! String(contentsOfFile: fpath)
	}
	init(text: String) {
		self.text = text
	}
	
	
	func run() -> Parser {
		var index = text.startIndex
//		var index = skipSeparators(from:text.startIndex)
		while index < text.endIndex {
			index = skipSeparators(from: index)
			if index >= text.endIndex {
				return self
			}
//			tr.Info(self, info: "\(index.encodedOffset)")
			let c = text[index]
			
			// omijamy komentarze komentarze
			if c == Slash {
				let nextIndex = text.index(after: index)
				if nextIndex < text.endIndex {
					let cc = text[nextIndex]
					if cc == Slash {
						if let token = parseCommentCpp(from: index) {
							tokens.append(token)
							index = text.index(index, offsetBy: token.pos.len)
							continue
						}
					}
					else if cc == Asterisk {
						if let token = parseCommentC(from: index) {
							tokens.append(token)
							index = text.index(index, offsetBy: token.pos.len)
							continue
						}
					}
				}
			}
			
			// omijamy łańuchy tekstowe
			if c == Quotation {
				if let token = parseString(from: index) {
					tokens.append(token)
					index = text.index(index, offsetBy: token.pos.len)
					continue
				}
			}
			
			if isLiteralCharacter(c) {
				let (literalTokens, pos) = parseLiteral(from: index)
				for item in literalTokens {
					if item.type != .unknownType {
						tokens.append(item)
					}
				}
				index = pos
				continue
			}

			if isNumberCharacter(c) {
				if let token = parseNumber(from: index) {
					tokens.append(token)
					index = text.index(index, offsetBy: token.pos.len + 1)
					continue
				}
			}
			
			let (token, pos) = parseOperation(from: index)
//			if token.type != .unknownType {
				tokens.append(token)
//			}
//			index = text.index(index, offsetBy: token.pos.len + 1)
			index = pos
		}
		return self
	}
}


extension Parser {
	
	///
	/// parseOperation
	///
	private func parseOperation(from idx: String.Index) -> (Token, String.Index) {
//		tr.In(self)
//		defer { tr.Out(self) }
		
		var pos = idx
		while pos < text.endIndex {
			let c = text[pos]
			if isSeparator(c: c) || isDigit(c) || isLiteralCharacter(c) {
				let content = String(text[idx..<pos])
				var type = ItemType.unknownType
				if	arithmeticOperators.contains(content) ||
					relationalOperators.contains(content) ||
					logicalOperators.contains(content)    ||
					bitwiseOperators.contains(content)    ||
					assigmentOperators.contains(content)
				{
					type = .operation
				}
				let token = Token(name: content, pos: Position(text, idx, pos), type: type)
//				tr.Info(self, info: "1. \(token)")
				return (token, pos)
			}
			pos = text.index(after: pos)
		}
		let token = Token(name: String(text[idx..<pos]), pos: Position(text, idx, pos), type: .unknownType)
//		tr.Info(self, info: "2. \(token)")
		return (token, pos)
	}
	
	///
	/// parseLiteral
	///
	private func parseLiteral(from idx: String.Index) -> ([Token], String.Index) {
//		tr.In(self)
//		defer { tr.Out(self) }

		var indexes: [Index2] = []
		var pos = idx
		var startPos = pos
		
		while pos < text.endIndex {
			let c = text[pos]
			if isLiteralCharacter(c) || isDigit(c) {
				pos = text.index(after: pos)
				continue
			}
			if c == DecimalPoint {
				let poss = Index2(idx0: startPos, idx1: pos)
				indexes.append(poss)
				pos = text.index(after: pos)
				startPos = pos
				continue
			}
			let poss = Index2(idx0: startPos, idx1: pos)
			indexes.append(poss)
			break
		}
		
		var literalTokens: [Token] = []
		
		if indexes.count == 1 {
			let poss = indexes.first!
			let content = String(text[poss.idx0..<poss.idx1])
			var type = ItemType.unknownType
			
			if keywords.contains(content) {
				type = .keyword
			} else if types.contains(content){
				type = .basicType
			}
			let token = Token(name: content, pos: Position(text, idx, pos), type: type)
			literalTokens.append(token)
		}
		else {
			let lastPoss = indexes.removeLast()
			
			for poss in indexes {
				let content = String(text[poss.idx0..<poss.idx1])
				let token = Token(name: content, pos: Position(text, poss.idx0, poss.idx1), type: .objectName)
				literalTokens.append(token)
			}
			let content = String(text[lastPoss.idx0..<lastPoss.idx1])
			let token = Token(name: content, pos: Position(text, lastPoss.idx0, lastPoss.idx1), type: .objectMember)
			literalTokens.append(token)

		}
		return (literalTokens, pos)
	}
	
	///
	/// parserNumber
	///
	private func parseNumber(from idx: String.Index) -> Token? {
//		tr.In(self)
//		defer { tr.Out(self) }

		var pos = text.index(after: idx)
		while pos < text.endIndex {
			if !isNumberCharacter(text[pos]) {
				let content = String(text[idx..<pos])
				let decimalPointExists = content.contains(DecimalPoint)
				return Token(name: content, pos: Position(text, idx, pos), type: decimalPointExists ? ItemType.floatValue : ItemType.intValue)
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	///
	/// parseString
	///
	private func parseString(from idx: String.Index) -> Token? {
//		tr.In(self)
//		defer { tr.Out(self) }

		var pos = text.index(after: idx)
		while pos < text.endIndex {
			if text[pos] == Quotation {
				if text[text.index(before: pos)] != Backslash {
					return Token(name: String(text[idx...pos]), pos: Position(text, idx, text.index(after: pos)), type: ItemType.stringValue)
				}
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	///
	/// parseCommentCpp
	///
	private func parseCommentCpp(from idx: String.Index) -> Token? {
		var pos = idx
		
//		tr.In(self)
//		defer {
//			print("\(pos.encodedOffset)")
//			tr.Out(self)
//		}
		
		while pos < text.endIndex {
			if text[pos] == NewLine {
				return Token(name: String(text[idx..<pos]), pos: Position(text, idx, pos), type: ItemType.commentCpp)
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	///
	/// parseCommentC
	///
	private func parseCommentC(from idx: String.Index) -> Token? {
		var pos = text.index(idx, offsetBy: 2)
		
//		tr.In(self)
//		defer {
//			print("\(pos.encodedOffset)")
//			tr.Out(self)
//		}

		while pos < text.endIndex {
			if text[pos] == Asterisk {
				let nextPos = text.index(after: pos)
				if nextPos < text.endIndex {
					if text[nextPos] == Slash {
						return Token(name: String(text[idx...nextPos]), pos: Position(text, idx, text.index(after: nextPos)), type: ItemType.commentC)
					}
				}
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	private func skipSeparators(from idx: String.Index) -> String.Index {
//		tr.In(self)
//		defer { tr.Out(self) }

		var pos = idx
		while pos < text.endIndex {
			if !isSeparator(c: text[pos]) {
				return pos
			}
			pos = text.index(after: pos)
		}
		return text.endIndex
	}
	
	
	
	private func isSeparator(c: Character) -> Bool {
		return separators.contains(String(c))
	}
	
	private func isLetter(_ c: Character) -> Bool {
		return (c >= a && c <= z) || (c >= A && c <= Z)
	}
	private func isLiteralCharacter(_ c: Character) -> Bool {
		return isLetter(c) || c == Underscore
	}
	
	private func isDigit(_ c: Character) -> Bool {
		return c >= Digit0 && c <= Digit9
	}
	private func isNumberCharacter(_ c: Character) -> Bool {
		return isDigit(c) || c == Minus || c == DecimalPoint
	}

}
