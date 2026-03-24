//
//  AppLang.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/07/07.
//

import SwiftUI

struct Localization_Item_ST: Codable, Hashable {
    var code: String?
    var version: Double?
    var url: String?
}
struct Localization_ST: Codable, Hashable {
    var Localization: [Localization_Item_ST]?
}

struct AppLangsSelecter: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var MemorySingleton = Memory.shared
    @State var selected: String = "en (Bundle)"
    @State var lang: [Localization_Item_ST] = [Localization_Item_ST]()
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            List {
                Section(header: Text("misaka")) {
                    Button(action: {
                        SettingsManager.shared.AppLang = "en (Bundle)"
                        SettingsManager.shared.LocalizationVersion = 1.0
                        terminateApp()
                    }) {
                        HStack{
                            VStack {
                                HStack {
                                    Text(MILocalizedString("en (Bundle)"))
                                    Spacer()
                                }
                                if MILocalizedString("en (Bundle)") != "en (Bundle)" {
                                    HStack {
                                        Text("en (Bundle)")
                                            .foregroundColor(.secondary)
                                            .font(.footnote)
                                        Spacer()
                                    }
                                }
                            }
                            Spacer()
                            if "en (Bundle)" == SettingsManager.shared.AppLang {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    ForEach(lang.indices, id: \.self) { index in
                        if let code = lang[index].code,
                           let url = lang[index].url,
                           let version = lang[index].version {
                            Button(action: {
                                Requests(RequestsType(Method: "Get", URL: url)) { data in
                                    if let data = data {
                                        let Localization = "\(DataPath("Settings"))/Localization"
                                        do {
                                            try? FileManager.default.createDirectory(atPath: Localization, withIntermediateDirectories: true, attributes: nil)
                                            try? FileManager.default.removeItem(atPath: "\(Localization)/\(code)")
                                            try data.write(to: URLwithEncode(string: "\(Localization)/\(code)")!)
                                            DispatchQueue.main.sync {
                                                SettingsManager.shared.AppLang = code
                                                SettingsManager.shared.LocalizationVersion = version
                                                ViewMemory.shared.AppLoading = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    RemoveAppCache(alert: true)
                                                    terminateApp()
                                                    DispatchQueue.main.sync {
                                                        ViewMemory.shared.AppLoading = false
                                                    }
                                                }
                                            }
                                        }catch{
                                            
                                        }
                                    }
                                }
                            }) {
                                HStack{
                                    VStack {
                                        HStack {
                                            Text(MILocalizedString(code))
                                            Spacer()
                                        }
                                        if MILocalizedString(code) != code {
                                            HStack {
                                                Text(code)
                                                    .foregroundColor(.secondary)
                                                    .font(.footnote)
                                                Spacer()
                                            }
                                        }
                                    }
                                    Spacer()
                                    if code == SettingsManager.shared.AppLang {
                                        if version != SettingsManager.shared.LocalizationVersion {
                                            Text(MILocalizedString("Update Available"))
                                        }
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    if lang == [Localization_Item_ST]() {
                        ProgressView()
                            .onAppear{
                                Requests(RequestsType(Method: "Get", URL: "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Localization/Data.json")) { data in
                                    do {
                                        if let data = data {
                                            let decoder = JSONDecoder()
                                            decoder.allowsJSON5 = true
                                            let json = try decoder.decode(Localization_ST.self, from: data)
                                            lang = json.Localization ?? [Localization_Item_ST]()
                                        }
                                    }catch{}
                                }
                            }
                    }
                }
            }
            .navigationBarTitle(MILocalizedString("App Language"))
            .listStyle(SidebarListStyle())
            .overlay(
                AppLoadingView()
            )
        }
    }
}
