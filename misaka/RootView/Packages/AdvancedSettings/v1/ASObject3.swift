//
//  ED2.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/04/17.
//

import Foundation
import SwiftUI


struct Enabler_Toggle_Bridge: View {
    @Binding var Option: [String: Any]
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Enabler_Toggle(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }else{
            VStack {
                Enabler_Toggle(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }
    }
}
struct Enabler_Toggle: View {
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Option: [String: Any]
    @State var Option_Toggle: Bool = false
    @Binding var Write: Bool
    var body: some View {
        if var Option_Value = Option["Value"] as? Bool,
           var Option_Identifiers = Option["Identifiers"] as? [String: [String]],
           var Option_Identifiers_To_Enable = Option_Identifiers["To_Enable"],
           var Option_Identifiers_To_Disable = Option_Identifiers["To_Disable"] {
            Toggle(isOn: Binding<Bool>(
                get: { Option_Value },
                set: { newValue in
                    withAnimation(.linear(duration: 1)) {
                        Option["Value"] = newValue
                        
                        func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                            var categories = b_categories
                            for Categories_index in categories.indices {
                                var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                for tweaks_index in tweaks.indices {
                                    if var options = tweaks[tweaks_index] as? [String: Any],
                                       let option_Identifier = options["Identifier"] as? String {
                                        if Option_Identifiers_To_Disable.contains(option_Identifier) {
                                            if newValue {
                                                options["Disabled"] = true
                                            }else{
                                                options.removeValue(forKey: "Disabled")
                                            }
                                        }
                                        if Option_Identifiers_To_Enable.contains(option_Identifier) {
                                            if newValue {
                                                options.removeValue(forKey: "Disabled")
                                            }else{
                                                options["Disabled"] = true
                                            }
                                        }
                                        tweaks[tweaks_index] = options
                                        categories[Categories_index]["Tweaks"] = tweaks
                                    }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                        tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                    }
                                }
                            }
                            return categories
                        }
                        Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
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
}


struct Disabler_Toggle_Bridge: View {
    @Binding var Option: [String: Any]
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Disabler_Toggle(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }else{
            VStack {
                Disabler_Toggle(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }
    }
}
struct Disabler_Toggle: View {
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Option: [String: Any]
    @State var Option_Toggle: Bool = false
    @Binding var Write: Bool
    var body: some View {
        if var Option_Value = Option["Value"] as? Bool,
           var Option_Identifiers = Option["Identifiers"] as? [String: [String]],
           var Option_Identifiers_To_Enable = Option_Identifiers["To_Enable"],
           var Option_Identifiers_To_Disable = Option_Identifiers["To_Disable"] {
            Toggle(isOn: Binding<Bool>(
                get: { !Option_Value },
                set: { newValue in
                    withAnimation(.linear(duration: 1)) {
                        Option["Value"] = !newValue
                        
                        func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                            var categories = b_categories
                            for Categories_index in categories.indices {
                                var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                for tweaks_index in tweaks.indices {
                                    if var options = tweaks[tweaks_index] as? [String: Any],
                                       let option_Identifier = options["Identifier"] as? String {
                                        if Option_Identifiers_To_Disable.contains(option_Identifier) {
                                            if !newValue {
                                                options["Disabled"] = true
                                            }else{
                                                options.removeValue(forKey: "Disabled")
                                            }
                                        }
                                        if Option_Identifiers_To_Enable.contains(option_Identifier) {
                                            if !newValue {
                                                options.removeValue(forKey: "Disabled")
                                            }else{
                                                options["Disabled"] = true
                                            }
                                        }
                                        tweaks[tweaks_index] = options
                                        categories[Categories_index]["Tweaks"] = tweaks
                                    }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                        tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                    }
                                }
                            }
                            return categories
                        }
                        Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
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
}





struct Disabler_Selection_Bridge: View {
    @Binding var Option: [String: Any]
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Disabler_Selection(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }else{
            VStack {
                Disabler_Selection(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }
    }
}
struct Disabler_Selection: View {
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Option: [String: Any]
    @Binding var Write: Bool
    @State var Option_Toggle: Bool = false
    var body: some View {
        if var Option_Value = Option["Value"] as? String,
           var Option_Identifiers = Option["Identifiers"] as? [[String: Any]] {
            if let Option_Label = Option["Label"] as? String {
                Text(Option_Label)
            }
            Picker("", selection: Binding<String>(
                get: { Option_Value },
                set: { newValue in
                    withAnimation(.linear(duration: 1)) {
                        Option["Value"] = newValue
                        for index in 0..<Option_Identifiers.count {
                            if var Selection_Value = Option_Identifiers[index]["Value"] as? String,
                               var Selection_Label = Option_Identifiers[index]["Label"] as? String,
                               var Option_Identifiers_To_Enable = Option_Identifiers[index]["To_Enable"] as? [String],
                               var Option_Identifiers_To_Disable = Option_Identifiers[index]["To_Disable"] as? [String] {
                                
                                if Selection_Value == newValue {
                                    func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                                        var categories = b_categories
                                        for Categories_index in categories.indices {
                                            var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                            for tweaks_index in tweaks.indices {
                                                if var options = tweaks[tweaks_index] as? [String: Any],
                                                   let option_Identifier = options["Identifier"] as? String {
                                                    if Option_Identifiers_To_Disable.contains(option_Identifier) {
                                                        options.removeValue(forKey: "Disabled")
                                                    }
                                                    tweaks[tweaks_index] = options
                                                    categories[Categories_index]["Tweaks"] = tweaks
                                                }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                                    tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                                }
                                            }
                                        }
                                        return categories
                                    }
                                    Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
                                }else{
                                    func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                                        var categories = b_categories
                                        for Categories_index in categories.indices {
                                            var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                            for tweaks_index in tweaks.indices {
                                                if var options = tweaks[tweaks_index] as? [String: Any],
                                                   let option_Identifier = options["Identifier"] as? String {
                                                    if Option_Identifiers_To_Disable.contains(option_Identifier) {
                                                        options["Disabled"] = true
                                                    }
                                                    tweaks[tweaks_index] = options
                                                    categories[Categories_index]["Tweaks"] = tweaks
                                                }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                                    tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                                }
                                            }
                                        }
                                        return categories
                                    }
                                    Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
                                }
                            }
                        }
                        Write.toggle()
                    }
                }
            )) {
                ForEach(0..<Option_Identifiers.count, id: \.self) { index in
                    if var Selection_Value = Option_Identifiers[index]["Value"] as? String,
                       var Selection_Label = Option_Identifiers[index]["Label"] as? String {
                        Text(Selection_Label).tag(Selection_Value)
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}





struct Hider_Toggle_Bridge: View {
    @Binding var Option: [String: Any]
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Hider_Toggle(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }else{
            VStack {
                Hider_Toggle(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }
    }
}
struct Hider_Toggle: View {
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Option: [String: Any]
    @State var Option_Toggle: Bool = false
    @Binding var Write: Bool
    var body: some View {
        if var Option_Value = Option["Value"] as? Bool,
           var Option_Identifiers = Option["Identifiers"] as? [String: [String]],
           var Option_Identifiers_To_Enable = Option_Identifiers["To_Enable"],
           var Option_Identifiers_To_Disable = Option_Identifiers["To_Disable"] {
            Toggle(isOn: Binding<Bool>(
                get: { !Option_Value },
                set: { newValue in
                    withAnimation(.linear(duration: 1)) {
                        Option["Value"] = !newValue
                        
                        func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                            var categories = b_categories
                            for Categories_index in categories.indices {
                                var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                for tweaks_index in tweaks.indices {
                                    if var options = tweaks[tweaks_index] as? [String: Any],
                                       let option_Identifier = options["Identifier"] as? String {
                                        if Option_Identifiers_To_Disable.contains(option_Identifier) {
                                            if !newValue {
                                                options["Hide"] = true
                                            }else{
                                                options.removeValue(forKey: "Hide")
                                            }
                                        }
                                        if Option_Identifiers_To_Enable.contains(option_Identifier) {
                                            if !newValue {
                                                options.removeValue(forKey: "Hide")
                                            }else{
                                                options["Hide"] = true
                                            }
                                        }
                                        tweaks[tweaks_index] = options
                                        categories[Categories_index]["Tweaks"] = tweaks
                                    }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                        tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                    }
                                }
                            }
                            return categories
                        }
                        Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
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
}





struct Hider_Selection_Bridge: View {
    @Binding var Option: [String: Any]
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Hider_Selection(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }else{
            VStack {
                Hider_Selection(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }
    }
}
struct Hider_Selection: View {
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Option: [String: Any]
    @Binding var Write: Bool
    @State var Option_Toggle: Bool = false
    var body: some View {
        if var Option_Value = Option["Value"] as? String,
           var Option_Identifiers = Option["Identifiers"] as? [[String: Any]] {
            if let Option_Label = Option["Label"] as? String {
                Text(Option_Label)
            }
            Picker("", selection: Binding<String>(
                get: { Option_Value },
                set: { newValue in
                    withAnimation(.linear(duration: 1)) {
                        Option["Value"] = newValue
                        for index in 0..<Option_Identifiers.count {
                            if var Selection_Value = Option_Identifiers[index]["Value"] as? String,
                               var Selection_Label = Option_Identifiers[index]["Label"] as? String,
                               var Option_Identifiers_To_Enable = Option_Identifiers[index]["To_Enable"] as? [String],
                               var Option_Identifiers_To_Disable = Option_Identifiers[index]["To_Disable"] as? [String] {
                                
                                if Selection_Value == newValue {
                                    func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                                        var categories = b_categories
                                        for Categories_index in categories.indices {
                                            var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                            for tweaks_index in tweaks.indices {
                                                if var options = tweaks[tweaks_index] as? [String: Any],
                                                   let option_Identifier = options["Identifier"] as? String {
                                                    if Option_Identifiers_To_Disable.contains(option_Identifier) {
                                                        options.removeValue(forKey: "Hide")
                                                    }
                                                    tweaks[tweaks_index] = options
                                                    categories[Categories_index]["Tweaks"] = tweaks
                                                }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                                    tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                                }
                                            }
                                        }
                                        return categories
                                    }
                                    Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
                                }else{
                                    func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                                        var categories = b_categories
                                        for Categories_index in categories.indices {
                                            var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                            for tweaks_index in tweaks.indices {
                                                if var options = tweaks[tweaks_index] as? [String: Any],
                                                   let option_Identifier = options["Identifier"] as? String {
                                                    if Option_Identifiers_To_Disable.contains(option_Identifier) {
                                                        options["Hide"] = true
                                                    }
                                                    tweaks[tweaks_index] = options
                                                    categories[Categories_index]["Tweaks"] = tweaks
                                                }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                                    tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                                }
                                            }
                                        }
                                        return categories
                                    }
                                    Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
                                }
                            }
                        }
                        Write.toggle()
                    }
                }
            )) {
                ForEach(0..<Option_Identifiers.count, id: \.self) { index in
                    if var Selection_Value = Option_Identifiers[index]["Value"] as? String,
                       var Selection_Label = Option_Identifiers[index]["Label"] as? String {
                        Text(Selection_Label).tag(Selection_Value)
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}





struct Preset_Bridge: View {
    @Binding var Option: [String: Any]
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Write: Bool
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Preset(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }else{
            VStack {
                Preset(Main_Categories: $Main_Categories, Categories: $Categories, Option: $Option, Write: $Write)
            }
        }
    }
}
struct Preset: View {
    @Binding var Main_Categories: [[String: Any]]
    @Binding var Categories: [[String: Any]]
    @Binding var Option: [String: Any]
    @Binding var Write: Bool
    @State var Option_Toggle: Bool = false
    var body: some View {
        if var Option_Presets = Option["Presets"] as? [[String: Any]] {
            if let Option_Label = Option["Label"] as? String {
                Button(Option_Label) {
                    withAnimation(.linear(duration: 1)) {
                        func updatevalue(b_categories: [[String: Any]]) -> [[String: Any]]? {
                            var categories = b_categories
                            for Categories_index in categories.indices {
                                var tweaks = categories[Categories_index]["Tweaks"] as? [[String: Any]] ?? []
                                for tweaks_index in tweaks.indices {
                                    if var options = tweaks[tweaks_index] as? [String: Any],
                                       let option_Identifier = options["Identifier"] as? String {
                                        for Preset in Option_Presets {
                                            if Preset["Identifier"] as? String == option_Identifier {
                                                options["Value"] = Preset["Value"]
                                            }
                                        }
                                        tweaks[tweaks_index] = options
                                        categories[Categories_index]["Tweaks"] = tweaks
                                    }else if var categories_2 = tweaks[tweaks_index]["Categories"] as? [[String: Any]] {
                                        tweaks[tweaks_index]["Categories"] = updatevalue(b_categories: categories_2) ?? categories_2
                                    }
                                }
                            }
                            return categories
                        }
                        Main_Categories = updatevalue(b_categories: Main_Categories) ?? Main_Categories
                        Write.toggle()
                    }
                }
            }
        }
    }
}





