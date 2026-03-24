//
//  Color.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/07/07.
//

import SwiftUI

struct OtherConfiguration: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var CM = ColorManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            List {
                Group {
                    Section(header: Text(MILocalizedString("ON"))) {
                        Button(action: {}){
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    HStack {
                                        ImageLoader("https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png")
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 50)
                                            .cornerRadius(10)
                                            .padding(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 2,
                                                trailing: 5
                                            ))
                                        VStack(alignment: .leading) {
                                            Text(MILocalizedString("PackageID"))
                                                .font(.system(size: 14, weight: .bold, design: .default))
                                        }
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                            .frame(height: 70)
                            .padding(2)
                            .cornerRadius(10)
                            .BoxBackground(isSucceeded: true, colorScheme: colorScheme)
                        }
                        .overlay(
                            VStack {
                                HStack{
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 8,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 8
                                        ))
                                        .foregroundColor(colorScheme == .dark ? CM.D_Box_Other_ON : CM.W_Box_Other_ON)
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("0.0")
                                        .padding(EdgeInsets(
                                            top: 0,
                                            leading: 0,
                                            bottom: 8,
                                            trailing: 8
                                        ))
                                        .foregroundColor(colorScheme == .dark ? CM.D_Box_Other_ON : CM.W_Box_Other_ON)
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                }
                            }
                        )
                        .cornerRadius(7)
                        ColorPicker(selection: colorScheme == .dark ? $CM.D_Box_Base_ON : $CM.W_Box_Base_ON , supportsOpacity: true, label: {Text(MILocalizedString("Base"))})
                        ColorPicker(selection:  colorScheme == .dark ? $CM.D_Box_Text_ON : $CM.W_Box_Text_ON, supportsOpacity: true, label: {Text(MILocalizedString("Text"))})
                        ColorPicker(selection:  colorScheme == .dark ? $CM.D_Box_Shadow_ON : $CM.W_Box_Shadow_ON, supportsOpacity: true, label: {Text(MILocalizedString("Shadow"))})
                        ColorPicker(selection:  colorScheme == .dark ? $CM.D_Box_Other_ON : $CM.W_Box_Other_ON, supportsOpacity: true, label: {Text(MILocalizedString("Other"))})
                    }
                    
                    Section(header: Text(MILocalizedString("OFF"))) {
                        Button(action: {}){
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    HStack {
                                        ImageLoader("https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png")
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 50)
                                            .cornerRadius(10)
                                            .padding(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 2,
                                                trailing: 5
                                            ))
                                        VStack(alignment: .leading) {
                                            Text(MILocalizedString("PackageID"))
                                                .font(.system(size: 14, weight: .bold, design: .default))
                                        }
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                            .frame(height: 70)
                            .padding(2)
                            .cornerRadius(10)
                            .BoxBackground(isSucceeded: false, colorScheme: colorScheme)
                        }
                        .overlay(
                            VStack {
                                HStack{
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 8,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 8
                                        ))
                                        .foregroundColor(colorScheme == .dark ? CM.D_Box_Other_OFF : CM.W_Box_Other_OFF)
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("0.0")
                                        .padding(EdgeInsets(
                                            top: 0,
                                            leading: 0,
                                            bottom: 8,
                                            trailing: 8
                                        ))
                                        .foregroundColor(colorScheme == .dark ? CM.D_Box_Other_OFF : CM.W_Box_Other_OFF)
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                }
                            }
                        )
                        .cornerRadius(7)
                        Group {
                            ColorPicker(selection: colorScheme == .dark ? $CM.D_Box_Base_OFF : $CM.W_Box_Base_OFF , supportsOpacity: true, label: {Text(MILocalizedString("Base"))})
                            ColorPicker(selection: colorScheme == .dark ? $CM.D_Box_Text_OFF : $CM.W_Box_Text_OFF, supportsOpacity: true, label: {Text(MILocalizedString("Text"))})
                            ColorPicker(selection: colorScheme == .dark ? $CM.D_Box_Shadow_OFF : $CM.W_Box_Shadow_OFF, supportsOpacity: true, label: {Text(MILocalizedString("Shadow"))})
                            ColorPicker(selection: colorScheme == .dark ? $CM.D_Box_Other_OFF : $CM.W_Box_Other_OFF, supportsOpacity: true, label: {Text(MILocalizedString("Other"))})
                        }
                    }
                    
                    Section(header: Text(MILocalizedString("Common"))) {
                        HStack {
                            Toggle(MILocalizedString("Blur"), isOn: colorScheme == .dark ? $CM.D_Box_Blur : $CM.W_Box_Blur)
                        }
                    }
                    
                    Section(header: Text(MILocalizedString("App"))) {
                        ColorPicker(selection: colorScheme == .dark ? $CM.D_AccentColor : $CM.W_AccentColor, supportsOpacity: true, label: {Text(MILocalizedString("Accent"))})
                        Picker(MILocalizedString("Background"), selection: colorScheme == .dark ? $CM.D_BG_Type : $CM.W_BG_Type) {
                            Text(MILocalizedString("None")).tag("None")
                            Text(MILocalizedString("Gradient")).tag("Gradient")
                            Text(MILocalizedString("Image")).tag("Image")
                        }
                        .pickerStyle(.segmented)
                        HStack {
                            Text("\(MILocalizedString("Blur")) \(String(ceil(colorScheme == .dark ? CM.D_BG_Blur : CM.W_BG_Blur)))")
                            Slider(value: colorScheme == .dark ? $CM.D_BG_Blur : $CM.W_BG_Blur, in: 0...100, step: 0.1)
                        }
                        if (colorScheme == .dark ? CM.D_BG_Type : CM.W_BG_Type) == "Image" {
                            Custom_Image(Label: MILocalizedString("Select Image"))
                        }
                    }
                    
                    Picker(MILocalizedString("Appearance"), selection: $CM.appearanceMode) {
                        Text(MILocalizedString("Follow System"))
                            .tag(0)
                        Text(MILocalizedString("Dark Mode"))
                            .tag(1)
                        Text(MILocalizedString("Light Mode"))
                            .tag(2)
                    }.onChange(of: CM.appearanceMode, perform: { newvalue in
                        terminateApp()
                    })
                    .foregroundColor(.primary)
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(MILocalizedString("Other Configuration"))
        }
    }
}

