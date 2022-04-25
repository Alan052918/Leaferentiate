//
//  ContentView.swift
//  Leaferentiate
//
//  Created by Alan Ai on 2019/12/16.
//  Copyright © 2019 Alan Ai. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var image: Image? = Image("appface")
    @State private var commonName: String = "Leaferentiate"
    @State private var plantName: String = ""
    @State private var probability: String = ""

    @State private var showPhotoLibraryView: Bool = false
    @State private var showCameraView: Bool = false
    @State private var showProgressView: Bool = false
  
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                if (showProgressView) {
                    ProgressView()
                }
                
                Text(plantName)
                    .font(.caption)
                
                Text(commonName)
                    .font(.largeTitle)
                
                Text(probability)
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
            }
            .padding()
            .sheet(isPresented: $showPhotoLibraryView) {
                PhotoLibraryView(isShown: $showPhotoLibraryView, image: $image, showProgress: $showProgressView, commonName: $commonName, plantName: $plantName, probability: $probability)
            }

            if (showCameraView) {
                CameraView(isShown: $showCameraView, image: $image, showProgress: $showProgressView, commonName: $commonName, plantName: $plantName, probability: $probability)
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
