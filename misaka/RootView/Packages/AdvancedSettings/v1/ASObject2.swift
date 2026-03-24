//
//  Editeaslly_item.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/04/02.
//

import Foundation
import SwiftUI

struct Color_Picker_Hex: View {
    @Binding var Option_Value: String
    @State var Option_Param: [String: Any]
    @State private var selectedColor = Color.white
    var body: some View {
        let NoHash = Option_Param["NoHash"] as? Bool ?? false
        let GBRA = Option_Param["BGRA"] as? Bool ?? false
        ColorPicker(selection: $selectedColor, supportsOpacity: true, label: {})
            .onChange(of: selectedColor) { newValue in
                var Hex = getColorsFromPicker(pickerColor: selectedColor)
                if NoHash {
                    Hex = Hex.replacingOccurrences(of: "#", with: "")
                }
                if GBRA && NoHash {
                    Hex = convertColorFormat(Hex)
                }
                Option_Value = Hex
            }
            .onAppear {
                var Hex = Option_Value
                if GBRA && NoHash {
                    Hex = convertColorFormatReverse(Hex)
                }
                if NoHash {
                    Hex = "#"+Hex
                }
                let RGBA = hexToRGBA(hex: Hex)
                let RGBA_normalized = normalizeRGB(RGBA)
                selectedColor = Color(red: RGBA_normalized.red, green: RGBA_normalized.green, blue: RGBA_normalized.blue, opacity: RGBA_normalized.alpha)
            }
    }
}

struct Color_Picker_Tinting: View {
    @Binding var Option_Value: [String: Any]
    @State private var selectedColor = Color.white
    var body: some View {
        ColorPicker(selection: $selectedColor, supportsOpacity: true, label: {})
            .onChange(of: selectedColor) { newValue in
                let Hex = getColorsFromPicker(pickerColor: selectedColor)
                let RGBA = hexToRGBA(hex: Hex)
                let RGBA_normalized = normalizeRGB(RGBA)
                
                let 変数名 = [
                    "tintAlpha": RGBA_normalized.alpha,
                    "tintColor": [
                        "red": RGBA_normalized.red,
                        "green": RGBA_normalized.green,
                        "blue": RGBA_normalized.blue,
                        "alpha": 1
                    ]
                ] as [String : Any]
                Option_Value = 変数名
            }
            .onAppear {
                let red = 取得_プロパティリスト値_プロパティリスト(プロパティリスト: Option_Value, キー: "red") as? Double ?? 0
                let blue = 取得_プロパティリスト値_プロパティリスト(プロパティリスト: Option_Value, キー: "blue") as? Double ?? 0
                let green = 取得_プロパティリスト値_プロパティリスト(プロパティリスト: Option_Value, キー: "green") as? Double ?? 0
                let tintAlpha = 取得_プロパティリスト値_プロパティリスト(プロパティリスト: Option_Value, キー: "tintAlpha") as? Double ?? 0
                selectedColor = Color(red: red, green: green, blue: blue, opacity: tintAlpha)
            }
    }
}
func 取得_プロパティリスト値_プロパティリスト(プロパティリスト: [String: Any], キー: String) -> Any? {
    // 取得した値を格納する変数
    var 値: Any? = nil
    
    // 再帰的に辞書を探索して、指定されたキーの値を取得する関数
    func 検索値(_ 辞書: [String: Any], _ キー: String) -> [String: Any] {
        var 新辞書 = 辞書
        for (k, v) in 辞書 {
            if k == キー {
                値 = 新辞書[k]
            } else if let サブ辞書 = v as? [String: Any] {
                新辞書[k] = 検索値(サブ辞書, キー)
            }
        }
        return 新辞書
    }
    
    // プロパティリストから指定されたキーの値を探索する
    検索値(プロパティリスト, キー)
    // 取得した値を返す
    return 値
}


