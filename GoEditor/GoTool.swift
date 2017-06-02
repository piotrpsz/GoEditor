//
//  GoTool.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 01/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

func after(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

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
