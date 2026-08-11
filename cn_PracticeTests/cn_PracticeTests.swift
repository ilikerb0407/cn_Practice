//
//  cn_PracticeTests.swift
//  cn_PracticeTests
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import Testing
@testable import cn_Practice
internal import Foundation

struct cn_PracticeTests {

    @Test func mockRepositoryReturnsThreeAssets() async throws {
        let repository = MockAssetRepository()
        let assets = try await repository.fetchAssets()
        #expect(assets.count == 3)
    }

    @Test func jpyHasNoDecimalPlaces() {
        let amount = CurrencyAmount(value: 2891.5, currency: .jpy)
        #expect(amount.formatted == "¥2,892")
    }

    @Test func usdHasTwoDecimalPlaces() {
        let amount = CurrencyAmount(value: 227.5, currency: .usd)
        #expect(amount.formatted == "$227.50")
    }
    
    @Test func finnhubQuoteDecoding() throws {
        let json = """
        {"c":227.52,"d":-1.0,"dp":-0.44,"h":230,"l":226,"o":228,"pc":228.52,"t":1678886400}
        """.data(using: .utf8)!
        let quote = try JSONDecoder().decode(FinnhubQuote.self, from: json)
        #expect(quote.currentPrice == 227.52)
    }

    @Test func hybridRepositoryRequiresAPIKey() async {
        let repository = HybridAssetRepository()
        await #expect(throws: AssetRepositoryError.self) {
            try await repository.fetchAssets()
        }
    }

    @Test func failingRepositoryThrowsError() async {
        let repository = FailingAssetRepository()

        await #expect(throws: URLError.self) {
            try await repository.fetchAssets()
        }
    }
}
