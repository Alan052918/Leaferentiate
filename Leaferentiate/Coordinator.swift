//
//  Coordinator.swift
//  Leaferentiate
//
//  Created by Alan Ai on 2019/12/16.
//  Copyright © 2019 Alan Ai. All rights reserved.
//

import SwiftUI
import Foundation

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var isCoordinatorShown: Bool
    @Binding var imageInCoordinator: Image?
    @Binding var commonName: String
    @Binding var plantName: String
    @Binding var probability: String
    
    init(isShown: Binding<Bool>, image: Binding<Image?>, commonName: Binding<String>, plantName: Binding<String>, probability: Binding<String>) {
        _isCoordinatorShown = isShown
        _imageInCoordinator = image
        _commonName = commonName
        _plantName = plantName
        _probability = probability
        NSLog("Coordinator instantiated")
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrappedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            NSLog("Failed to unwrap image")
            return
        }
        NSLog("In imagePickerController unwrappedImage obtained")
        
        self.postData(image: unwrappedImage, postDataCompletionHandler: { jsonData, error in
            // Post request to server to upload image and get prediction result
            guard let jsonData = jsonData else {
                NSLog("Fail to unwrap jsonData")
                return
            }
            print("In imagePickerController postDataCompletionHandler got responseDictionary:\n\(jsonData)")
            
            let suggestions = jsonData["suggestions"] as! [[String: AnyObject]]
            
            let plantName = suggestions[0]["plant_name"] as! String
            NSLog("In imagePickerController postDataCompletionHandler got plantName: \(plantName)")
            
            let plantDetails = suggestions[0]["plant_details"] as! [String: AnyObject]
            
            let commonName = (plantDetails["common_names"] as! [String])[0]
            NSLog("In imagePickerController postDataCompletionHandler got commonName: \(commonName)")
            
            let probability = suggestions[0]["probability"] as! Double
            NSLog("In imagePickerController postDataCompletionHandler got probability: \(probability)")
            
            self.probability = "Confidence: " + String(format: "%.1f", probability * 100.0) + "%"
            
            let confidenceThreshold = 0.20
            if probability >= confidenceThreshold {
                self.plantName = "\"\(plantName)\""
                self.commonName = commonName
            } else {
                self.commonName = "Prediction unreliable"
            }
        })
        imageInCoordinator = Image(uiImage: unwrappedImage)
        isCoordinatorShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = false
    }

    func deserializeData(from jsonString: String) -> [String: AnyObject] {
        NSLog("In deserializeData got jsonString: \(jsonString)")
        guard let jsonData = jsonString.data(using: .utf8) else {
            NSLog("In deserializeData fail to get jsonData")
            return [String: AnyObject]()
        }
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject] else {
            NSLog("In deserializeData fail to decode JSON string")
            return [String: AnyObject]()
        }
        return json
    }
    
    func postData(image: UIImage, postDataCompletionHandler: @escaping ([String: AnyObject]?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            NSLog("Invalid image data")
            return
        }
        NSLog("In postData generated imageData: \(type(of: imageData)) \(imageData)")
        
        let parameters: [String: Any] = [
            "api_key": "Wqm1eyQdarRKxrKEV2JAsdfVM4WeasGtmoNgeln5R46QUlhU30",
            "images": [imageData.base64EncodedString()],
            // modifiers docs: https://github.com/flowerchecker/Plant-id-API/wiki/Modifiers
            "modifiers": ["crops_fast", "similar_images", "health_all", "disease_similar_images"],
            "plant_language": "en",
            // plant details docs: https://github.com/flowerchecker/Plant-id-API/wiki/Plant-details
            "plant_details": ["common_names"]
        ]
        
        let url = URL(string: "https://api.plant.id/v2/identify")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            let dataString = String(data: data, encoding: .utf8)
//            if let decodeResponse = self.getDictionaryFromJSONString(jsonString: dataString) {
//                re
//            }
//        } catch {
//            NSLog("In postData something went wrong")
//        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("In postData ERROR: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    NSLog("In postData response statusCode: \(response.statusCode)")
                    NSLog("In postData response allHeaderfields:\n\(response.allHeaderFields)")
                }
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    let jsonData = self.deserializeData(from: jsonString)
                    postDataCompletionHandler(jsonData, nil)
                    print("In postData got responseDictionary:\n\(jsonData)")
                }
            }
        }
        task.resume()
    }
}
