//
//  TextFieldPro.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 04.09.2023.
//

import SwiftUI

struct TextFieldPro: UIViewRepresentable {
    typealias UIViewType = UITextFieldPro
    
    let numberFormatter: NumberFormatter
    let currencyField: UITextFieldPro
    
    init(value: Binding<Int>) {
        self.numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.currencyCode = "RUB"
        numberFormatter.currencySymbol = ""
        currencyField = UITextFieldPro(formatter: numberFormatter, value: value)
    }
    
    func makeUIView(context: Context) -> UITextFieldPro {
        return currencyField
    }
    
    func updateUIView(_ uiView: UITextFieldPro, context: Context) { }
}

struct TextFieldPro_Previews: PreviewProvider {
    @State static private var test = 0
    static var previews: some View {
        TextFieldPro(value: $test)
    }
}
