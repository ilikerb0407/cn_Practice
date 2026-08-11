//
//  CurrencyAmount.swift
//  cn_Practice
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import Foundation

enum Currency: String, CaseIterable {
    case usd = "USD"
    case krw = "KRW"
    case jpy = "JPY"

    /// 這個幣別小數點後要顯示幾位
    /// JPY 沒有小數位(最小單位就是整數円),USD/KRW 常見顯示到小數點後兩位
    var decimalDigits: Int {
        switch self {
        case .usd: return 2
        case .krw: return 0
        case .jpy: return 0
        }
    }

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .krw: return "₩"
        case .jpy: return "¥"
        }
    }
}

struct CurrencyAmount {
    let value: Decimal
    let currency: Currency

    /// 格式化成使用者看得懂的字串,例如 "$1,234.56" 或 "₩1,234"
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = currency.decimalDigits
        formatter.maximumFractionDigits = currency.decimalDigits
        formatter.groupingSeparator = ","

        let numberString = formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
        return "\(currency.symbol)\(numberString)"
    }
}
