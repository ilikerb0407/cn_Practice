//
//  AssetRepository.swift
//  cn_Practice
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import Foundation

protocol AssetRepositoryProtocol {
    func fetchAssets() async throws -> [Asset]
}

struct MockAssetRepository: AssetRepositoryProtocol {
    func fetchAssets() async throws -> [Asset] {
        // 模擬網路延遲(真實 API 呼叫的感覺)
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 秒

        return [
            Asset(symbol: "AAPL", name: "Apple Inc.", market: .us,
                  price: CurrencyAmount(value: 227.52, currency: .usd)),
            Asset(symbol: "005930", name: "Samsung Electronics", market: .kr,
                  price: CurrencyAmount(value: 71300, currency: .krw)),
            Asset(symbol: "7203", name: "Toyota Motor", market: .jp,
                  price: CurrencyAmount(value: 2891, currency: .jpy))
        ]
    }
}

struct FailingAssetRepository: AssetRepositoryProtocol {
    func fetchAssets() async throws -> [Asset] {
        throw URLError(.notConnectedToInternet)
    }
}
