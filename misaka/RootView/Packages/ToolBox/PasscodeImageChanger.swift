//
//  PasscodeImageChanger.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/08.
//

import Foundation
import SwiftUI
import FilePicker

struct PasscodeImageChanger: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var ViewMemorySingleton = ViewMemory.shared
    @Environment(\.scenePhase) private var scenePhase
    @State var message: String = ""
    let rows = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", ""]
    ]
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            VStack {
                VStack(spacing: 15) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 15) {
                            ForEach(row, id: \.self) { digit in
                                if digit.isEmpty {
                                    Color.clear
                                        .frame(width: 90 ,height: 90)
                                } else {
                                    PasscodeImageChanger_ImagePicker(message: $message, digit: digit)
                                }
                            }
                        }
                    }
                }
                .padding()
                .padding()
                .padding()
                .padding()
                if message != "" { Text(message) }
                HStack {
                    Button("Apply") {
                        if SettingsManager.shared.TelephonyUI == "" {
                            UIApplication.shared.alert(title: MILocalizedString("Passcode Theme"), body: MILocalizedString("Select TelephonyUI in settings first"))
                        } else if PFaceOverwrite() {
                            UIApplication.shared.alert(title: "Succeed", body: "Applied the theme")
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            message = "Applied the theme"
                        } else {
                            UIApplication.shared.alert(title: MILocalizedString("Passcode Theme"), body: MILocalizedString("Please reboot and try again"))
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            message = "Error"
                        }
                    }
                    .padding()
                    .accentColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
                    Button("Remove All") {
                        ViewMemory.shared.AppLoading = true
                        if let fs = try? FileManager.default.contentsOfDirectory(at: URL(string: "\(DataPath("Settings"))/Passcode")!, includingPropertiesForKeys: nil) {
                            for f in fs {
                                try? FileManager.default.removeItem(at: f)
                            }
                            UIApplication.shared.alert(title: "Succeed", body: "")
                            ViewMemory.shared.AppLoading = false
                        }
                    }
                    .padding()
                    .accentColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
                    Button("Force Reboot") {
//                        Force_Reboot(Bundle.main.resourceURL!.path+"/Assets/Passcode", "/var/mobile/Library/Caches/TelephonyUI-10")
                    }
                    .padding()
                    .accentColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
                }
            }
            .navigationTitle("Passcode Theme")
            .overlay(
                Group {
                    if ViewMemorySingleton.AppLoading {
                        VStack {
                            GeometryReader { geometry in
                                ProgressView(MILocalizedString("Loading..."))
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .foregroundColor(Color.white)
                            }
                        }
                        .background(Color.black.opacity(0.8))
                        .edgesIgnoringSafeArea(.all)
                    }
                }
            )
            .onChange(of: scenePhase) { phase in
                let _ = try? FileManager.default.contentsOfDirectoryExploit(atPath: "/var/mobile/Library/Caches/TelephonyUI-9")
                let _ = try? FileManager.default.contentsOfDirectoryExploit(atPath: "/var/mobile/Library/Caches/TelephonyUI-8")
                let _ = try? FileManager.default.contentsOfDirectoryExploit(atPath: "/var/mobile/Library/Caches/TelephonyUI-7")
            }.task {
                let _ = try? FileManager.default.contentsOfDirectoryExploit(atPath: "/var/mobile/Library/Caches/TelephonyUI-9")
                let _ = try? FileManager.default.contentsOfDirectoryExploit(atPath: "/var/mobile/Library/Caches/TelephonyUI-8")
                let _ = try? FileManager.default.contentsOfDirectoryExploit(atPath: "/var/mobile/Library/Caches/TelephonyUI-7")
            }
        }
    }
}

func PFaceOverwrite() -> Bool {
    let o_files = [
        "0.png",
        "1.png",
        "2.png",
        "3.png",
        "4.png",
        "5.png",
        "6.png",
        "7.png",
        "8.png",
        "9.png",
        "0.png",
        "1.png",
        "2.png",
        "3.png",
        "4.png",
        "5.png",
        "6.png",
        "7.png",
        "8.png",
        "9.png"
    ]
    let t_files = [
        "en-0---white.png",
        "en-1---white.png",
        "en-2-A B C--white.png",
        "en-3-D E F--white.png",
        "en-4-G H I--white.png",
        "en-5-J K L--white.png",
        "en-6-M N O--white.png",
        "en-7-P Q R S--white.png",
        "en-8-T U V--white.png",
        "en-9-W X Y Z--white.png",
        "other-0---white.png",
        "other-1---white.png",
        "other-2-A B C--white.png",
        "other-3-D E F--white.png",
        "other-4-G H I--white.png",
        "other-5-J K L--white.png",
        "other-6-M N O--white.png",
        "other-7-P Q R S--white.png",
        "other-8-T U V--white.png",
        "other-9-W X Y Z--white.png",
    ]
    
    for i in 0..<t_files.count {
        let o = "\(DataPath("Settings"))/Passcode/\(o_files[i])"
        let t = "/var/mobile/Library/Caches/"+SettingsManager.shared.TelephonyUI+"/\(t_files[i])"
        if let data = FileManager.default.contentsExploit(atPath: o) {
            try? FileManager.default.writeFileExploit(atPath: t, data)
        }
    }
    return true
}

struct PasscodeImageChanger_ImagePicker: View {
    @State var showingPicker = false
    @Binding var message: String
    @State var digit: String
    @State var image: Data?
    var body: some View {
        HStack {
            Button {
                showingPicker.toggle()
            } label: {
                VStack {
                    if let image = UIImage(data: image ?? Data()) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }else{
                        Text(digit)
                    }
                }
                .font(.title)
                .frame(width: 90 ,height: 90)
                .background(Color.gray.opacity(0.2))
                .accentColor(Color.white)
                .background(Color.blue)
                .cornerRadius(50)
                .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
            }
        }
        .sheet(isPresented: $showingPicker) {
            ImagePickerView(image: $image, sourceType: .library)
        }
        .onChange(of: image) { newValue in
            guard let o = newValue else { return }
            do{
                try? FileManager.default.createDirectory(atPath: "\(DataPath("Settings"))/Passcode", withIntermediateDirectories: true, attributes: nil)
                try o.write(to: URL(fileURLWithPath: "\(DataPath("Settings"))/Passcode/\(digit).png"))
                message = "Saved"
            }catch{
                image = Data()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UIApplication.shared.alert(title: "Error", body: "Permission Denied")
                }
            }
        }
        .onAppear{
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: "\(DataPath("Settings"))/Passcode/\(digit).png")) else { return }
            image = data
        }
    }
}

