//
//  Country.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 24/6/23.
//

import Foundation

struct Country: Hashable, Comparable {
    let name: String
    let code: String
    let language: String
    let language_code: String
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.code == rhs.code
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.code)
    }
    
    static func < (lhs: Country, rhs: Country) -> Bool {
        lhs.name < rhs.name
    }
}
