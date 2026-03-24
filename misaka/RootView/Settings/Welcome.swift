//
//  ChangeLog.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/10/13.
//

import Foundation
import SwiftUI
import WebKit

struct Welcome: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @Environment(\.colorScheme) var colorScheme
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Text("Welcome to Misaka v"+version.replacingOccurrences(of: " Beta", with: ""))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Spacer()
                    
                    VStack(spacing: 24) {
                        FeatureCell(image: "paperplane", title: "DarkSword", subtitle: "Sandboxed tweaks", color: .blue)
                        FeatureCell(image: "person.2", title: "Get Support", subtitle: "You can join our discord server now to start a discussion", color: .blue)
                        FeatureCell(image: "calendar", title: "Next update coming soon", subtitle: "We are preparing to support other development languages.", color: .red)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    Spacer()
                    NavigationLink {
                        Discord()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding()
                .padding()
                .padding()
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
            }
        }
    }
}
struct Discord: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var MemorySingleton = Memory.shared
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Discord Support")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.horizontal)
                Spacer()
                
                VStack {
                    HTML()
                }
                
                Spacer()
                Spacer()
                
                if MemorySingleton.Welcome_IsActive {
                    Button(action: {
                        MemorySingleton.Welcome_IsActive = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .padding()
                    .padding()
                }
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .onAppear {
                UIApplication.shared.confirmAlert(title: MILocalizedString("Donation"), body: MILocalizedString("This project is completely free and always will be.❤️"), onOK: {
                    if let url = URL(string: "https://www.paypal.com/paypalme/nnn288") {
                        UIApplication.shared.open(url, options: [.universalLinksOnly: false], completionHandler: { completed in
                            print(completed)
                        })
                    }
                }, noCancel: false, YesText: "Paypal", NoText: "Close")
            }
        }
    }
}

struct HTMLView: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
        uiView.isOpaque = false
        uiView.backgroundColor = UIColor.clear
        uiView.scrollView.backgroundColor = UIColor.clear
    }
}

struct HTML: View {
    var body: some View {
        VStack {
            HTMLView(htmlString:
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Document</title>
        </head>
        <body>
            <iframe src="https://discord.com/widget?id=1156843198799421490&theme=dark" width="100%" height="300" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>
        <iframe src="https://discord.com/widget?id=1074625970029477919&theme=dark" width="100%" height="300" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>
        </body>
        </html>
        """)
        }
        .padding()
    }
}


struct FeatureCell: View {
    var image: String
    var title: String
    var subtitle: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 24) {
            Image(systemName: image)
            //                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}
