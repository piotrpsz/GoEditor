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

private let arithmeticOperators: Set = ["+", "-", "*", "/", "%", "++", "--"]
private let relationalOperators: Set = ["==", "!=", ">", "<", ">=", "<="]
private let logicalOperators: Set = ["&&", "||", "!"]
private let bitwiseOperators: Set = ["&", "|", "^", "<<", ">>"]
private let assigmentOperators: Set = ["=", "+=", "-=", "*=", "/=", "%=", "<<=", ">>=", "&=", "^=", "|="]
private let separators: Set = [" ", "\n", "\t", "(", ")", "[", "]"]



//case keyword, variable, package, member, method
//case string, number, bool

enum ItemType {
	case packageName
	case keyword
	case stringValue
	case intValue
	case floatValue
	case boolValue
	case commentC
	case commentCpp
	case operation
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
			return "(name: \(name), pos: \(pos), type: \(type))"
		}
	}
}


final class Parser {
	private let underscore = Character("_")
	private let a = Character("a")
	private let A = Character("A")
	private let z = Character("z")
	private let Z = Character("Z")
	private let Slash = Character("/")
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
			
			// komentarze
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
			if
			
			index = text.index(after: index)
		}
		
	}
}


extension Parser {
	
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
	private func isLetter(c: Character) -> Bool {
		return (c >= a && c <= z) || (c >= A && c <= Z) || (c == underscore)
	}

}
