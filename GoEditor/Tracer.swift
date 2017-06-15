//
//  Tracer.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 15/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Foundation

final class Tracer {
	private var prefix = ""
	
	func info(_ object: Any, _ info: String? = nil, function: String = #function, line: Int = #line) {
		var s = "\(prefix)INF \(type(of: object)).\(function),"
		if let info = info {
			print(" \(info),", terminator: "", to: &s)
		}
		print(" (line: \(line))(thread: \(Shared.threadInfo()))", terminator: "", to: &s)
		fputs(s + "\n", stderr)
		fflush(stderr)
	}
	
	func `in`(_ object: Any, function: String = #function) {
		var s = "\(prefix)>>> \(type(of: object)):\(function) "
		print("(thread: \(Shared.threadInfo()))", terminator: "", to: &s)
		fputs(s + "\n", stderr)
		fflush(stderr)
		prefix += "\t"
	}
	
	func out(_ object: Any, function: String = #function) {
		prefix.removeLast()
		var s = "\(prefix)<<< \(type(of: object)):\(function) "
		print("(thread: \(Shared.threadInfo()))", terminator: "", to: &s)
		fputs(s + "\n", stderr)
		fflush(stderr)
	}
	
	func callStack() {
		let stack = Thread.callStackSymbols
		for item in stack {
			print("\(item)")
		}
	}
	
}
