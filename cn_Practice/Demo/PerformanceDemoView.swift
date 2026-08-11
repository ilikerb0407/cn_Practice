//
//  PerformanceDemoView.swift
//  cn_Practice
//
//  Created by Kai Fu Jhuang on 2026/8/11.
//

import SwiftUI
import Combine

@MainActor
final class TickerViewModel: ObservableObject {
    @Published var prices: [String: Decimal] = [
        "AAPL": 227.52,
        "005930": 71300,
        "7203": 2891
    ]

    private var timer: Timer?

    func startTicking() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func stopTicking() {
        timer?.invalidate()
    }

    private func tick() {
        guard let randomKey = prices.keys.randomElement() else { return }
        let change = Decimal(Double.random(in: -0.5...0.5))
        prices[randomKey, default: 0] += change
    }
}

final class SilentCounter {
    var count = 0
}

// MARK: - 爛版本:整個大 View 直接吃 @Published,任何一筆變動都全部重繪
struct BadTickerView: View {
    @StateObject private var viewModel = TickerViewModel()
    private let counter = SilentCounter()
    @State private var finalCount: Int? = nil

    var body: some View {
        VStack {
            if let finalCount {
                Text("10秒內共重繪 \(finalCount) 次")
                    .font(.headline)
            } else {
                Text("測試中...")
                    .font(.headline)
            }

            ForEach(Array(viewModel.prices.keys.sorted()), id: \.self) { key in
                let _ = counter.count += 1
                HStack {
                    Text(key)
                    Spacer()
                    Text("\(viewModel.prices[key] ?? 0)")
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startTicking()
            Task {
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                viewModel.stopTicking()
                finalCount = counter.count
                print("=== Bad版本 10秒內共重繪 \(counter.count) 次 ===")
            }
        }
    }
}

// MARK: - 好版本:每一行拆成獨立元件,只有自己的數字變動時才重繪自己

struct GoodTickerView: View {
    @StateObject private var viewModel = TickerViewModel()
    private let counter = SilentCounter()
    @State private var hasFinished = false

    var body: some View {
        VStack {
            Text(hasFinished ? "10秒內共重繪 \(counter.count) 次" : "測試中... \(counter.count)")
                .font(.headline)

            ForEach(Array(viewModel.prices.keys.sorted()), id: \.self) { key in
                TickerRow(symbol: key, price: viewModel.prices[key] ?? 0, counter: counter)
                    .equatable()
            }
        }
        .onAppear {
            viewModel.startTicking()
            Task {
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                viewModel.stopTicking()
                hasFinished = true
                print("=== Good版本 10秒內共重繪 \(counter.count) 次 ===")
            }
        }
    }
}

private struct TickerRow: View, Equatable {
    let symbol: String
    let price: Decimal
    let counter: SilentCounter

    static func == (lhs: TickerRow, rhs: TickerRow) -> Bool {
        lhs.symbol == rhs.symbol && lhs.price == rhs.price
    }

    var body: some View {
        DispatchQueue.main.async {
            counter.count += 1
        }
        return HStack {
            Text(symbol)
            Spacer()
            Text("\(price)")
        }
        .padding()
    }
}

#Preview {
//    GoodTickerView()
//    BadTickerView()
}
