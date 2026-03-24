//
//  Tweak_Settings.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/04/17.
//

import Foundation
import SwiftUI

struct Tweak_Settings: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    @State var Title: String
    @Binding var IsError: Bool
    var body: some View {
        Group {
            if MemorySingleton.ConfigEditMode && UIDevice.current.userInterfaceIdiom == .pad || !MemorySingleton.ConfigEditMode {
                if IsError {
                    VStack {
                    GeometryReader { geometry in
                        ProgressView(MILocalizedString("Parse Error"))
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .foregroundColor(Color.white)
                        }
                    }
                    .background(Color.black.opacity(0.8))
                    .edgesIgnoringSafeArea(.all)
                }else {
                    List {
                        ForEach(Categories.indices, id: \.self) { Categories_index in
                            if Categories.count != 0 {
                                let Category = Categories[Categories_index]["Category"] as? String
                                let Description = Categories[Categories_index]["Description"] as? String
                                var Tweaks = Categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                if Tweaks.allSatisfy({ $0["Disabled"] as? Bool != false }) {
                                    
                                    if Category ?? "" != "" && Description ?? "" != ""{
                                        Section(header: Text(Category ?? ""), footer: Text(Description ?? "")) {
                                            Tweak_Settings_Tweaks(Main_Categories: $Categories, Categories: $Categories, Write: $Write, Tweaks: Binding<[[String: Any]]>(
                                                get: {
                                                    Tweaks
                                                },
                                                set: { newValue in
                                                    Categories[Categories_index]["Tweaks"] = newValue
                                                }
                                            ), IsError: $IsError)
                                        }
                                    }else if Category ?? "" != "" {
                                        Section(header: Text(Category ?? "")) {
                                            Tweak_Settings_Tweaks(Main_Categories: $Categories, Categories: $Categories, Write: $Write, Tweaks: Binding<[[String: Any]]>(
                                                get: {
                                                    Tweaks
                                                },
                                                set: { newValue in
                                                    Categories[Categories_index]["Tweaks"] = newValue
                                                }
                                            ), IsError: $IsError)
                                        }
                                    }else{
                                        Tweak_Settings_Tweaks(Main_Categories: $Categories, Categories: $Categories, Write: $Write, Tweaks: Binding<[[String: Any]]>(
                                            get: {
                                                Tweaks
                                            },
                                            set: { newValue in
                                                Categories[Categories_index]["Tweaks"] = newValue
                                            }
                                        ), IsError: $IsError)
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarTitle(Title)
                }
            }
        }
    }
}

struct Tweak_Settings_Bridge_Bridge: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @State var Categories: [[String: Any]] = [[String: Any]]()
    @State var Write = false
    @State var FirstBoot = true
    @State var timer: Timer?
    @State var IsError = false
    
    var body: some View {
        Tweak_Settings(Main_Categories: $Categories, Categories: $Categories, Write: Binding<Bool>(
            get: {
                Write
            },
            set: { newValue in
                writeToConfigPlist()
            }
        ), Title: MILocalizedString("Advanced Settings"), IsError: $IsError)
        .onAppear {
            if FirstBoot == true {
                ViewMemory.shared.AppLoading = true
                DispatchQueue.global().async { // バックグラウンドスレッドで実行する
                    let _ = Apply(PackageID: MemorySingleton.AdvancedSettings_Addon, Mode: "Restore")
                    loadconfig()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        ViewMemory.shared.AppLoading = false
                    }
                }
            }
            FirstBoot = false
            guard timer == nil else { return }
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { s in
                if SettingsManager.shared.DeveloperMode && MemorySingleton.ConfigEditMode {
                    loadconfig()
                    print("reload")
                }
            }
        }
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if !MemorySingleton.AdvancedSettings_isActive {
                    timer?.invalidate()
                }
            }
        }
    }
    func writeToConfigPlist() {
        let config_path = "\(DataPath("Packages"))/\(MemorySingleton.AdvancedSettings_Addon)/config.plist"
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: Categories, format: .xml, options: 0)
            try data.write(to: URL(fileURLWithPath: config_path))
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    func loadconfig() {
        let config_path = "\(DataPath("Packages"))/\(MemorySingleton.AdvancedSettings_Addon)/config.plist"
        if let plistData = FileManager.default.contents(atPath: config_path) {
            do {
                Categories = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [[String: Any]] ?? [[String: Any]]()
                IsError = false
            } catch {
                print("Error: \(error.localizedDescription)")
                IsError = true
            }
        }else{
            IsError = true
        }
    }
}

struct AdvancedSettings: View {
    @ObservedObject var MemorySingleton = Memory.shared
    var body: some View {
        Tweak_Settings_Bridge_Bridge()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                if SettingsManager.shared.DeveloperMode {
                    Button(action: {
                        MemorySingleton.ConfigEditMode.toggle()
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
    }
}
