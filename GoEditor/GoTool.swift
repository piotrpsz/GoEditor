//
//  GoTool.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 01/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class GoTool {
	static func fmt() -> String? {
		let task = Process()
		let arguments: [String]? = []
		task.arguments = arguments
		task.launchPath = "gofmt"
		
		let output = Pipe()
		task.standardOutput = output
		task.standardError = output
		
		task.launch()
		task.waitUntilExit()
		
		return output.fileHandleForReading.readDataToEndOfFile().string()
	}
	
	static func run(dir: String, files: [String]) -> String? {
		let task = Process()
		var arguments = ["run"]
		arguments.append(contentsOf: files)
		task.arguments = arguments
		task.launchPath = "/usr/local/go/bin/go"
		task.currentDirectoryPath = dir
		
		let output = Pipe()
		task.standardOutput = output
		task.standardError = output
		
		task.launch()
		task.waitUntilExit()
		
		return output.fileHandleForReading.readDataToEndOfFile().string()
		
	}
	
}
