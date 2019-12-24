//
//  ContentView.swift
//  Leaferentiate
//
//  Created by Alan Ai on 2019/12/16.
//  Copyright © 2019 Alan Ai. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @State private var showPhotoLibraryView: Bool = false
    @State private var showCameraView: Bool = false
    @State private var image: Image? = Image("appface")
    @State private var name: String = "Leaferentiate"
    @State private var confidence: String = ""
  
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Text(name)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                
                Text(confidence)
                    .italic()

                image?
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .padding()
                
                Button(action: {
                    self.showCameraView.toggle()
                }) {
                    Text("Capture by camera")
                        .padding(10)
                        .background(Color.green)
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
                .padding(5)
                
                Button(action: {
                    self.showPhotoLibraryView.toggle()
                }) {
                    Text("Select from photos")
                        .padding(10)
                        .background(Color.green)
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
                .padding(5)
                
                Spacer()
                Text("A course project app for")
                    .font(.footnote)
                Text("SUSTech CS303 Artificial Intelligence")
                    .font(.footnote)
            }
            .padding()
            .sheet(isPresented: $showPhotoLibraryView) {
                PhotoLibraryView(isShown: self.$showPhotoLibraryView, image: self.$image, name: self.$name, confidence: self.$confidence)
            }

            if (showCameraView) {
                CameraView(isShown: self.$showCameraView, image: self.$image, name: self.$name, confidence: self.$confidence)
                    .statusBar(hidden: true)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
