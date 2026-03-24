//
//  DebugLogs.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/22.
//

import Foundation
import SwiftUI
import UIKit

struct DebugLogs: View {
    @ObservedObject var ViewMemorySingleton = ViewMemory.shared
    var body: some View {
        List{
            PackagesAddon(Mode: "List", Details: DetailsType(Addon: ViewMemory.shared.Details.Addon))
            .cornerRadius(7)
            ForEach(ViewMemorySingleton.Details.Result, id: \.self) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.Log)
                            .font(.headline)
                            .foregroundColor(item.Log.contains("Success") || item.Log.contains("Optional") ? .green : .red)
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 5,
                                trailing: 0
                            ))
                        Text(MILocalizedString("Overwrite"))
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(item.Overwrite)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 5,
                                trailing: 0
                            ))
                        Text(MILocalizedString("Target"))
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(item.Target)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 5,
                                trailing: 0
                            ))
                        Text(item.FullLog)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(String(item.IsSuccess))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = item.Overwrite
                    } label: {
                        Label(MILocalizedString("Copy overwrite path"), systemImage: "doc.on.doc")
                    }
                    Button {
                        UIPasteboard.general.string = item.Target
                    } label: {
                        Label(MILocalizedString("Copy target path"), systemImage: "doc.on.doc")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(MILocalizedString("Debug Logs"))
    }
}
