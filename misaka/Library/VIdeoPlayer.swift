//
//  VIdeoPlayer.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/12.
//

import Foundation
import SwiftUI
import AVKit

struct VideoPlayer: View {
    @State var someVideoURL: URL
    
    var body: some View {
        VideoPlayerView(player: AVPlayer(url: someVideoURL))
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        player.isMuted = true // ミュートに設定
        player.automaticallyWaitsToMinimizeStalling = false
        player.play()

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {

    }
}
