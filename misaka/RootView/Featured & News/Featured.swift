//
//  Featured.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI

struct FeaturedType: Codable {
    var Header: [RepositoryContentSimpleType]?
    var Popular: [RepositoryContentSimpleType]?
}

struct Featured: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @State var Featured: FeaturedType = FeaturedType()
    @State var First = true
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                Group {
                    // Header Tweaks
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if let data = Featured.Header {
                                if data.count != 0 {
                                    ForEach(data, id: \.self) { d in
                                        FN_ContentView(RepositoryContentSimple: d, DisplayType: "Header")
                                    }
                                }
                            }else{
                                ForEach (0..<10) { _ in
                                    FN_ContentView(DisplayType: "Header")
                                        .redacted(reason: .placeholder)
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical)
                        .padding(.leading, 12)
                    }
                }
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 8)
                
                Group {
                    // Popular Text
                    HStack {
                        Text(MILocalizedString("Popular"))
                            .font(.system(size: 30, weight: .bold, design: .default))
                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 22)
                    
                    // Popular Tweaks
                    Section {
                        if let data = Featured.Popular {
                            if data.count != 0 {
                                ForEach(data, id: \.self) { d in
                                    FN_ContentView(RepositoryContentSimple: d, DisplayType: "Popular")
                                }
                            }
                        }else{
                            ForEach (0..<10) { _ in
                                FN_ContentView(DisplayType: "Popular")
                                    .redacted(reason: .placeholder)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.horizontal, 22)
                    .padding(.leading, 7)
                    
                    // App Info
                    Section {
                        HStack {
                            Spacer()
                            VStack(alignment: .center) {
                                Text("misaka")
                                    .bold()
                                    .font(Font.system(size: 20))
                                Text("\(MILocalizedString("Version")) \(Bundle.main.releaseVersionNumber!), \(MILocalizedString("build")) \(Bundle.main.buildVersionNumber!)")
                                    .font(Font.system(size: 13))
                                    .opacity(0.5)
                            }
                            Spacer()
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                }
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 8)
            }
            .onAppear {
                if Featured.Header == nil && Featured.Popular == nil {
                    withAnimation(.linear(duration: 0.1)) {
                        Load()
                    }
                }
                First = false
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    HStack{
                        TBModule(ModuleName: "Settings")
                    }
                }
            }
        }
    }
    
    private func Load() {
        Featured = FeaturedType()
        Requests(RequestsType(Method: "Get", URL: "https://github.com/shimajiron/Misaka_Network/raw/main/Server/FeaturedDS.json")) { data in
            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.allowsJSON5 = true
                    Featured = try decoder.decode(FeaturedType.self, from: data)
                }
            }catch{}
        }
    }
}
