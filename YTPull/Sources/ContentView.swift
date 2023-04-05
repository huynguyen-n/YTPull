//
//  ContentView.swift
//  YTPull
//
//  Created by Huy Nguyen on 04/04/2023.
//

import SwiftUI

struct ContentView: View {

    @State private var url = "https://www.youtube.com/watch?v=5Zj85fjB36s"

    var body: some View {
        VStack {
            TextField("URL", text: $url)
            Button("Get URL", action: didTapGetURL)
        }
        .padding()
    }

    private func didTapGetURL() {
        guard !url.isEmpty else {
            print("empty url")
            return
        }
        guard let bundle = Bundle.main.path(forResource: "yt-dlp", ofType: "sh") else {
            return
        }
        let path = String(bundle)
        shell(command: path)
        do {
            let json = try executeCommand(command: path, args: ["-f", "bv/ba", "-j", url])
            print(json)
        } catch {
            print(error)
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func executeCommand(command: String, args: [String]) throws -> String {

    let task = Process()
    task.launchPath = command
    task.arguments = args

    let pipeStdOut = Pipe()
    let pipeStdErr = Pipe()
    task.standardOutput = pipeStdOut
    task.standardError = pipeStdErr
    task.launch()

    let data = pipeStdOut.fileHandleForReading.readDataToEndOfFile()
    let output: String = String(data: data, encoding: String.Encoding.utf8)!


    if task.terminationStatus != 0 {
        let data = pipeStdErr.fileHandleForReading.readDataToEndOfFile()
        let errOutput: String = String(data: data, encoding: String.Encoding.utf8)!
        print("Unexpected error while executing command: \(errOutput)")
        throw GetInfoError(errOutput)
    }

    return output
}

func shell(command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/bin/chmod"
    task.arguments = ["u+x", command]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

struct GetInfoError: Error, LocalizedError {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}

