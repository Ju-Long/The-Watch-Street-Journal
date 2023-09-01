//
//  Data_hexString.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 30/6/23.
//

import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
