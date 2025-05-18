//
//  WinkyGIFView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//

import SwiftUI
import WebKit

struct WinkyGIFView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let path = Bundle.main.path(forResource: "winky", ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            webView.load(data, mimeType: "image/gif", characterEncodingName: "", baseURL: URL(fileURLWithPath: path))
        }
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
