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

private let types: Set = ["bool", "string", "int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64", "uintptr", "byte", "rune", "float32", "float64", "complex64", "complex128"]
private let arithmeticOperators: Set = ["+", "-", "*", "/", "%", "++", "--"]
private let relationalOperators: Set = ["==", "!=", ">", "<", ">=", "<="]
private let logicalOperators: Set = ["&&", "||", "!"]
private let bitwiseOperators: Set = ["&", "|", "^", "<<", ">>"]
private let assigmentOperators: Set = ["=", "+=", "-=", "*=", "/=", "%=", "<<=", ">>=", "&=", "^=", "|="]
private let separators: Set = [" ", "\n", "\t", ",", "(", ")", "[", "]"]



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
	
	required init(fpath: String) {
		self.text = try! String(contentsOfFile: fpath)
	}
	
	
	func run() {
		var index = skipSeparators(from: text.startIndex)
		while index < text.endIndex {
			let c = text[index]
			
			// omijamy komentarze komentarze
			if c == Slash {
				let nextIndex = text.index(after: index)
				if nextIndex < text.endIndex {
					let cc = text[nextIndex]
					if cc == Slash {
						if let token = skipCommentC(from: index) {
							tokens.append(token)
							index = text.index(index, offsetBy: token.pos.len)
							continue
						}
					}
					else if cc == Asterisk {
						if let token = skipCommentCpp(from: index) {
							tokens.append(token)
							index = text.index(index, offsetBy: token.pos.len + 1)
							continue
						}
					}
				}
			}
			
			// omijamy łańuchy tekstowe
			if c == Quotation {
				if let token = skipString(from: index) {
					tokens.append(token)
					index = text.index(index, offsetBy: token.pos.len + 1)
					continue
				}
			}
			
			if isLiteralCharacter(c) {
				let (items, pos) = parseLiteral(from: index)
				if items != nil {
//					print("Items count for literal: \(items!.count)")
					tokens.append(contentsOf: items!)
				}
				else {
					print("Items of literal is nil")
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
			
			index = text.index(after: index)
		}
		print("STOP \(tokens.count)")
	}
}


extension Parser {
	
	private func parseLiteral(from idx: String.Index) -> ([Token]?, String.Index) {
		var indexes: [Index2] = []
		var pos = idx
		var startPos = pos
		
		while pos < text.endIndex {
			let c = text[pos]
			if isLiteralCharacter(c) {
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
		
		var tokens: [Token] = []
		
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
			tokens.append(token)
		}
		else {
			for poss in indexes {
				let content = String(text[poss.idx0..<poss.idx1])
				let token = Token(name: content, pos: Position(text, poss.idx0, poss.idx1), type: .unknownType)
				tokens.append(token)
			}
		}
		return ((tokens.isEmpty ? nil : tokens), pos)
	}
	
	private func parseNumber(from idx: String.Index) -> Token? {
		var pos = text.index(after: idx)
		while pos < text.endIndex {
			if !isNumberCharacter(text[pos]) {
				return Token(name: String(text[idx..<pos]), pos: Position(text, idx, pos), type: ItemType.intValue)
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	private func skipString(from idx: String.Index) -> Token? {
		var pos = text.index(after: idx)
		while pos < text.endIndex {
			if text[pos] == Quotation {
				if text[text.index(before: pos)] != Backslash {
					return Token(name: String(text[idx...pos]), pos: Position(text, idx, pos), type: ItemType.stringValue)
				}
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	private func skipCommentC(from idx: String.Index) -> Token? {
		var pos = idx
		while pos < text.endIndex {
			if text[pos] == NewLine {
				return Token(name: String(text[idx..<pos]), pos: Position(text, idx, pos), type: ItemType.commentC)
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	private func skipCommentCpp(from idx: String.Index) -> Token? {
		var pos = text.index(idx, offsetBy: 2)
		while pos < text.endIndex {
			if text[pos] == Asterisk {
				let nextPos = text.index(after: pos)
				if nextPos < text.endIndex {
					if text[nextPos] == Slash {
						return Token(name: String(text[idx...nextPos]), pos: Position(text, idx, nextPos), type: ItemType.commentCpp)
					}
				}
			}
			pos = text.index(after: pos)
		}
		return nil
	}
	
	private func skipSeparators(from idx: String.Index) -> String.Index {
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
