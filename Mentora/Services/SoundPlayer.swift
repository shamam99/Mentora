//
//  SoundPlayer.swift
//  Mentora
//
//  Created by Shamam Alkafri on 19/05/2025.
//

import AVFoundation

class SoundPlayer {
    static let shared = SoundPlayer()
    private var player: AVAudioPlayer?

    private init() {}

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print(" Sound file \(name).wav not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print(" Failed to play sound \(name): \(error.localizedDescription)")
        }
    }
}
