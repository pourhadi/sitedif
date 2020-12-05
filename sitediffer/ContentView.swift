//
//  ContentView.swift
//  sitediffer
//
//  Created by Daniel Pourhadi on 11/30/20.
//

import SwiftUI
import AppKit
import WebKit
import Combine

struct ContentView: View {
    @State var typedUrl: String = ""
    @State var currentUrl: String = ""
    @State var flag = 0
    @State var started = false
    var body: some View {
        VStack {
            Text("\(flag)")
            HStack {
                
                TextField("URL", text: $typedUrl, onCommit: {
                    currentUrl = typedUrl
                })
                Toggle("On", isOn: $started)
            }
            Spacer()
            GeometryReader { metrics in
                WebView(url: $currentUrl, started: $started, flag: $flag)
                    .frame(width: metrics.size.width, height: metrics.size.height)
            }
            .background(Color.blue)
            
            
        }
        .onReceive(Timer.publish(every: 15, on: .current, in: .common).autoconnect().receive(on: DispatchQueue.main), perform: { _ in
            self.flag += 1
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}

struct WebView : NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    @Binding var url: String
    @Binding var started: Bool
    
    @Binding var flag: Int
    
    func makeNSView(context: Context) -> WKWebView {
        let v = WKWebView(frame: .zero, configuration: .init())
        v.navigationDelegate = context.coordinator
        return v
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let goodUrl = URL(string:url), nsView.url != goodUrl {
            nsView.load(URLRequest(url: goodUrl))
        } else if started {
            nsView.reload()
        }
        
    }
    
    typealias NSViewType = WKWebView
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        var cancellable: AnyCancellable?
        init(_ parent: WebView) {
            self.parent = parent
            super.init()

        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print("didCommit")
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("startProvisional")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.url = webView.url?.absoluteString ?? ""
            
            webView.find("Unavailable for pickup at Apple Northbrook") { (result) in
                if !result.matchFound {
                    NSSound.beep()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        NSSound.beep()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            NSSound.beep()
                        })
                    })
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print(error)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }
        
    }
    
}