struct Color_Picker_Matrix: View {
    @Binding var Option_Value: [String: Any]
    @State private var selectedColor = Color.white
    var body: some View {
        ColorPicker(selection: $selectedColor, supportsOpacity: true, label: {})
            .onChange(of: selectedColor) { newValue in
                let Hex = getColorsFromPicker(pickerColor: selectedColor)
                let matrixArray = convertHexToColorMatrix(hex: Hex)
                let matrixDict = [
                    "m11": matrixArray[0],
                    "m12": matrixArray[0],
                    "m13": matrixArray[0],
                    "m14": matrixArray[0],
                    "m15": matrixArray[0],
                    
                    "m21": matrixArray[6],
                    "m22": matrixArray[6],
                    "m23": matrixArray[6],
                    "m24": matrixArray[6],
                    "m25": matrixArray[6],
                    
                    "m31": matrixArray[12],
                    "m32": matrixArray[12],
                    "m33": matrixArray[12],
                    "m34": matrixArray[12],
                    "m35": matrixArray[12],
                    
                    "m41": matrixArray[18],
                    "m42": matrixArray[18],
                    "m43": matrixArray[18],
                    "m44": matrixArray[18],
                    "m45": matrixArray[18],
                ]
                Option_Value = matrixDict
            }
            .onAppear {
                var matrixDictM = Option_Value
                let matrixDict = matrixDictM as? [String: Double] ?? [String: Double]()
                if matrixDict.count != 20 { return }
                let matrixArray = [
                    matrixDict["m11"]!, matrixDict["m12"]!, matrixDict["m13"]!, matrixDict["m14"]!, matrixDict["m15"]!,
                    matrixDict["m21"]!, matrixDict["m22"]!, matrixDict["m23"]!, matrixDict["m24"]!, matrixDict["m25"]!,
                    matrixDict["m31"]!, matrixDict["m32"]!, matrixDict["m33"]!, matrixDict["m34"]!, matrixDict["m35"]!,
                    matrixDict["m41"]!, matrixDict["m42"]!, matrixDict["m43"]!, matrixDict["m44"]!, matrixDict["m45"]!,
                ]
                guard let Hex = convertColorMatrixToHex(matrix: matrixArray) else { return }
                let RGBA = hexToRGBA(hex: Hex)
                let RGBA_normalized = normalizeRGB(RGBA)
                selectedColor = Color(red: RGBA_normalized.red, green: RGBA_normalized.green, blue: RGBA_normalized.blue, opacity: RGBA_normalized.alpha)
            }
    }
}

