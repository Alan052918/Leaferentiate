//
//  PhotoLibraryView.swift
//  Leaferentiate
//
//  Created by Alan Ai on 2019/12/16.
//  Copyright © 2019 Alan Ai. All rights reserved.
//

import SwiftUI

struct PhotoLibraryView {
  
    /// MARK: - Properties
    @Binding var isShown: Bool
    @Binding var image: Image?
    @Binding var name: String
    @Binding var confidence: String
  
    func makeCoordinator() -> Coordinator {
        NSLog("PhotoLibraryView makeCoordinator invoked")
        return Coordinator(isShown: $isShown, image: $image, name: $name, confidence: $confidence)
    }
}

extension PhotoLibraryView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoLibraryView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        NSLog("PhotoLibraryView UIImagePickerController instantiated")
        picker.delegate = context.coordinator
        NSLog("PhotoLibraryView UIImagePickerController delegate coordinator assigned")
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        return picker
    }
  
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                              context: UIViewControllerRepresentableContext<PhotoLibraryView>) {
    
    }
}
