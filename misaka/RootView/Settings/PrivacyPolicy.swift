//
//  PrivacyPolicy.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/07/07.
//

import SwiftUI

struct PrivacyPolicy: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var agreed = false
    @State private var License = ""
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading) {
                    Text(License)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .padding()
            .navigationTitle(MILocalizedString("Privacy Policy"))
            .onAppear{
                Requests(RequestsType(Method: "Get", URL: "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/PrivacyPolicy")) { data in
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
