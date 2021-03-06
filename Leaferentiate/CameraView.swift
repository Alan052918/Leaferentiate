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
    @Binding var name: String
    @Binding var confidence: String
    
    func makeCoordinator() -> Coordinator {
        NSLog("CameraView makeCoordinator invoked")
        return Coordinator(isShown: $isShown, image: $image, name: $name, confidence: $confidence)
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
