////
////  Search.swift
////  misaka
////
////  Created by straight-tamago☆ on 2023/02/28.
////
//
//import SwiftUI
//import Foundation
//import SwiftUIGIF
//import UIKit
//
//struct ImageSearch: View {
//    @State private var searchPath = "/System/Library/PrivateFrameworks"
//    @State var image_paths: [String] = [String]()
//    @State var car_paths: [String] = [String]()
//    @State var columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
//    @State var isLoading = false // プログレスバー表示用のフラグ
//    @State var FirstBoot = true
//    var body: some View {
//        VStack {
//            TextField(MILocalizedString("Search"), text: $searchPath)
//            ScrollView {
//                LazyVGrid(columns: columns) {
//                    Section(header: Text(".car")) {
//                        ForEach (car_paths, id: \.self) { car_path in
//                            CUINamedImages_View(path: car_path)
//                        }
//                    }
//                    Section(header: Text(".png .jpg ...")) {
//                        ForEach (image_paths, id: \.self) { image_path in
//                            Button(action: {
//                                UIApplication.shared.confirmAlert(title: MILocalizedString("Copy Path?"), body: image_path, onOK: {
//                                    UIPasteboard.general.string = image_path
//                                }, noCancel: false)
//                            }) {
//                                GIFImage(data: sds(image: image_path) ?? Data())
//                                    .aspectRatio(contentMode: .fit)
//                                    .foregroundColor(.white)
//                                    .frame(height: 110)
//                                    .padding(2)
//                                    .background(Color.blue)
//                                    .cornerRadius(10)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .navigationTitle(MILocalizedString("Image Viewer"))
//        .padding()
//        .onAppear {
//            if FirstBoot == true {
//                isLoading = true // プログレスバー表示フラグをtrueにする
//                DispatchQueue.global().async { // バックグラウンドスレッドで実行する
//                    image_paths = getFilePaths(ext: "png")
//                    car_paths = getFilePaths(ext: "car")
//                    if UIDevice.current.userInterfaceIdiom == .pad {
//                        columns = [ GridItem(.adaptive(minimum: 180, maximum: 250)) ]
//                    }
//                    isLoading = false // プログレスバー表示フラグをfalseにする
//                }
//            }
//            FirstBoot = false
//        }
//        .onChange(of: searchPath) { newValue in
//            isLoading = true // プログレスバー表示フラグをtrueにする
//            DispatchQueue.global().async { // バックグラウンドスレッドで実行する
//                image_paths = getFilePaths(ext: "png")
//                car_paths = getFilePaths(ext: "car")
//                if UIDevice.current.userInterfaceIdiom == .pad {
//                    columns = [ GridItem(.adaptive(minimum: 180, maximum: 250)) ]
//                }
//                isLoading = false // プログレスバー表示フラグをfalseにする
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing){
//                if isLoading {
//                    ProgressView("")
//                }
//            }
//        }.navigationViewStyle(.stack)
//    }
//    func getFilePaths(ext: String) -> [String]{
//        var result = [String]()
//        if let enumerator = FileManager.default.enumerator(atPath: searchPath) {
//            while let element = enumerator.nextObject() as? String {
//                if element.hasSuffix(".\(ext)") {
//                    let filePath = URL(fileURLWithPath: searchPath).appendingPathComponent(element).path
//                    result.append(filePath)
//                }
//            }
//        }
//        return result
//    }
//}
//
//func sds(image: String) -> Data?{
//    guard let url = URLwithEncode(string: image) else { return nil }
//    guard let data = try? Data(contentsOf: url) else { return nil }
//    return data
//}
//
//struct CUINamedImages_View: View {
//    @State var path: String
//    @State var CUINamedImages: [String] = [String]()
//    
//    @State var columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
//    
//    var body: some View {
//        Text(" ")
//            .onAppear {
//                ClearPath(Path: Path_Generate(Type: "CarTmp"))
////                CUINamedImages = loadCUINamedImages(path: path) ?? [String]()
//            }
//        ForEach(CUINamedImages, id: \.self) { CUINamedImage in
//            Button(action: {
//                UIApplication.shared.confirmAlert(title: MILocalizedString("Copy Path?"), body: path, onOK: {
//                    UIPasteboard.general.string = path
//                }, noCancel: false)
//            }) {
//                Image(uiImage: UIImage(contentsOfFile: CUINamedImage) ?? UIImage())
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.white)
//                    .frame(height: 110)
//                    .padding(2)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//        }
//    }
//}
////
////func loadCUINamedImages(path: String) -> [String]? {
////    var namedImages = [String]()
////    guard let carFileURL = URLwithEncode(string: path) else { return nil }
////    let catalog = CUICatalog(url: carFileURL, error: nil)
////    let imageNames = catalog.allImageNames()
////    imageNames.forEach{
////        if let namedImage = catalog.image(withName: $0, scaleFactor: 1.0).image {
////            if let imageData = UIImage(cgImage: namedImage).pngData() {
////                do {
////                    let uuid = UUID().uuidString
////                    try imageData.write(to: Path_Generate(Type: "CarTmp").appendingPathComponent(uuid))
////                    namedImages.append(Path_Generate(Type: "CarTmp").appendingPathComponent(uuid).path)
////                    print("sis")
////                } catch {
////                    print("Failed to save image: \(error)")
////                }
////            }
////        }
////    }
////    return namedImages
////}
//
