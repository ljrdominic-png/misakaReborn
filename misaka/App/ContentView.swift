//
//  ContentView.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var memory = Memory.shared
    @ObservedObject private var smooth = SmoothSheetController.shared

    init() {
        UITabBar.appearance().backgroundColor = .systemBackground
    }

    var body: some View {
        let selectedTab = Binding<Int>(
            get: { memory.TabSelection },
            set: {
                memory.TabSelection = $0
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        )
        ZStack(alignment: .bottom) {
            TabView(selection: selectedTab) {
                TabButton(
                    index: 0,
                    title: "Featured",
                    symbol: "star.fill",
                    view: { Featured() }
                )
                TabButton(
                    index: 1,
                    title: "News",
                    symbol: "newspaper.fill",
                    view: { NEWs() }
                )
                TabButton(
                    index: 2,
                    title: "Sources",
                    symbol: "globe.americas.fill",
                    view: { Sources() }
                )
                TabButton(
                    index: 3,
                    title: packagesTabTitle,
                    symbol: "shippingbox",
                    view: { Packages() }
                )
            }
            .padding(.bottom, smooth.TabOffset)

            SmoothSheet()
        }
    }

    private var packagesTabTitle: String {
        let exploit = SettingsManager.shared.Exploit
        if SettingsManager.shared.ExploitInfo[exploit] == "Sandboxed" { return "Packages (Emu/var)" }
        if SettingsManager.shared.NoVar { return "Packages (Emu/var)" }
        return "Packages"
    }
}

struct TabButton<Content: View>: View {
    var index: Int
    var title: String
    var symbol: String
    var view: () -> Content

    init(
        index: Int,
        title: String,
        symbol: String,
        @ViewBuilder view: @escaping () -> Content
    ) {
        self.index = index
        self.title = title
        self.symbol = symbol
        self.view = view
    }

    @ObservedObject private var memory = Memory.shared
    @ObservedObject private var smooth = SmoothSheetController.shared

    var body: some View {
        Group {
            if memory.TabSelection != index {
                Color.clear
            } else {
                NavigationView {
                    ZStack {
                        Background(Shadow: false)
                        view()
                            .navigationTitle(MILocalizedString(title))
                    }
                }
                .navigationViewStyle(.stack)
                .padding(.bottom, smooth.ShowBar ? 63 : 0)
            }
        }
        .tabItem {
            Image(systemName: symbol)
            Text(MILocalizedString(title))
        }
        .tag(index)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
