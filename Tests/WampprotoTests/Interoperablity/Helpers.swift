import Foundation
import XCTest
@testable import Wampproto

func runCommand(command: String) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/local/bin/wampproto")
    process.arguments = command.split(separator: " ").map { String($0) }

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
            XCTFail("Failed to decode the output")
            return nil
        }

        process.waitUntilExit()

        if process.terminationStatus != 0 {
            XCTFail("Command execution failed with exit code \(process.terminationStatus)")
            return nil
        }

        return output
    } catch {
        XCTFail("Failed to execute command: \(error.localizedDescription)")
        return nil
    }
}

func runCommandAndDeserialize(serializer: Serializer, command: String) -> Message? {
    do {
        guard let output = runCommand(command: command) else {
            return nil
        }

        let outputBytes = try output.hexDecodedBytes()

        if let jsonSerializer = serializer as? JSONSerializer {
            guard let jsonString = String(data: Data(outputBytes), encoding: .utf8) else {
                XCTFail("Invalid json")
                return nil
            }

            return try jsonSerializer.deserialize(data: jsonString)
        }

        return try serializer.deserialize(data: Data(outputBytes))
    } catch let error as NSError {
        XCTFail("\(error.localizedDescription)")
        return nil
    }
}
