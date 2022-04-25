//
//  CameraView.swift
//  Leaferentiate
//
//  Created by Alan Ai on 2019/12/16.
//  Copyright © 2019 Alan Ai. All rights reserved.
//

import SwiftUI

struct CameraView {
    
    /// MARK: - Properties
    @Binding var isShown: Bool
    @Binding var image: Image?
    @Binding var showProgress: Bool
    @Binding var commonName: String
    @Binding var plantName: String
    @Binding var probability: String
    
    func makeCoordinator() -> Coordinator {
        NSLog("CameraView makeCoordinator invoked")
        return Coordinator(isShown: $isShown, image: $image, showProgress: $showProgress, commonName: $commonName, plantName: $plantName, probability: $probability)
    }
}

extension CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        NSLog("CameraView UIImagePickerController instantiated")
        picker.delegate = context.coordinator
        NSLog("CameraView UIImagePickerController delegate coordinator assigned")
        picker.sourceType = UIImagePickerController.SourceType.camera
        return picker
    }
  
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                              context: UIViewControllerRepresentableContext<CameraView>) {
    
    }
}
