//
//  AssetListViewModel.swift
//  cn_Practice
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import Foundation
import Combine

@MainActor
final class AssetListViewModel: ObservableObject {

    enum State {
        case loading
        case loaded([Asset])
        case error(String)
    }

    @Published private(set) var state: State = .loading

    private let repository: AssetRepositoryProtocol

    init(repository: AssetRepositoryProtocol = MockAssetRepository()) {
        self.repository = repository
    }

    func loadAssets() async {
        state = .loading
        do {
            let assets = try await repository.fetchAssets()
            state = .loaded(assets)
        } catch {
            state = .error("無法載入資料，請稍後再試")
        }
    }
}

