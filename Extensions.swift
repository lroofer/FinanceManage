//
//  Extensions.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 02.09.2023.
//

import Foundation

extension Date {
    func getDay() -> String {
        return self.formatted(date: .abbreviated, time: .omitted).components(separatedBy: " ")[0]
    }
    func getMonth() -> String {
        return self.formatted(date: .abbreviated, time: .omitted).components(separatedBy: " ")[1]
    }
    func getYear() -> String {
        return self.formatted(date: .abbreviated, time: .omitted).components(separatedBy: " ")[2]
    }
}
