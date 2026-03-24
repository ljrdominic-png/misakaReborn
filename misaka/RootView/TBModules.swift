//
//  TBModules.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/03/10.
//

import Foundation
import SwiftUI
import UIKit
import AVKit

struct TBModule: View {
    @StateObject var MemorySingleton = Memory.shared
    @State var ModuleName: String
    @State var isPresented = false
    var body: some View {
        HStack {
            if ModuleName == "Settings" {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    Memory.shared.SettingsView_IsActive = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                }
            }else if ModuleName == "ChangeLogs" {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    Memory.shared.WebsiteView_IsActive = true
                }) {
                    Image(systemName: "doc.plaintext")
                }
            }
            else if ModuleName == "DevDocs" {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    if let url = URL(string: "https://github.com/shimajiron/Misaka_Network/blob/main/Document.md") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "doc.text.magnifyingglass")
                }
            }
            else if ModuleName == "Discord" {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    if let url = URL(string: "https://discord.gg/vGByEU7UzX") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "server.rack")
                }
            }
            else if ModuleName == "Respring" {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    Memory.shared.RespringConfirm = true
                }) {
                    HStack {
                        Image(systemName: "slowmo")
                    }
                }
            }else if ModuleName == "Apply" {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    ViewMemory.shared.Applying = true
                    DispatchQueue.global().async {
                        ApplyAll(Keep: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            ViewMemory.shared.Applying = false
                            Memory.shared.RespringConfirm = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "wand.and.rays.inverse")
                    }
                }
            }else if ModuleName == "DisplayType" {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    if MemorySingleton.DisplayType == 0 {
                        MemorySingleton.DisplayType = 1
                    }else{
                        MemorySingleton.DisplayType = 0
                    }
                }) {
                    HStack {
                        if MemorySingleton.DisplayType == 0 {
                            Image(systemName: "rectangle.grid.1x2.fill")
                        }else{
                            Image(systemName: "rectangle.grid.2x2.fill")
                        }
                    }
                }
            }else if ModuleName == "Applying_Keep" {
                if Memory.shared.BGRun_Applying {
                    ProgressView("")
                        .padding(EdgeInsets(
                            top: 11,
                            leading: 0,
                            bottom: 0,
                            trailing: 2
                        ))
                        .foregroundColor(Color.green)
                }
            }
        }
    }
}
var CGAT: CGAffineTransform?
func Respring() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    if SettingsManager.shared.RespringType != "FrontBoard" {
    }
    if SettingsManager.shared.RespringType == "FrontBoard" {
//        respringFrontboard()
    } else if SettingsManager.shared.RespringType == "BackBoard" {
//        respringBackboard()
    }
    
//    let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
//        let windows: [UIWindow] = UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .flatMap(\.windows)
//        
//        for window in windows {
//            CGAT = window.transform
//            window.alpha = 0
//            window.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        }
//    }
//    
//    animator.addCompletion { _ in
//        if SettingsManager.shared.Exploit == "KFD" && Memory.shared.kfd != 0 {
//            do_kclose()
//            MemorySingleton.puaf_pages = 0
//            MemorySingleton.kfd = 0
//        }
//        if SettingsManager.shared.RespringType == "FrontBoard" {
//            respringFrontboard()
//        } else {
//            respringBackboard()
//        }
//    }
//    animator.startAnimation()
}

func Wakeup() {
//    if let CGAT = CGAT {
//        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
//            let windows: [UIWindow] = UIApplication.shared.connectedScenes
//                .compactMap { $0 as? UIWindowScene }
//                .flatMap(\.windows)
//            
//            for window in windows {
//                window.alpha = 1
//                window.transform = CGAT
//            }
//        }
//        animator.startAnimation()
//    }
}



