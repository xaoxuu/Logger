//
//  ContentView.swift
//  Logger
//
//  Created by xaoxuu on 2020/6/6.
//  Copyright © 2020 xaoxuu.com. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isSharePresented: Bool = false

    var body: some View {
        VStack {
            Button("输出普通日志") {
                Logger("输出普通日志")
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(4)
            .padding()
            
            Button("⚠️ 输出警告") {
                Logger(level: .warning, "这是一条警告消息")
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(4)
            .padding()
            
            Button("❗️ 输出错误") {
                Logger(level: .error, "这里发生了错误")
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(4)
            .padding()
            
            Button("‼️ 输出致命错误") {
                Logger(level: .critical, "这里发生了致命错误")
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(4)
            .padding()
             
            Button("分享最近7天的日志") {
                self.isSharePresented = true
            }
            .sheet(isPresented: $isSharePresented, onDismiss: {
                print("Dismiss")
            }, content: {
                ShareVC()
            })
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(4)
            .padding()
  
        }
        
    }
    
    
    
}

struct ShareVC: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIActivityViewController {
        Logger.share(count: 7)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .padding(16)
    }
}
