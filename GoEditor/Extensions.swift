//
//  Extensions.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 02/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Foundation

extension Data {

	func string() -> String? {
		return String(data: self, encoding: String.Encoding.utf8)
	}
}

extension String {
	
	func lastOccurenceOf(char: Character, fromIndex: String.Index? = nil) -> String.Index? {
		let start = startIndex
		let end = fromIndex ?? endIndex
		let range = start..<end
		return self.range(of: String(char), options: String.CompareOptions.backwards, range: range)?.lowerBound
	}
}
