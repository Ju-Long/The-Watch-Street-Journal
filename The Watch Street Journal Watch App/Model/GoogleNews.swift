//
//  GoogleNewsModel.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 18/6/23.
//

import Foundation

struct GoogleNews {
    let id: String
    
    let source: GoogleNewsSource
    let publish_date: Date
    let description: [GoogleNewsSource]
    
    struct GoogleNewsSource {
        let title: String
        let source: String
        let source_url: String
    }
    
    init(source: GoogleNewsSource, publish_date: Date, description: [GoogleNewsSource]) {
        self.id = source.title
        self.source = source
        self.publish_date = publish_date
        self.description = description
    }
}

extension GoogleNews: Identifiable, Hashable {
    static func == (lhs: GoogleNews, rhs: GoogleNews) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.id)
    }
}
