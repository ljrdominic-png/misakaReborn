//
//  SmoothSheet.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/14.
//

import Foundation
import SwiftUI

class SmoothSheetController: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = SmoothSheetController()
    @Published var TabOffset: CGFloat = 0
    @Published var ShowBar = false
}

struct SmoothSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var SmoothSheetControllerSingleton = SmoothSheetController.shared
    @State var isPresent = false
    @State var BarHeight: CGFloat = 63
    @State var TabHeights: [String: CGFloat] = [
        "iPhone-Dynamic_Island": 140,
        "iPhone-Notch": 127,
        "iPhone": 67,
        "iPad": 87,
    ]
    @State var DeviceType: String = "iPhone-Notch"
    @State var QueueOffset: CGFloat = 0
    /// Extra downward offset when the queue is empty so the header + handle sit fully below the tab bar (100pt was not enough).
    private var hiddenWhenQueueEmptyExtra: CGFloat {
        SmoothSheetControllerSingleton.ShowBar ? 0 : 240
    }
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.white : Color.black
            VStack {
                if !isPresent {
                    QueueHeader(isPresent: $isPresent)
                    .contentShape(RoundedRectangle(cornerRadius: 20))
                    .onTapGesture {
                        isPresent = true
                    }
                }
                Image(systemName: "chevron.compact.down")
                    .font(.system(size: 40))
                    .padding(.top, isPresent ? 50 : 10)
                    .padding(.bottom, 5)
                    .gesture(DragGesture().onChanged(Close(value:)))
                QueueContent(isPresent: $isPresent)
                    .padding(.bottom, (DeviceType == "iPhone-Dynamic_Island" || DeviceType == "iPhone-Notch") ? 50 : 30)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .offset(y: ((UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight)) + QueueOffset) + hiddenWhenQueueEmptyExtra)
        .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnded(value:)))
        .onChange(of: isPresent) { bool in
            Control(bool)
        }
        .onAppear {
            DeviceType = (UIDevice.current.isiPhone) ? "iPhone" : "iPhone-Notch"
            DeviceType = (UIDevice.current.isiPad) ? "iPad" : DeviceType
            DeviceType = (UIDevice.current.isiPhone && UIDevice.current.hasNotch) ? "iPhone-Notch" : DeviceType
            DeviceType = (UIDevice.current.isiPhone && UIDevice.current.hasDynamicIsland) ? "iPhone-Dynamic_Island" : DeviceType
            print("[* misaka] "+DeviceType)
        }      
    
    }
    func Close(value: DragGesture.Value){
        isPresent = false
    }
    func Control(_ bool: Bool) {
        withAnimation(.interpolatingSpring(stiffness: 600, damping: 100)) {
            QueueOffset = bool ? -(UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight)) : 0
            SmoothSheetControllerSingleton.TabOffset = bool ? -TabHeights[DeviceType]! : 0
            isPresent = bool
        }
    }
    func onChanged(value: DragGesture.Value){
        if QueueOffset >= -(UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight)) && QueueOffset <= 0 {
            if isPresent {
//                QueueOffset = value.translation.height - (UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight))
//                SmoothSheetControllerSingleton.TabOffset = (value.translation.height*120 / (UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight))) - (TabHeights[DeviceType]! + BarHeight)
            }else {
                QueueOffset = value.translation.height
                SmoothSheetControllerSingleton.TabOffset = value.translation.height*120 / (UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight))
            }
        }
    }
    func onEnded(value: DragGesture.Value){
        if isPresent {
            Control(!(QueueOffset > -(((UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight)) / 4)*3)))
        }else {
            Control(!(QueueOffset > -((UIScreen.main.bounds.height - (TabHeights[DeviceType]! + BarHeight)) / 4)))
        }
    }
}


