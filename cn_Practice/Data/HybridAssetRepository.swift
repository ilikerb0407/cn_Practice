//
//  HybridAssetRepository.swift
//  cn_Practice
//

import Foundation

/// AAPL 走 Finnhub 真實報價；韓日標的維持 Mock（free tier 對亞股支援有限）
struct HybridAssetRepository: AssetRepositoryProtocol {
    private let finnhubClient: FinnhubClient

    init(finnhubClient: FinnhubClient = FinnhubClient()) {
        self.finnhubClient = finnhubClient
    }

    func fetchAssets() async throws -> [Asset] {
        guard let apiKey = APIKeyProvider.finnhubKey else {
            throw AssetRepositoryError.missingAPIKey
        }

        async let aaplTask = finnhubClient.fetchQuote(symbol: "AAPL", apiKey: apiKey)

        let aaplQuote = try await aaplTask
        let aapl = Asset(
            symbol: "AAPL",
            name: "Apple Inc.",
            market: .us,
            price: CurrencyAmount(value: Decimal(aaplQuote.currentPrice), currency: .usd)
        )

        return [aapl] + MockAssetRepository.asianAssets
    }
}

enum AssetRepositoryFactory {
    static func makeDefault() -> AssetRepositoryProtocol {
        if APIKeyProvider.finnhubKey != nil {
            HybridAssetRepository()
        } else {
            MockAssetRepository()
        }
    }
}
