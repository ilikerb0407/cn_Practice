//
//  Asset.swift
//  cn_Practice
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import Foundation

struct Asset: Identifiable {
    let id: UUID = UUID()
    let symbol: String        // 例如 "AAPL", "005930" (三星), "7203" (Toyota)
    let name: String          // 例如 "Apple Inc.", "Samsung Electronics"
    let market: Market
    let price: CurrencyAmount
}

enum Market: String, CaseIterable {
    case us = "US"
    case kr = "KR"
    case jp = "JP"

    var currency: Currency {
        switch self {
        case .us: return .usd
        case .kr: return .krw
        case .jp: return .jpy
        }
    }
}
