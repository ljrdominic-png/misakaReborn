//
//  Editeasily.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/03/14.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct Tweak_Settings_Tweaks: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    @Binding var Tweaks: [[String: Any]]
    @Binding var IsError: Bool

    var body: some View {
        ForEach(Tweaks.indices, id: \.self) { Tweaks_index in
            if var Option = Tweaks[Tweaks_index] as? [String: Any],
               let Option_Type = Option["Type"] as? String,
               let Option_Identifier = Option["Identifier"] as? String {
                
                if Option["Disabled"] as? Bool != true && Option["Hide"] as? Bool != true {
                    if Option_Type == "Color_Hex" {
                        if let Option_Value = Option["Value"] as? String {
                            HStack {
                                if let Option_Label = Option["Label"] as? String {
                                    Text(Option_Label)
                                }
                                Color_Picker_Hex(Option_Value: Binding<String>(
                                    get: {
                                        Option_Value
                                    },
                                    set: { newValue in
                                        Option["Value"] = newValue
                                        Tweaks[Tweaks_index] = Option
                                        Write.toggle()
                                    }
                                ), Option_Param: Option["Param"] as? [String: Any] ?? [String: Any]())
                            }
                        }
                    }
                    if Option_Type == "Color_Tinting" {
                        if let Option_Value = Option["Value"] as? [String: Any] {
                            HStack {
                                if let Option_Label = Option["Label"] as? String {
                                    Text(Option_Label)
                                }
                                Color_Picker_Tinting(Option_Value: Binding<[String: Any]>(
                                    get: {
                                        Option_Value
                                    },
                                    set: { newValue in
                                        Option["Value"] = newValue
                                        Tweaks[Tweaks_index] = Option
                                        Write.toggle()
                                    }
                                ))
                            }
                        }
                    }
                    if Option_Type == "Color_Matrix" {
                        if var Option_Value = Option["Value"] as? [String: Any] {
                            HStack {
                                if let Option_Label = Option["Label"] as? String {
                                    Text(Option_Label)
                                }
                                Color_Picker_Matrix(Option_Value: Binding<[String: Any]>(
                                    get: {
                                        Option_Value
                                    },
                                    set: { newValue in
                                        Option["Value"] = newValue
                                        Tweaks[Tweaks_index] = Option
                                        Write.toggle()
                                    }
                                ))
                            }
                        }
                    }
                    else if Option_Type == "Double" {
                        Double_Input_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ))
                    }
                    else if Option_Type == "Int" {
                        Int_Input_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ))
                    }
                    else if Option_Type == "Bool" {
                        if var Option_Value = Option["Value"] as? Bool {
                            Toggle(isOn: Binding<Bool>(
                                get: { Option_Value },
                                set: { newValue in
                                    withAnimation(.linear(duration: 1)) {
                                        Option["Value"] = newValue
                                        Tweaks[Tweaks_index] = Option
                                        Write.toggle()
                                    }
                                }
                            )) {
                                if let Option_Label = Option["Label"] as? String {
                                    Text(Option_Label)
                                }
                            }
                        }
                    }
                    else if Option_Type == "String" {
                        String_Input_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ))
                    }
                }
            }else if var Option = Tweaks[Tweaks_index] as? [String: Any],
                     var Option_UI = Option["UI"] as? String,
                     var Option_URL = Option["URL"] as? String {
                if Option["Disabled"] as? Bool != true && Option["Hide"] as? Bool != true  {
                    if Option_UI == "Link" {
                        Button(Option["Label"] as? String ?? "") {
                            if let url = URL(string: Option_URL) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    else if Option_UI == "ImagePicker" {
                        ImagePicker(Option_Label: Option["Label"] as? String ?? "", Option_URL: Option_URL, Option_Param: Option["Param"] as? [String: Any] ?? [:])
                    }
                    else if Option_UI == "FilePicker" {
                        FilePicker_m(Option_Label: Option["Label"] as? String ?? "", Option_URL: Option_URL)
                    }
                    else if var Option_Width = Option["Width"] as? Double,
                            var Option_Height = Option["Height"] as? Double {
                        if Option_UI == "Image" {
                            WebImage(url: URL(string: Option_URL))
                                .resizable()
                                .frame(width: Option_Width == 0 ? nil : Option_Width, height: Option_Height == 0 ? nil : Option_Height)
                                .scaledToFit()
                        }
                    }
                }
            }else if var Option = Tweaks[Tweaks_index] as? [String: Any],
                     var Option_UI = Option["UI"] as? String{
                if Option["Disabled"] as? Bool != true && Option["Hide"] as? Bool != true  {
                    if Option_UI == "Text" {
                        if let Option_Label = Option["Label"] as? String {
                            Text(Option_Label)
                        }
                    }
                    else if Option_UI == "xpc_crasher" {
                        if let Option_Process = Option["Process"] as? String {
                            Button(Option["Label"] as? String ?? "") {
                                let service_name = Option_Process
                                var cString = service_name.cString(using: .utf8)!
                                cString.withUnsafeMutableBytes { ptr in
//                                    xpc_crasher(ptr.baseAddress!)
                                }
                            }
                        }
                    }
                    else if Option_UI == "NavigationLink" {
                        if let Categories = Option["Categories"] as? [[String: Any]] {
                            NavigationLink {
                                Tweak_Settings(Main_Categories: Binding<[[String: Any]]>(
                                    get: {
                                        Main_Categories
                                    },
                                    set: { newValue in
                                        Main_Categories = newValue
                                        Write.toggle()
                                    }
                                ), Categories: Binding<[[String: Any]]>(
                                    get: {
                                        Categories
                                    },
                                    set: { newValue in
                                        Option["Categories"] = newValue
                                        Tweaks[Tweaks_index] = Option
                                        Write.toggle()
                                    }
                                ), Write: $Write, Title: Option["Label"] as? String ?? "", IsError: $IsError)
                            } label: {
                                if let Option_Label = Option["Label"] as? String {
                                    Text(Option_Label)
                                }
                            }
                        }
                    }
                    else if Option_UI == "Enabler_Toggle" {
                        Enabler_Toggle_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ), Main_Categories: $Main_Categories, Categories: $Categories, Write: $Write)
                    }
                    else if Option_UI == "Disabler_Toggle" {
                        Disabler_Toggle_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ), Main_Categories: $Main_Categories, Categories: $Categories, Write: $Write)
                    }
                    else if Option_UI == "Disabler_Selection" {
                        Disabler_Selection_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ), Main_Categories: $Main_Categories, Categories: $Categories, Write: $Write)
                    }
                    else if Option_UI == "Hider_Toggle" {
                        Hider_Toggle_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ), Main_Categories: $Main_Categories, Categories: $Categories, Write: $Write)
                    }
                    else if Option_UI == "Hider_Selection" {
                        Hider_Selection_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ), Main_Categories: $Main_Categories, Categories: $Categories, Write: $Write)
                    }
                    else if Option_UI == "Preset" {
                        Preset_Bridge(Option: Binding<[String: Any]>(
                            get: {
                                Option
                            },
                            set: { newValue in
                                Tweaks[Tweaks_index] = newValue
                                Write.toggle()
                            }
                        ), Main_Categories: $Main_Categories, Categories: $Categories, Write: $Write)
                    }
                }
            }
        }
    }
}
