//
//  GoTool.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 01/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class GoTool {
    static func fmt(fpath: String) -> (Int, String?) {
		let task = Process()
		task.arguments = [fpath]
		task.launchPath = "/usr/local/go/bin/gofmt"
		
		let output = Pipe()
		task.standardOutput = output
		task.standardError = output
		
		task.launch()
		task.waitUntilExit()
		
        let status = Int(task.terminationStatus)
        let string = output.fileHandleForReading.readDataToEndOfFile().string()
		return (status, string)
	}
	
	static func run(dir: String, files: [String]) -> String? {
		let task = Process()
		
		var arguments = ["run"]
		arguments.append(contentsOf: files)
		task.arguments = arguments
		
		task.environment = ["GOPATH":"/Users/piotr/Projects/Go"];
		task.launchPath = "/usr/local/go/bin/go"
		task.currentDirectoryPath = dir
		
		let output = Pipe()
		task.standardOutput = output
		task.standardError = output
		
		task.launch()
		task.waitUntilExit()
		
		return output.fileHandleForReading.readDataToEndOfFile().string()
	}
	
	static func installedPackages() {
		let task = Process()
		
		task.launchPath = "/usr/local/go/bin/go"
		task.arguments = ["list", "..."]
		let output = Pipe()
		task.standardOutput = output
		task.launch()
		task.waitUntilExit()
		if let result = output.fileHandleForReading.readDataToEndOfFile().string() {
			tr.Info(self, info: "Installed packages:\n\(result)")
		}
	}
	
}
