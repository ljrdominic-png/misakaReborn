//
//  floating.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/23.
//

import Foundation
import SwiftUI

struct FloatingToolbox: View {
    @ObservedObject var MemorySingleton = Memory.shared
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    MemorySingleton.ToolBox_IsActive = true
                }, label: {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 24))
                        .frame(width: 60, height: 60)
                        .background(Color.blue.opacity(0.5))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .padding(EdgeInsets(top: 0, leading: 16.0, bottom: 16.0, trailing: 0)) // --- 5
                })
                Spacer()
            }
        }
    }
}
