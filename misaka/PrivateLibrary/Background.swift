//
//  Background.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI
import Colorful
import FluidGradient

struct Background: View {
    @ObservedObject var CM = ColorManager.shared
    @ObservedObject var MemorySingleton = Memory.shared
    @Environment(\.colorScheme) var colorScheme
    @State var D_BG_Image: UIImage?
    @State var W_BG_Image: UIImage?
    @State var Shadow: Bool
    var body: some View {
        GeometryReader { geometry in
            if colorScheme == .dark {
                if CM.D_BG_Type == "Image" {
                    if let D_BG_Image = D_BG_Image {
                        if Shadow {
                            Image(uiImage: D_BG_Image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.6)
                        }else{
                            Image(uiImage: D_BG_Image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                }else if CM.D_BG_Type == "Gradient" {
                    if MemorySingleton.ShowViewFB {
                        //                    FluidGradient(blobs: [.accentColor],
                        //                                  highlights: [.purple, .purple, .purple, .purple],
                        //                                  speed: 0.25,
                        //                                  blur: 0)
                        //                    .background(VStack{Color.blue})
                        //                    .blur(radius: 100)
                        //                    .opacity(0.2)
                        ColorfulView(uiColors: [.purple, .blue])
                            .opacity(Shadow ? 0.3 : 1)
                    }
                }
            }else{
                if CM.W_BG_Type == "Image" {
                    if let W_BG_Image = W_BG_Image {
                        if Shadow {
                            Image(uiImage: W_BG_Image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.6)
                        }else{
                            Image(uiImage: W_BG_Image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                }else if CM.W_BG_Type == "Gradient" {
                    if MemorySingleton.ShowViewFB {
                        FluidGradient(blobs: [.accentColor],
                                      highlights: [.blue, .blue, .blue, .purple],
                                      speed: 0.25,
                                      blur: 0)
                        .background(VStack{Color.blue})
                        .blur(radius: 100)
                        .opacity(0.02)
                        //                    ColorfulView()
                        //                        .opacity(0.2)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .blur(radius: CM.D_BG_Blur)
        .onAppear{
            let D_BG_Path = "\(DataPath("Settings/Wallpaper"))/Dark.png"
            let W_BG_Path = "\(DataPath("Settings/Wallpaper"))/Light.png"
            if let data = FileManager.default.contents(atPath: D_BG_Path) {
                D_BG_Image = UIImage(data: data)
            }
            if let data = FileManager.default.contents(atPath: W_BG_Path) {
                W_BG_Image = UIImage(data: data)
            }
        }
    }
}
