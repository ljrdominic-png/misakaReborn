//
//  SettingsView.swift
//  FileSwitcherPro
//
//  Created by leminlimez & straight-tamago★ on 2023/01/22.
//

import Foundation
import SwiftUI
import CoreLocation
import SwiftUIGIF
import FilePicker

enum SettingsOptionType {
    case toggle
    case dropdown
}
struct SettingsOption: Identifiable {
    var id = UUID()
    var key: String
    var title: String
    var type: SettingsOptionType
    var toggle_value: Bool = false
    var dropdown_value: String = ""
    var dropdown_list: [String] = []
    
    init(key: String, title: String, value: Bool = false) {
        self.key = key
        self.title = title
        self.type = .toggle
        self.toggle_value = value
    }
    
    init(key: String, title: String, value: String? = nil, dropdown_list: [String]) {
        self.key = key
        self.title = title
        self.type = .dropdown
        self.dropdown_value = value ?? dropdown_list.first!
        self.dropdown_list = dropdown_list
    }
}

struct SettingsView: View {
    @ObservedObject var CM = ColorManager.shared
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var SM = SettingsManager.shared
    @Environment(\.colorScheme) var colorScheme
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    @State private var selectedIndex = 0
    @State private var RespringTypeActionSheet = false
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
                List {
                    Group {
                        if selectedIndex == 0 {
                            Section(header: Text("misaka v\(version)")) {
                                //                        Button(MILocalizedString("Check Updates")) {
                                //                            DataRequest(url: "https://api.github.com/repos/straight-tamago/misaka/releases/latest") { data in
                                //                                if let data = data {
                                //                                    do {
                                //                                        let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
                                //                                        guard let latast_v = object["tag_name"] else { return }
                                //                                        if version != latast_v as! String {
                                //                                            UIApplication.shared.confirmAlert(title: MILocalizedString("Update Available"), body: MILocalizedString("Do you want to download the update from GitHub?"), onOK: {
                                //                                                if let url = URL(string: "https://github.com/straight-tamago/misaka/releases") {
                                //                                                    UIApplication.shared.open(url)
                                //                                                }
                                //                                            }, noCancel: false)
                                //                                        }else{
                                //                                            UIApplication.shared.confirmAlert(title: MILocalizedString("Check Updates"), body: MILocalizedString("No Update found"), onOK: {
                                //                                            }, noCancel: true)
                                //                                        }
                                //                                    } catch {
                                //                                        print(error)
                                //                                    }
                                //                                }
                                //                            }
                                //                        }
                                //                        .opacity(0.9)
                                
                                //                        Button(MILocalizedString("misaka (Github)")) {
                                //                            if let url = URL(string: "https://github.com/straight-tamago/misaka") {
                                //                                UIApplication.shared.open(url)
                                //                            }
                                //                        }
                                //                        .opacity(0.9)
                                //
                                NavigationLink {
                                    Discord()
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text(MILocalizedString("misaka (Discord Support)"))
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                }
                                .opacity(0.9)
                                .foregroundColor(.primary)
                            }
                            
                            Section(header: Label(MILocalizedString("Device"), systemImage: "gear")) {
                                Group {
                                    Picker(selection: $SM.SpringLang, label: Text(MILocalizedString("Device Language"))) {
                                        ForEach(0 ..< SM.SpringLang_Selection.count, id: \.self) {
                                            Text(MILocalizedString(SM.SpringLang_Selection[$0])).tag(SM.SpringLang_Selection[$0])
                                        }
                                        .onChange(of: SM.SpringLang_Selection, perform: { newvalue in
                                            UserDefaults.standard.set(newvalue, forKey: "Device_Language")
                                        })
                                    }
                                    Button(action: {
                                        RespringTypeActionSheet = true
                                    }) {
                                        HStack {
                                            Text(MILocalizedString("Respring Type"))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Text(MILocalizedString(SM.RespringType))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .actionSheet(isPresented: $RespringTypeActionSheet) {
                                        return ActionSheet(title: Text(MILocalizedString("Respring Type")), buttons:
                                                            ((SM.RespringType_Selection.map { option in
                                            ActionSheet.Button.default(Text(option)) {
                                                SM.RespringType = option
                                            }
                                        }))
                                           + [ActionSheet.Button.cancel()]
                                        )
                                    }
                                    Toggle(isOn: $SM.ShortcutApp) {
                                        HStack {
                                            Text(MILocalizedString("Use ShortcutApp"))
                                            Spacer()
                                            Text(SM.ShortcutApp ? MILocalizedString("ON"): MILocalizedString("OFF"))
                                                .foregroundColor(.secondary)
                                        }
                                    }
//                                    Toggle(isOn: $SM.LogStream) {
//                                        HStack {
//                                            Text(MILocalizedString("Log Stream"))
//                                            Spacer()
//                                            Text(SM.LogStream ? MILocalizedString("ON"): MILocalizedString("OFF"))
//                                                .foregroundColor(.secondary)
//                                        }
//                                    }
                                }
                            }
                            
                            Section(header: Label(MILocalizedString("App"), systemImage: "gear")) {
                                Group {
                                    NavigationLink {
                                        AppLangsSelecter()
                                    } label: {
                                        HStack {
                                            Text(MILocalizedString("App Language"))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Text(MILocalizedString(SM.AppLang))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .opacity(0.9)
                                    NavigationLink {
                                        AppIconSelecter()
                                    } label: {
                                        Text(MILocalizedString("App Icons"))
                                    }
                                    .opacity(0.9)
                                    NavigationLink {
                                        OtherConfiguration()
                                    } label: {
                                        Text(MILocalizedString("Other Configuration"))
                                    }
                                    .opacity(0.9)
                                }
                            }
                            
                            Section(header: Label(MILocalizedString("Exploit"), systemImage: "gear")) {
                                HStack {
                                    Text(MILocalizedString("Method"))
                                    Spacer()
                                    Text("DarkSword").foregroundColor(.secondary)
                                }
                            }
                            
                            
                            
                            
                            Section(header: Label(MILocalizedString("Background Execution (Effective after restarting app)"), systemImage: "gear")) {
                                Toggle(isOn: $SM.RuninBackground) {
                                    HStack {
                                        Text(MILocalizedString("Run in Background"))
                                        Spacer()
                                        Text(SM.RuninBackground ? MILocalizedString("ON"): MILocalizedString("OFF"))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .onChange(of: SM.RuninBackground, perform: { newvalue in
                                    if newvalue {
                                        CLLocationManager().requestWhenInUseAuthorization()
                                        CLLocationManager().requestAlwaysAuthorization()
                                    }
                                })
                                if SM.RuninBackground {
                                    Toggle(isOn: $SM.StatusBarIndicator) {
                                        HStack {
                                            Text(MILocalizedString("Statusbar Indicator"))
                                            Spacer()
                                            Text(SM.StatusBarIndicator ? MILocalizedString("ON"): MILocalizedString("OFF"))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Toggle(isOn: $SM.Background_Apply) {
                                        HStack {
                                            Text(MILocalizedString("Background Apply"))
                                            Spacer()
                                            Text(SM.Background_Apply ? MILocalizedString("ON"): MILocalizedString("OFF"))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .onChange(of: SM.RuninBackground, perform: { newvalue in
                                        if newvalue {
                                            CLLocationManager().requestWhenInUseAuthorization()
                                            CLLocationManager().requestAlwaysAuthorization()
                                        }
                                    })
                                    if SM.Background_Apply {
                                        HStack {
                                            Text("\(MILocalizedString("Interval (sec)")) \(String(ceil(SM.RuninBackground_Interval)))")
                                            Slider(value: $SM.RuninBackground_Interval, in: 10...500, step: 1)
                                        }
                                    }
                                }
                            }
                            
                            
                            Section(header: Label(MILocalizedString("Mode"), systemImage: "gear")) {
                                Group {
                                    Toggle(isOn: $SM.DeveloperMode) {
                                        HStack {
                                            Text(MILocalizedString("Developer Mode"))
                                            Spacer()
                                            Text(SM.DeveloperMode ? MILocalizedString("ON"): MILocalizedString("OFF"))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            
                            Credits()
                            
                            NavigationLink {
                                Licenses()
                            } label: {
                                Text(MILocalizedString("Licenses"))
                            }
                            .opacity(0.9)
                            NavigationLink {
                                PrivacyPolicy()
                            } label: {
                                Text(MILocalizedString("Privacy Policy"))
                            }
                            .opacity(0.9)
                            NavigationLink {
                                TermsOfService()
                            } label: {
                                Text(MILocalizedString("Terms of Service"))
                            }
                            .opacity(0.9)
                        }
                    }
                    .listRowBackground((colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.1)))
                }
                //            .listStyle(SidebarListStyle())
                .navigationBarTitle("Settings")
            }
        }
    }
}
