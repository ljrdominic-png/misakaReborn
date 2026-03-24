//
//  AppIcon.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/07/07.
//

import SwiftUI

struct AppIcons_ST: Identifiable {
    var id = UUID()
    var imageName: String
    var Name: String
    var Author: String
    var Link: String
}

struct AppIconSelecter: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var AppIcons: [AppIcons_ST] = [
        AppIcons_ST(imageName: "Epos_misaka_pink_p1", Name: "Default 3.0 -", Author: "© EPOS", Link: "https://github.com/RealEPOS"),
        AppIcons_ST(imageName: "Epos_misaka_pink_p2", Name: "misaka Pink 2", Author: "© EPOS", Link: "https://twitter.com/RealEPOS"),
        AppIcons_ST(imageName: "BomberFish_misaka", Name: "2.0 - 3.0", Author: "© BomberFish (You seem to hate me and don't reply.)", Link: "https://github.com/BomberFish"),
        AppIcons_ST(imageName: "haxi0sm_misaka", Name: "1.0 - 1.8", Author: "© haxi0 (thanks♡)", Link: "https://twitter.com/haxi0sm"),
        AppIcons_ST(imageName: "nbxy_misaka_light", Name: "misaka Light", Author: "© uz.ra", Link: "https://twitter.com/ChromiumCandy"),
        AppIcons_ST(imageName: "nbxy_misaka_dark", Name: "misaka Dark", Author: "© uz.ra", Link: "https://twitter.com/ChromiumCandy"),
        AppIcons_ST(imageName: "nbxy_misaka_darklight", Name: "misaka DarkLight", Author: "© uz.ra", Link: "https://twitter.com/ChromiumCandy"),
        AppIcons_ST(imageName: "Janneske_misaka_ext_v01", Name: ".misaka ext01", Author: "© Janneske", Link: "https://twitter.com/jam_minty"),
        AppIcons_ST(imageName: "Janneske_misaka_ext_v02", Name: ".misaka ext02", Author: "© Janneske", Link: "https://twitter.com/jam_minty"),
        AppIcons_ST(imageName: "Outland3r2007_misakaS_blue", Name: "misakaS Blue", Author: "© Outland3r2007", Link: "https://twitter.com/Outland3r2007"),
        AppIcons_ST(imageName: "Outland3r2007_misakaS_brown", Name: "misakaS Brown", Author: "© Outland3r2007", Link: "https://twitter.com/Outland3r2007"),
        AppIcons_ST(imageName: "bytefrost_misaka", Name: "misaka", Author: "© bytefrost", Link: ""),
        AppIcons_ST(imageName: "tyler", Name: "misaka", Author: "© tyler", Link: "https://twitter.com/tyler10290"),
        AppIcons_ST(imageName: "tyler1029_misaka", Name: "misaka", Author: "© tyler", Link: "https://twitter.com/tyler10290"),
        AppIcons_ST(imageName: "phucdo_misaka", Name: "misaka", Author: "© Phuc Do", Link: "https://twitter.com/dobabaophuc"),
        AppIcons_ST(imageName: "phucdo_misaka_pink", Name: "misaka pink", Author: "© Phuc Do", Link: "https://twitter.com/dobabaophuc"),
        AppIcons_ST(imageName: "oktfrds_misaka", Name: "misaka", Author: "© oktfrds", Link: "https://twitter.com/oktfrds"),
        AppIcons_ST(imageName: "oktfrds_misaka2", Name: "misaka", Author: "© oktfrds", Link: "https://twitter.com/oktfrds"),
        AppIcons_ST(imageName: "oktfrds_misaka3", Name: "misaka", Author: "© oktfrds", Link: "https://twitter.com/oktfrds"),
        AppIcons_ST(imageName: "iwishkem_Lime", Name: "Lime", Author: "© iwishkem", Link: "https://twitter.com/iWishkem"),
        AppIcons_ST(imageName: "JannikCrack_FileSwitcherPro", Name: "FileSwitcherPro", Author: "© JannikCrack", Link: "https://twitter.com/JannikCrack"),
        AppIcons_ST(imageName: "AdelStar_misaka2", Name: "misaka", Author: "© AdelStar", Link: "https://twitter.com/adelmehenni4"),
        AppIcons_ST(imageName: "loy64_misaka", Name: "misaka pink", Author: "© Loy64", Link: "https://twitter.com/loy64_"),
        AppIcons_ST(imageName: "FileSwitcherPro3D", Name: "FileSwitcherPro 3D", Author: "© Janneske", Link: "https://twitter.com/jam_minty"),
        AppIcons_ST(imageName: "hackzy_classic", Name: "misaka classic", Author: "© HackZy", Link: "https://twitter.com/hackzy"),
        AppIcons_ST(imageName: "FileSwitcherProFlat", Name: "FileSwitcherPro Flat", Author: "© Janneske", Link: "https://twitter.com/jam_minty"),
        AppIcons_ST(imageName: "FileSwitcherProMono", Name: "FileSwitcherPro Mono", Author: "© Janneske", Link: "https://twitter.com/jam_minty"),
        AppIcons_ST(imageName: "YangJiii_yellow", Name: "misaka yellow", Author: "© YangJiii", Link: "https://twitter.com/duongduong0908"),
        AppIcons_ST(imageName: "YangJiii_purple", Name: "misaka purple", Author: "© YangJiii", Link: "https://twitter.com/duongduong0908"),
        AppIcons_ST(imageName: "AdelStar_misaka", Name: "misaka", Author: "© AdelStar", Link: "https://twitter.com/adelmehenni4"),
        AppIcons_ST(imageName: "FileSwitcherProAlt3D", Name: "FileSwitcherPro Alt3D", Author: "© Janneske", Link: "https://twitter.com/jam_minty"),
        AppIcons_ST(imageName: "FileSwitcherProAltFlat", Name: "FileSwitcherPro AltFlat", Author: "© Janneske", Link: "https://twitter.com/jam_minty"),
        AppIcons_ST(imageName: "FileSwitcherProAltMono", Name: "FileSwitcherPro AltMono", Author: "© Janneske", Link: "https://twitter.com/jam_minty")
    ]
    @State private var showingActionSheet = false
    @State private var ActionS: AppIcons_ST = AppIcons_ST(imageName: "", Name: "", Author: "", Link: "")
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            List {
                Section(header: Text("")) {
                    ForEach(AppIcons) { item in
                        if let path = Bundle.main.url(forResource: "\(item.imageName)", withExtension: "png"),
                           let data = try? Data(contentsOf: path),
                           let uiimage = UIImage(data: data) {
                            Button(action: {
                                ActionS = item
                                showingActionSheet = true
                            }) {
                                HStack {
                                    Image(uiImage: uiimage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(10)
                                        .padding(.trailing, 5)
                                    VStack(alignment: .leading) {
                                        Text(item.Name)
                                            .font(.headline)
                                        Text(item.Author)
                                            .font(.subheadline)
                                    }
                                }
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: 4,
                                    bottom: 0,
                                    trailing: 4
                                ))
                            }
                            .actionSheet(isPresented: $showingActionSheet) {
                                ActionSheet(title: Text(ActionS.Author), message: Text(ActionS.Name), buttons: [
                                    .default(Text("\(MILocalizedString("Author")) (\(ActionS.Author))")) {
                                        if let url = URL(string: ActionS.Link) {
                                            UIApplication.shared.open(url)
                                        }
                                    },
                                    .default(Text(MILocalizedString("Set"))) {
                                        UIApplication.shared.setAlternateIconName(ActionS.imageName) { error in
                                            if let e = error {
                                                print(e)
                                            }
                                        }
                                    },
                                    .cancel()
                                ])
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(MILocalizedString("App Icons"))
            .listStyle(SidebarListStyle())
        }
    }
}
