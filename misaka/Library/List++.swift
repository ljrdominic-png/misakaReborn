//
//  List++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/14.
//

import Foundation
import SwiftUI

extension List {
    func listBackground(_ color: Color) -> some View {
        UITableView.appearance().backgroundColor = UIColor(color)
        return self
    }
}
