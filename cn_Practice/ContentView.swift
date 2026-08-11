//
//  ContentView.swift
//  cn_Practice
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            await testFetchAssets()
        }
    }

    func testFetchAssets() async {
        let repository = MockAssetRepository()
        do {
            let assets = try await repository.fetchAssets()
            for asset in assets {
                print("\(asset.symbol) - \(asset.name): \(asset.price.formatted)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
