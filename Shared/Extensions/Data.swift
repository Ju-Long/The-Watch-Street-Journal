//
//  Data.swift
//  The Watch Street Journal
//
//  Created by Long Ju on 2/20/26.
//

import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
