//
//  FinnhubClient.swift
//  cn_Practice
//

import Foundation

struct FinnhubQuote: Decodable, Sendable {
    let currentPrice: Double

    enum CodingKeys: String, CodingKey {
        case currentPrice = "c"
    }
}

enum AssetRepositoryError: LocalizedError {
    case missingAPIKey
    case invalidQuote(symbol: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "請設定 Finnhub API Key（參考 Secrets.plist.example）"
        case .invalidQuote(let symbol):
            return "無法取得 \(symbol) 的報價"
        }
    }
}

struct FinnhubClient: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchQuote(symbol: String, apiKey: String) async throws -> FinnhubQuote {
        var components = URLComponents(string: "https://finnhub.io/api/v1/quote")!
        components.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "token", value: apiKey)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let quote = try JSONDecoder().decode(FinnhubQuote.self, from: data)

        guard quote.currentPrice > 0 else {
            throw AssetRepositoryError.invalidQuote(symbol: symbol)
        }

        return quote
    }
}
