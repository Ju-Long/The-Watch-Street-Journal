//
//  Date_-.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 18/6/23.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> String {
        let calender = Calendar.current
        let diff = calender.dateComponents([.hour, .minute], from: rhs, to: lhs)
        
        if let hour = diff.hour {
            return "\(hour) Hrs"
        } else if let mins = diff.minute {
            return "\(mins) Mins"
        } else {
            return "Now"
        }
    }
}

