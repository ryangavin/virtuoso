//
//  SheetMusicRenderer.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 6/4/24.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let wkwebView = WKWebView()
        let request = URLRequest(url: url)
        wkwebView.load(request)
        return wkwebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct SheetMusicRenderer: View {
    var url = Bundle.main.url(forResource: "sheetMusicRenderer", withExtension: "html")!
    let mxlUrl = Bundle.main.url(forResource: "chopin", withExtension: "mxl")!

    init() {
        url.append(queryItems: [URLQueryItem(name: "url", value: mxlUrl.absoluteString)])
        print("SheetMusicRenderer URL: \(url)")
    }

    var body: some View {
        WebView(url: url)
    }
}

#Preview {
    SheetMusicRenderer()
        .glassBackgroundEffect()
}
