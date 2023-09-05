//
//  Extensions.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 02.09.2023.
//

import Foundation

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
            return calendar.dateComponents(Set(components), from: self)
        }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Decimal {
    func show() -> String {
        if Int(truncating: self * 100 as NSDecimalNumber) % 100 == 0 {
            return self.formatted(.number.precision(.fractionLength(0)))
        }
        return self.formatted(.number.precision(.fractionLength(1)))
    }
}

extension Int {
    func convertToMonth() -> String {
        switch self {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return "N/A"
        }
    }
}
