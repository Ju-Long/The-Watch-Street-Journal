//
//  CustomFileManager.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 2/7/23.
//

import Foundation
import SwiftyJSON

class CustomFileManager {
    static func sharedContainerURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.BaBaSaMa.The-Watch-Street-Journal")!
    }
    
    func fileExist(_ filename: String) -> Bool {
        let file_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: file_dir.path) {
            return true
        }
        return false
    }

    func writeToFile(_ value: String, _ filename: String) throws {
        let document_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        try value.write(to: document_dir, atomically: true, encoding: String.Encoding.utf8)
    }
    
    func writeJSONToFile(_ json_value: JSON, _ filename: String) throws {
        let encoder = JSONEncoder()

        let document_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        let json_data = try encoder.encode(json_value)
        try json_data.write(to: document_dir)
    }
    
    func readFile(_ filename: String) throws -> String {
        let document_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        
        return try String(contentsOf: document_dir, encoding: String.Encoding.utf8)
    }

    func readFileToJSON(_ filename: String) throws -> JSON {
        let decoder = JSONDecoder()
        let document_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        let data = try Data(contentsOf: document_dir)
        return try decoder.decode(JSON.self, from: data)
    }
    
    func fileCreationDate(_ filename: String) throws {
        let document_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        let attr = try FileManager.default.attributesOfItem(atPath: document_dir.path()) as [FileAttributeKey: Any]
        debugPrint(attr)
    }

    func deleteFile(_ filename: String) throws {
        let document_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        try FileManager.default.removeItem(at: document_dir)
    }

    func getFileSize(_ filename: String) throws -> Int {
        guard fileExist(filename) else {
            return 0
        }

        let file_dir = CustomFileManager.sharedContainerURL().appendingPathComponent(filename)
        return try file_dir.resourceValues(forKeys: [.fileSizeKey]).fileSize!
    }
}
