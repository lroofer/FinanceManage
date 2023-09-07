//
//  ColorEncode.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 07.09.2023.
//

import Foundation
import SwiftUI

struct ColorEncode: Codable {
    enum DynamicColor: String, RawRepresentable, CaseIterable, Identifiable, Codable {
        var id: String {
            self.rawValue
        }
        var name: String { self.rawValue }
        case red = "Red",
             blue = "Blue",
             yellow = "Yellow",
             green = "Green",
             purple = "Purple"
        static var headerCases: [DynamicColor] {
            [.red, .blue, .yellow, .green, .purple]
        }
    }
    var stored: DynamicColor
    func get() -> Color {
        switch(stored) {
        case .blue:
            return .blue
        case .green:
            return .green
        case .purple:
            return .purple
        case .red:
            return .red
        case .yellow:
            return .yellow
        }
    }
}
