//
//  DemoVideoView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 21/05/2025.
//

import SwiftUI
import AVKit

struct DemoVideoView: View {
    var body: some View {
        VideoPlayer(player: AVPlayer(url:  Bundle.main.url(forResource: "Demo", withExtension: "mp4")!))
            .edgesIgnoringSafeArea(.all)
    }
}
