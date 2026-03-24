//
//  GenshinPasscode.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/09.
//

import Foundation
import SwiftUI

//struct GenshinPasscode: View {
//    @Environment(\.colorScheme) var colorScheme
//    @ObservedObject var MemorySingleton = Memory.shared
//    var body: some View {
//        ZStack {
//            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
//            Button(MILocalizedString(SettingsManager.shared.TelephonyUI == "" ? "Select TelephonyUI in settings first" : SettingsManager.shared.TelephonyUI)) {
//                let result = KFD_Passcode(Bundle.main.resourceURL!.path+"/Assets/Passcode/Genshin", "/var/mobile/Library/Caches/"+SettingsManager.shared.TelephonyUI)
//                if result == UInt64(0) {
//                    UIApplication.shared.alert(title: MILocalizedString("Genshin Passcode"), body: MILocalizedString("Succeed"))
//                }else{
//                    UIApplication.shared.alert(title: MILocalizedString("Genshin Passcode"), body: MILocalizedString("Please reboot and try again"))
//                }
//            }
//            .disabled(MemorySingleton.kfd == 0 || SettingsManager.shared.TelephonyUI == "")
//            .padding()
//            .navigationBarTitle(MILocalizedString("Genshin Passcode"))
//        }
//    }
//}
