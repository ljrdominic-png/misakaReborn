//
//  NEWs.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI

struct NewsType: Codable {
    var LastUpdate: String?
    var NewRelease: [RepositoryContentSimpleType]?
}

struct NEWs: View {
    @State var News: NewsType = NewsType()
    var body: some View {
        ZStack {
            if #available(iOS 15.0, *) {
                fallbackScrollView()
            }else {
                fallbackScrollView()
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 8)
        .onAppear {
            if News.NewRelease == nil && News.LastUpdate == nil {
                withAnimation(.linear(duration: 0.1)) {
                    Load()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(News.LastUpdate ?? "...")
                    .font(Font.system(size: 15, weight: .bold))
            }
        }
    }
    private func fallbackScrollView() -> some View {
        return AnyView(
            ScrollView(.vertical, showsIndicators: false) {
                // Popular Tweaks
                Section {
                    if let data = News.NewRelease {
                        if data.count != 0 {
                            ForEach(data, id: \.self) { d in
                                FN_ContentView(RepositoryContentSimple: d, DisplayType: "Popular")
                            }
                            .padding(.vertical, 7)
                        }
                    }else{
                        ForEach (0..<10) { _ in
                            FN_ContentView(DisplayType: "Popular")
                                .redacted(reason: .placeholder)
                        }
                        .padding(.vertical, 7)
                    }
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 22)
                .padding(.leading, 7)
                .padding(.top, 10)
            }
        )
    }
    
    private func Load() {
        News = NewsType()
        Requests(RequestsType(Method: "Get", URL: "https://github.com/shimajiron/Misaka_Network/raw/main/Server/NewsDS.json")) { data in
            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.allowsJSON5 = true
                    News = try decoder.decode(NewsType.self, from: data)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
