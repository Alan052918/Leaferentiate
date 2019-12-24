//
//  Coordinator.swift
//  Leaferentiate
//
//  Created by Alan Ai on 2019/12/16.
//  Copyright © 2019 Alan Ai. All rights reserved.
//

import SwiftUI

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var isCoordinatorShown: Bool
    @Binding var imageInCoordinator: Image?
    @Binding var name: String
    @Binding var confidence: String
    
    init(isShown: Binding<Bool>, image: Binding<Image?>, name: Binding<String>, confidence: Binding<String>) {
        _isCoordinatorShown = isShown
        _imageInCoordinator = image
        _name = name
        _confidence = confidence
        NSLog("Coordinator instantiated")
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        NSLog("In imagePickerController unwrapImage obtained")
        
        // Post request to server to get token
        getToken(getTokenCompletionHandler: { token, error in
            NSLog("In imagePickerController getTokenCompletionHandler got token:\n\(token!)")
            
            // Post request to server to upload image and get prediction result
            self.postData(image: unwrapImage, token: token!, postDataCompletionHandler: { responseDictionary, error in
                NSLog("In imagePickerController getTokenCompletionHandler postDataCompletionHandler got responseDictionary:\n\(responseDictionary!)")
                guard let responseDictionary = responseDictionary else { return }
                guard let predictResult = responseDictionary["predicted_label"] else { return }
                let scores = responseDictionary["scores"] as! Array<Array<Any>>
                let scoreString = scores[0][1] as! String
                let scoreDouble = Double(scoreString)!
                let resultScore = scoreDouble * 100.0
                self.confidence = "Confidence: " + String(format: "%.1f", resultScore) + "%"
                
                let confidenceThreshold = 20.0
                if resultScore >= confidenceThreshold {
                    self.name = predictResult as! String
                } else {
                    self.name = "Prediction unreliable"
                }
            })
            NSLog("In imagePickerController getTokenCompletionHandler successfully posted image to server")
        })
        imageInCoordinator = Image(uiImage: unwrapImage)
        isCoordinatorShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = false
    }

    func getToken(getTokenCompletionHandler: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://iam.myhuaweicloud.com/v3/auth/tokens")!
        let str = "{\"auth\": {\"identity\": {\"methods\": [\"password\"],\"password\": {\"user\": {\"name\": \"hw64561319\",\"password\": \"Ccc668123\",\"domain\": {\"name\": \"hw64561319\"}}}},\"scope\": {\"project\": {\"name\": \"cn-north-4\"}}}}"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        request.httpBody = str.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("In getToken ERROR: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    NSLog("In getToken response statusCode: \(response.statusCode)")
                    let token = response.value(forHTTPHeaderField: "X-Subject-Token")
                    getTokenCompletionHandler(token, nil)
                    NSLog("In getToken got token:\n\(token!)")
                }
            }
        }
        task.resume()
    }

    func getDictionaryFromJSONString(jsonString: String) -> NSDictionary {

        let jsonData: Data = jsonString.data(using: .utf8)!

        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }

    func imageToFormData(imageData: Data, boundary: String) -> Data {
        var formData = Data()
        
        formData.append(contentsOf: "--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        formData.append(contentsOf: "Content-Disposition: form-data; name=\"images\"; filename=\"user-uploaded-image.jpeg\"\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        formData.append(contentsOf: "Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        formData.append(imageData)
        formData.append(contentsOf: "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        formData.append(contentsOf: "--\(boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        return formData
    }
    
    func postData(image: UIImage, token: String, postDataCompletionHandler: @escaping (NSDictionary?, Error?) -> Void) {
        let url = URL(string: "https://86428c8b9e214002ae06f52a64636e82.apigw.cn-north-4.huaweicloud.com/v1/infers/cfc77979-37ee-417d-9a96-231c60809005")!
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        NSLog("In postData generated imageData: \(type(of: imageData)) \(imageData)")
        let bodyFormData = imageToFormData(imageData: imageData, boundary: boundary)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "X-Auth-Token")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(String(bodyFormData.count), forHTTPHeaderField: "Content-Length")
        request.httpBody = bodyFormData

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("In postData ERROR: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    NSLog("In postData response statusCode: \(response.statusCode)")
                    NSLog("In postData response allHeaderfields:\n\(response.allHeaderFields)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let responseDictionary = self.getDictionaryFromJSONString(jsonString: dataString)
                    postDataCompletionHandler(responseDictionary, nil)
                    NSLog("In postData got responseDictionary:\n\(responseDictionary)")
                }
            }
        }
        task.resume()
    }
}