struct String_Input_Bridge: View {
    @Binding var Option: [String: Any]
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                String_Input(Option: $Option)
            }
        }else{
            VStack {
                String_Input(Option: $Option)
            }
        }
    }
}
struct String_Input: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @Binding var Option: [String: Any]
    @State var Option_Toggle: Bool = false
    var body: some View {
        if Option["UI"] as? String == "Picker" {
            if var Option_Value = Option["Value"] as? String,
               var Option_Selection = Option["Selection"] as? [[String: Any]] {
                if let Option_Label = Option["Label"] as? String {
                    Text(Option_Label)
                }
                Picker("", selection: Binding<String>(
                    get: { Option_Value },
                    set: { newValue in
                        Option_Value = newValue
                        Option["Value"] = Option_Value
                        for PAudio in Option_Selection {
                            if var Selection_Value = PAudio["Value"] as? String,
                                var Selection_AudioURL = PAudio["Audio"] as? String {
                                if newValue != Selection_Value { continue }
                                playSound(path: Selection_AudioURL.replacingOccurrences(of: "%TweakRF%", with: "\(DataPath("Packages"))/\(MemorySingleton.AdvancedSettings_Addon)"))
                            }
                        }
                    }
                )) {
                    ForEach(0..<Option_Selection.count, id: \.self) { index in
                        if var Selection_Value = Option_Selection[index]["Value"] as? String,
                           var Selection_Label = Option_Selection[index]["Label"] as? String {
                            Text(Selection_Label).tag(Selection_Value)
                        }
                    }
                }
            }
        }
        else if Option["UI"] as? String == "SegmentedControl" {
            if var Option_Value = Option["Value"] as? String,
               var Option_Selection = Option["Selection"] as? [[String: Any]] {
                if let Option_Label = Option["Label"] as? String {
                    Text(Option_Label)
                }
                Picker("", selection: Binding<String>(
                    get: { Option_Value },
                    set: { newValue in
                        withAnimation(.linear(duration: 1)) {
                            Option["Value"] = newValue
                        }
                    }
                )) {
                    ForEach(0..<Option_Selection.count, id: \.self) { index in
                        if var Selection_Label = Option_Selection[index]["Label"] as? String,
                           var Selection_Value = Option_Selection[index]["Value"] as? String {
                            Text(Selection_Label).tag(Selection_Value)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        else if Option["UI"] as? String == "Wheel" {
            if var Option_Value = Option["Value"] as? String,
               var Option_Selection = Option["Selection"] as? [[String: Any]] {
                if let Option_Label = Option["Label"] as? String {
                    Text(Option_Label)
                }
                Picker("", selection: Binding<String>(
                    get: { Option_Value },
                    set: { newValue in
                        withAnimation(.linear(duration: 1)) {
                            Option["Value"] = newValue
                        }
                    }
                )) {
                    ForEach(0..<Option_Selection.count, id: \.self) { index in
                        if var Selection_Value = Option_Selection[index]["Value"] as? String,
                           var Selection_Label = Option_Selection[index]["Label"] as? String {
                            Text(Selection_Label).tag(Selection_Value)
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 60)
            }
        }
        else if Option["UI"] as? String == "Menu" {
            if var Option_Value = Option["Value"] as? String,
               var Option_Selection = Option["Selection"] as? [[String: Any]] {
                HStack {
                    if let Option_Label = Option["Label"] as? String {
                        Text(Option_Label)
                    }
                    Spacer()
                    Menu {
                        ForEach(0..<Option_Selection.count, id: \.self) { index in
                            if var Selection_Value = Option_Selection[index]["Value"] as? String,
                               var Selection_Label = Option_Selection[index]["Label"] as? String {
                                Button(action: {
                                    Option["Value"] = Selection_Value
                                }) {
                                    Text(Selection_Label)
                                }
                            }
                        }
                    } label: {
                        if let lang = Option_Selection.first(where: { $0["Value"] as? String == Option_Value }) {
                            Text(lang["Label"] as? String ?? "")
                        }
                    }
                }
            }
        }
        else if Option["UI"] as? String == "Toggle" {
            if var Option_Value = Option["Value"] as? String,
               var Option_Selection = Option["Selection"] as? [String: String],
               var YES_Value = Option_Selection["YES"] as? String,
               var NO_Value = Option_Selection["NO"] as? String  {
                Toggle(isOn: Binding<Bool>(
                    get: { Option_Toggle },
                    set: { newValue in
                        withAnimation(.linear(duration: 1)) {
                            if newValue {
                                Option_Value = YES_Value
                                Option["Value"] = Option_Value
                                Option_Toggle = newValue
                            }else{
                                Option_Value = NO_Value
                                Option["Value"] = Option_Value
                                Option_Toggle = newValue
                            }
                        }
                    }
                )) {
                    if let Option_Label = Option["Label"] as? String {
                        Text(Option_Label)
                    }
                }
                .onAppear {
                    Option_Toggle = Option_Value == YES_Value
                }
            }
        }else {
            if var Option_Value = Option["Value"] as? String {
                if let Option_Label = Option["Label"] as? String {
                    Text(Option_Label)
                }
                TextField("", text: Binding<String>(
                    get: { Option_Value },
                    set: { newValue in
                        Option_Value = newValue
                        Option["Value"] = Option_Value
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}


struct Int_Input_Bridge: View {
    @Binding var Option: [String: Any]
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Int_Input(Option: $Option)
            }
        }else{
            VStack {
                Int_Input(Option: $Option)
            }
        }
    }
}
struct Int_Input: View {
    @Binding var Option: [String: Any]
    @State var Option_Toggle: Bool = false
    var body: some View {
        if Option["UI"] as? String == "Toggle" {
            if var Option_Value = Option["Value"] as? Int,
               var Option_Selection = Option["Selection"] as? [String: Int],
               var YES_Value = Option_Selection["YES"] as? Int,
               var NO_Value = Option_Selection["NO"] as? Int {
                Toggle(isOn: Binding<Bool>(
                    get: { Option_Toggle },
                    set: { newValue in
                        withAnimation(.linear(duration: 1)) {
                            if newValue {
                                Option_Value = YES_Value
                                Option["Value"] = Option_Value
                                Option_Toggle = newValue
                            }else{
                                Option_Value = NO_Value
                                Option["Value"] = Option_Value
                                Option_Toggle = newValue
                            }
                        }
                    }
                )) {
                    if let Option_Label = Option["Label"] as? String {
                        Text(Option_Label)
                    }
                }
                .onAppear {
                    Option_Toggle = Option_Value == YES_Value
                }
            }
        }else if Option["UI"] as? String == "Slider" {
            if var Option_Value = Option["Value"] as? Int,
               var Option_Min = Option["Min"] as? Double,
               var Option_Max = Option["Max"] as? Double,
               var Option_Step = Option["Step"] as? Double {
                VStack {
                    if let Option_Label = Option["Label"] as? String {
                        Text(Option_Label)
                    }
                    HStack {
                        Text("\(Int(Option_Value))")
                        Slider(value: Binding<Double>(
                            get: { Double(Option_Value) },
                            set: { newValue in
                                Option["Value"] = Int(newValue)
                            }
                        ), in: Option_Min...Option_Max, step: Option_Step) {
                            Text("\(Option_Value)")
                        }
                    }
                }
            }
        }else {
            if var Option_Value = Option["Value"] as? Int,
               var Option_Min = Option["Min"] as? Int,
               var Option_Max = Option["Max"] as? Int,
               var Option_Step = Option["Step"] as? Double {
                HStack {
                    if let Option_Label = Option["Label"] as? String {
                        Text(Option_Label)
                    }
                    TextField("", value: Binding<Int>(
                        get: { Option_Value },
                        set: { newValue in
                            if newValue > Option_Max {
                                Option["Value"] = Option_Max
                                Option_Value = Option_Max
                            } else if newValue < Option_Min {
                                Option["Value"] = Option_Min
                                Option_Value = Option_Min
                            } else {
                                Option["Value"] = newValue
                            }
                        }
                    ), formatter: NumberFormatter())
                    Spacer()
                    Stepper(value: Binding<Int>(
                        get: { Option_Value },
                        set: { newValue in
                            Option["Value"] = newValue
                        }
                    ), in: Option_Min...Option_Max) {
                    }
                }
            }
        }
    }
}


struct Double_Input_Bridge: View {
    @Binding var Option: [String: Any]
    var body: some View {
        if Option["LabelPosition"] as? String ?? "Top" == "Left" {
            HStack {
                Double_Input(Option: $Option)
            }
        }else{
            VStack {
                Double_Input(Option: $Option)
            }
        }
    }
}
struct Double_Input: View {
    @Binding var Option: [String: Any]
    @State var Option_Toggle: Bool = false
    var body: some View {
        if Option["UI"] as? String == "Toggle" {
            if var Option_Value = Option["Value"] as? Double,
               var Option_Selection = Option["Selection"] as? [String: Double],
               var YES_Value = Option_Selection["YES"] as? Double,
               var NO_Value = Option_Selection["NO"] as? Double {
                Toggle(isOn: Binding<Bool>(
                    get: { Option_Toggle },
                    set: { newValue in
                        withAnimation(.linear(duration: 1)) {
                            if newValue {
                                Option_Value = YES_Value
                                Option["Value"] = Option_Value
                                Option_Toggle = newValue
                            }else{
                                Option_Value = NO_Value
                                Option["Value"] = Option_Value
                                Option_Toggle = newValue
                            }
                        }
                    }
                )) {
                    if let Option_Label = Option["Label"] as? String {
                        Text(Option_Label)
                    }
                }
                .onAppear {
                    Option_Toggle = Option_Value == YES_Value
                }
            }
        }else {
            if var Option_Value = Option["Value"] as? Double,
               var Option_Min = Option["Min"] as? Double,
               var Option_Max = Option["Max"] as? Double,
               var Option_Step = Option["Step"] as? Double {
                VStack {
                    if let Option_Label = Option["Label"] as? String {
                        Text(Option_Label)
                    }
                    HStack {
                        let formattedString = String(format: "%.\(countDecimalPlaces(Option_Step))f", Option_Value)
                        Text(formattedString)
                        Slider(value: Binding<Double>(
                            get: { Option_Value },
                            set: { newValue in
                                Option["Value"] = newValue
                            }
                        ), in: Option_Min...Option_Max, step: Option_Step) {
//                            Text("\(Option_Value)")
                        }
                    }
                }
            }
        }
    }
}

func countDecimalPlaces(_ number: Double) -> Int {
    let stringValue = String(number)
    
    if let range = stringValue.range(of: ".") {
        let decimalPart = stringValue.suffix(from: range.upperBound)
        return decimalPart.count
    } else {
        return 0
    }
}

//
//  ImagePicker.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/04/10.
//

import Foundation
import SwiftUI
import FilePicker

struct ImagePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: Data?
    enum SourceType {
        case camera
        case library
    }
    var sourceType: SourceType
    var allowsEditing: Bool = false

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                   mediaType == "public.movie",
                   let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                   let videoData = try? Data(contentsOf: videoURL) {
                        parent.image = videoData
            } else if let image = info[.editedImage] as? UIImage {
                parent.image = image.pngData()
            } else if let image = info[.originalImage] as? UIImage {
                parent.image = image.pngData()
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        viewController.mediaTypes = ["public.image", "public.movie"]
        switch sourceType {
            case .camera:
                viewController.sourceType = UIImagePickerController.SourceType.camera
            case .library:
                viewController.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        viewController.allowsEditing = allowsEditing
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
}

struct ImagePicker: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @State var Option_Label: String
    @State var Option_URL: String
    @State var Option_Param: [String: Any]
    @State var showingPicker = false
    @State var image: Data?
    var body: some View {
        HStack {
            Button(Option_Label) {
                showingPicker.toggle()
            }
            Spacer()
            if let image = UIImage(data: image ?? Data()) {
                let aspectRatio = Option_Param["aspectRadio"] as? String ?? "fit"
                let displayWidth = Option_Param["displayWidth"] as? CGFloat ?? nil
                let displayHeight = Option_Param["displayHeight"] as? CGFloat ?? nil
                if aspectRatio == "nil" {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: displayWidth, height: displayHeight)
                }else{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: aspectRatio == "fit" ? .fit : .fill)
                        .frame(width: displayWidth, height: displayHeight)
                }
            }else if let image = image {
                Text(String(image.count)+" bytes")
            }
        }
        .frame(maxHeight: 100)
        .sheet(isPresented: $showingPicker) {
            ImagePickerView(image: $image, sourceType: .library)
        }
        .onChange(of: image) { newValue in
            guard let data = newValue else { return }
            let url = URLwithEncode(string: "\(DataPath("Packages"))/\(MemorySingleton.AdvancedSettings_Addon)/Overwrite/\(Option_URL)")!
            do{
                try data.write(to: url)
            }catch{
                UIApplication.shared.alert(body: "Permission Denied")
            }
        }
        .onAppear{
            let url = URLwithEncode(string: "\(DataPath("Packages"))/\(MemorySingleton.AdvancedSettings_Addon)/Overwrite/\(Option_URL)")!
            guard let data = try? Data(contentsOf: url) else { return }
            image = data
        }
    }
}

struct FilePicker_m: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @State var Option_Label: String
    @State var Option_URL: String
    @State var image: Data?
    var body: some View {
        HStack {
            FilePicker(types: [.item], allowMultiple: false, title: Option_Label) { urls in
                guard let data = try? Data(contentsOf: urls.first!) else { return }
                var url = URLwithEncode(string: "\(DataPath("Packages"))/\(MemorySingleton.AdvancedSettings_Addon)/Overwrite/\(Option_URL)")!
                if Option_URL.contains("/var"), SettingsManager.shared.Exploit == "DarkSword" || SettingsManager.shared.NoVar {
                    url = URLwithEncode(string: "\(DataPath("Emu_Var"))/\(Option_URL)")!
                }
                do{
                    try data.write(to: url)
                    image = data
                }catch{
                    UIApplication.shared.alert(body: "Permission Denied")
                }
            }
            Spacer()
            if let image = image {
                Text(String(image.count)+" \(MILocalizedString("Bytes"))")
            }
        }
        .onAppear{
            var url = URLwithEncode(string: "\(DataPath("Packages"))/\(MemorySingleton.AdvancedSettings_Addon)/Overwrite/\(Option_URL)")!
            if Option_URL.contains("/var"), SettingsManager.shared.Exploit == "DarkSword" || SettingsManager.shared.NoVar {
                url = URLwithEncode(string: "\(DataPath("Emu_Var"))/\(Option_URL)")!
            }
            guard let data = try? Data(contentsOf: url) else { return }
            image = data
        }
    }
}
