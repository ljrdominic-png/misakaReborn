//
//  AnimatedNavigationTitle.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/10.
//

import Foundation
import SwiftUI

struct AnimatedNavigationTitle: View {
    @State var title: String
    var body: some View {
        HStack {
            BlurView(text: title, textSize: 30, startTime: 0)
                .frame(height: 10)
            Spacer()
        }
        .padding(.bottom, 20)
        .listRowSeparator(.hidden)
    }
}

struct BlurView: View {
    let characters: Array<String.Element>
    let baseTime: Double
    let textSize: Double
    @State var blurValue: Double = 10
    @State var opacity: Double = 0

    init(text:String, textSize: Double, startTime: Double) {
        characters = Array(text)
        self.textSize = textSize
        baseTime = startTime
    }

    var body: some View {
        HStack(spacing: 1){
            ForEach(0..<characters.count) { num in
                Text(String(self.characters[num]))
                    .font(.system(size: textSize, weight: .bold, design: .rounded))
//                    .font(.custom("DBLCDTempBlack", size: textSize))
                    .blur(radius: blurValue)
                    .opacity(opacity)
                    .animation(.easeInOut.delay( Double(num) * 0.01 ), value: blurValue)
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + baseTime) {
                if blurValue == 0{
                    blurValue = 10
                    opacity = 0.01
                } else {
                    blurValue = 0
                    opacity = 1
                }
            }
        }
    }
}
