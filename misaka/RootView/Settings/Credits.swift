//
//  Credits.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/03.
//

import SwiftUI
import SDWebImageSwiftUI

struct Credit_ST: Codable, Hashable {
    var Name: String?
    var Image: String?
    var Contribution: String?
    var Link: String?
}
struct Credits_ST: Codable, Hashable {
    var Section: String?
    var Contents: [Credit_ST]?
}

struct Credits: View {
    @State private var Credits: [Credits_ST] = [Credits_ST]()
    var body: some View {
        ForEach(Credits, id: \.self) { credit in
            if let section = credit.Section {
                Section(header: Label(MILocalizedString(section), systemImage: "heart")) {
                    if let contents = credit.Contents {
                        ForEach(contents, id: \.self) { content in
                            if let Name = content.Name,
                               let Contribution = content.Contribution,
                               let Link = content.Link {
                                if let _ = content.Image {
                                    Button(action: {
                                        if let url = URL(string: Link) {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            if let Image_ = content.Image,
                                               let ImageURL = URL(string: Image_) {
                                                CreditImageView(url: ImageURL) {
                                                    ProgressView()
                                                }
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(10)
                                                .padding(.trailing, 5)
                                            }
                                            VStack(alignment: .leading) {
                                                Text(MILocalizedString(Name))
                                                    .font(.headline)
                                                Text(MILocalizedString(Contribution))
                                                    .font(.subheadline)
                                            }
                                        }
                                        .padding(EdgeInsets(
                                            top: 5,
                                            leading: 4,
                                            bottom: 5,
                                            trailing: 4
                                        ))
                                    }
                                } else {
                                    Button(action: {
                                        if let url = URL(string: Link) {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text(Name) + Text(" (") + Text(Contribution) + Text(")")
                                    }
                                }
                            }
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        if Credits == [Credits_ST]() {
            ProgressView()
                .onAppear{
                    Requests(RequestsType(Method: "Get", URL: "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Credits.json")) { data in
                        do {
                            if let data = data {
                                let decoder = JSONDecoder()
                                decoder.allowsJSON5 = true
                                let json = try decoder.decode([Credits_ST].self, from: data)
                                Credits = json
                            }
                        }catch{}
                    }
                }
        }
    }
}

struct CreditImageView<Content: View>: View {
    @StateObject var viewModel: AsyncImageViewModel
    let placeholder: Content
    
    init(url: URL?,
         @ViewBuilder placeholder: () -> Content)  {
        _viewModel = StateObject(wrappedValue: AsyncImageViewModel(url: url))
        self.placeholder = placeholder()
    }
    var body: some View {
        ZStack {

            if let uiImage = viewModel.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                placeholder
            }
        }
        .onAppear {
            DispatchQueue.global().async { // バックグラウンドスレッドで実行する
                viewModel.downloadImage()
            }
        }
    }
}
class AsyncImageViewModel: ObservableObject {
    @Published var uiImage: UIImage? = nil
    let url: URL?

    init(url: URL?) {
        self.url = url
    }

    @MainActor
    func downloadImage() {
        guard let data = downloadImageData() else { return }
        uiImage = UIImage(data: data)
    }

    private func downloadImageData() -> Data? {

        guard let url = url else { return nil }
        let data = try? Data(contentsOf: url)
        return data
    }
}