struct Custom_Image: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @Environment(\.colorScheme) var colorScheme
    @State var Label: String
    @State var showingPicker = false
    @State var Pre_BG_Image: Data?
    @State var BG_Image: Data?
    var body: some View {
        HStack {
            Button(Label) {
                showingPicker.toggle()
            }
            Spacer()
            if let image = UIImage(data: BG_Image ?? Data()) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(maxHeight: 100)
        .sheet(isPresented: $showingPicker) {
            ImagePickerView(image: $BG_Image, sourceType: .library)
        }
        .onAppear{
            let D_BG_Path = URL(string: "file://\(DataPath("Settings/Wallpaper"))/Dark.png")!
            let W_BG_Path = URL(string: "file://\(DataPath("Settings/Wallpaper"))/Light.png")!
            if let data = try? Data(contentsOf: colorScheme == .dark ? D_BG_Path: W_BG_Path) {
                BG_Image = data
                Pre_BG_Image = data
            }
        }
        .onChange(of: BG_Image) { newValue in
            let D_BG_Path = URL(string: "file://\(DataPath("Settings/Wallpaper"))/Dark.png")!
            let W_BG_Path = URL(string: "file://\(DataPath("Settings/Wallpaper"))/Light.png")!
            if newValue != Pre_BG_Image {
                do {
                    try newValue?.write(to: colorScheme == .dark ? D_BG_Path : W_BG_Path)
                    terminateApp()
                }catch{
                    UIApplication.shared.alert(body: MILocalizedString("Permission Error"))
                }
            }
        }
    }
}
