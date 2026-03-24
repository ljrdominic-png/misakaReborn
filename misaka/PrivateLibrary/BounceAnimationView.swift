//
//  BounceAnimationView.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/10.
//

import Foundation
import SwiftUI

struct BounceAnimationView: View {
    let characters: Array<String.Element>

    @State var offsetYForBounce: CGFloat = -50
    @State var opacity: CGFloat = 0
    @State var baseTime: Double

    init(text: String, startTime: Double){
        self.characters = Array(text)
        self.baseTime = startTime
    }

    var body: some View {
        HStack(spacing:0){
            ForEach(0..<characters.count) { num in
                Text(String(self.characters[num]))
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .offset(x: 0, y: offsetYForBounce)
                    .opacity(opacity)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1).delay( Double(num) * 0.01 ), value: offsetYForBounce)
            }
            .onTapGesture {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    opacity = 0
                    offsetYForBounce = -50
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    opacity = 1
                    offsetYForBounce = 0
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + (0 + baseTime)) {
                    opacity = 1
                    offsetYForBounce = 0
                }
            }
        }
    }
}
