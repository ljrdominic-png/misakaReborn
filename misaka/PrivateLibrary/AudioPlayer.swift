//
//  AudioPlayer.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/07/01.
//

import Foundation
import AVFAudio
import UIKit

var sound: AVAudioPlayer?
func playSound(path: String) {
    do {
        if let url = URLwithEncode(string: path) {
            sound = try AVAudioPlayer(contentsOf: url)
            sound?.play()
        }
    } catch {
        UIApplication.shared.alert(body: error.localizedDescription)
        print("Could not find file")
    }
}

var loopsound: AVAudioPlayer?
func playLoopSound(path: String) {
    do {
        if let url = URLwithEncode(string: path) {
            loopsound = try AVAudioPlayer(contentsOf: url)
            loopsound?.numberOfLoops = -1
            loopsound?.play()
        }
    } catch {
        UIApplication.shared.alert(body: error.localizedDescription)
        print("Could not find file")
    }
}
