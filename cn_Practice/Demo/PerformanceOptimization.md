## Performance Optimization: Avoiding Unnecessary Re-renders

### 問題場景
模擬即時股價跳動(每 0.05 秒更新一次,一次只有一檔股票的價格變動),
觀察 SwiftUI 在「多筆資料、部分更新」情境下的重繪行為。

### Before(BadTickerView)
整個 `prices` 字典直接綁定在 `ForEach` 上,任何一檔股價變動,
所有列都會被視為「需要重新計算」,即使該列的資料其實沒有變化。

```swift
ForEach(Array(viewModel.prices.keys.sorted()), id: \.self) { key in
    HStack {
        Text(key)
        Spacer()
        Text("\(viewModel.prices[key] ?? 0)")
    }
    .padding()
}
```

**測試結果:10 秒內共重繪 642 次**(3 檔股票 × 每次 tick 全部重繪)

### After(GoodTickerView)
1. 把每一列拆成獨立的 `TickerRow`,只依賴自己需要的 `symbol` 跟 `price`
2. 讓 `TickerRow` 遵循 `Equatable`,並在呼叫端加上 `.equatable()`,
   讓 SwiftUI 在重繪前先比較內容是否真的改變,沒變就跳過

```swift
private struct TickerRow: View, Equatable {
    let symbol: String
    let price: Decimal

    static func == (lhs: TickerRow, rhs: TickerRow) -> Bool {
        lhs.symbol == rhs.symbol && lhs.price == rhs.price
    }

    var body: some View {
        HStack {
            Text(symbol)
            Spacer()
            Text("\(price)")
        }
        .padding()
    }
}

// 呼叫端
ForEach(Array(viewModel.prices.keys.sorted()), id: \.self) { key in
    TickerRow(symbol: key, price: viewModel.prices[key] ?? 0)
        .equatable()
}
```

**測試結果:10 秒內共重繪 213 次**(只有真正變動的那一列被重繪)

### 結論
在完全相同的 10 秒測試區間、相同的資料更新頻率下,
拆分 View 並加上 `Equatable` 後,重繪次數從 642 次降至 213 次,
降幅約 **67%**,且比例(約 3:1)與資料筆數(3 檔股票)吻合,
驗證了「未拆分版本每次更新都重繪全部列、拆分後只重繪真正變動的列」這個假設。

### 測試方式
兩個版本皆使用一個獨立於 SwiftUI 狀態系統之外的計數器(非 `@Published`),
在渲染時累加、10 秒後統一讀取結果,避免計數行為本身干擾被測量的重繪次數。
