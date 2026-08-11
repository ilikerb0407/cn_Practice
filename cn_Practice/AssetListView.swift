//
//  AssetListView.swift
//  cn_Practice
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import SwiftUI

struct AssetListView: View {
    @StateObject private var viewModel = AssetListViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("我的資產")
                .task {
                    await viewModel.loadAssets()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("載入中...")

        case .loaded(let assets):
            List(assets) { asset in
                AssetRow(asset: asset)
            }

        case .error(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text(message)
                Button("重試") {
                    Task {
                        await viewModel.loadAssets()
                    }
                }
            }
        }
    }
}

private struct AssetRow: View {
    let asset: Asset

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(asset.symbol)
                    .font(.headline)
                Text(asset.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(asset.price.formatted)
                    .font(.headline)
                Text(asset.market.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AssetListView()
}
