//
//  EditOperation.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

struct EditOperation {
	let char: Character
	let range: NSRange
}

enum TokenType {
	case keyword, variable, package, member, method
	case string, number, bool
}

struct TokenInfo {
	let type: TokenType
	let range: Range<String.Index>
}
