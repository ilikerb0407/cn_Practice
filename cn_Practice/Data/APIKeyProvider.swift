//
//  APIKeyProvider.swift
//  cn_Practice
//

import Foundation

enum APIKeyProvider {
    static var finnhubKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["FINNHUB_API_KEY"],
           isValidKey(envKey) {
            return envKey
        }

        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let secrets = NSDictionary(contentsOfFile: path),
           let plistKey = secrets["FINNHUB_API_KEY"] as? String,
           isValidKey(plistKey) {
            return plistKey
        }

        return nil
    }

    private static func isValidKey(_ key: String) -> Bool {
        !key.isEmpty && key != "YOUR_FINNHUB_API_KEY"
    }
}
