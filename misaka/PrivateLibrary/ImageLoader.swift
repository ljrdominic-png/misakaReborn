//
//  ImageLoader.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUIGIF


    

@ViewBuilder
func ImageLoader(_ url: String, loadingAnim: Bool = false) -> some View {
    if url == "" {
        WebImage(url: URL(string: url))
            .resizable()
    }else{
        if url.contains(".gif") {
            WebImage(url: URL(string: url))
                .resizable()
                .placeholder {
                    Color.gray.opacity(0.4)
                }
                .indicator(.activity)
        }else{
            WebImage(url: URL(string: url))
                .resizable()
                .placeholder {
                    if loadingAnim {
                        WebImage(url: URL(string: "https://github.com/shimajiron/Misaka_Network/blob/main/Server/Assets/loading.gif?raw=true"))
                            .resizable()
                    }else {
                        Color.gray.opacity(0.4)
                    }
                }
                .indicator(.activity)
            .transition(.opacity)
            .animation(.easeIn(duration: 0.3))
        }
    }
}
