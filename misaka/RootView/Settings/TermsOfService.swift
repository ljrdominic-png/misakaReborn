//
//  Terms_of_Service.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/07/07.
//

import SwiftUI

struct TermsOfService: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var MemorySingleton = Memory.shared
    @State private var agreed = false
    @State private var License = ""
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            ZStack {
                if UserDefaults.standard.bool(forKey: "Terms_of_Service") == false {
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading) {
                                Text(License)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                        }
                        .padding()
                        .navigationTitle(MILocalizedString("Terms of Service"))
                        if License != "" {
                            Spacer()
                            VStack {
                                Button(action: {
                                    agreed = true
                                    UserDefaults.standard.set(true, forKey: "Terms_of_Service")
                                    MemorySingleton.TermsOfService_IsActive = false
                                }) {
                                    HStack {
                                        Spacer()
                                        Text(MILocalizedString("Agree"))
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                Button(action: {
                                    agreed = false
                                    terminateApp()
                                }) {
                                    HStack {
                                        Spacer()
                                        Text(MILocalizedString("Disagree"))
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .foregroundColor(.white)
                                .background(agreed ? Color.blue : Color.red)
                                .cornerRadius(10)
                            }
                            .padding()
                            .padding(.horizontal)
                        }
                    }
                    .onDisappear{
                        if UserDefaults.standard.bool(forKey: "Terms_of_Service") == false {
                            terminateApp()
                        }else{
                            UserDefaults.standard.set(true, forKey: "AppIconSelect")
                        }
                    }
                }else{
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(License)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(MILocalizedString("Terms of Service"))
            .onAppear{
                Requests(RequestsType(Method: "Get", URL: "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/TermsOfService")) { data in
                    if let data = data {
                        License = String(data: data, encoding: .utf8) ?? ""
                    }else{
                        UIApplication.shared.alert(body: MILocalizedString("Network Error"))
                    }
                }
            }
        }
    }
}

