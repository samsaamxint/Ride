import Foundation
import UIKit
import Alamofire

var errorMessage = ""

enum RideError: Error {
    case forceUpdate
    case userNotFound
    case somethingWentWrong
    case internalError
    case noInternetConnection
    case decryptionProblem
    case remittanceNotAvailable
    case otherError(message:String)
    case wrongPin
    case errorWithCode(message: String, code: Int)
}

extension RideError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .forceUpdate:
            return AlertMessages.forceUpdate
        case .somethingWentWrong:
            return AlertMessages.somethingwrong
        case .internalError:
            return AlertMessages.somethingwrong
        case .noInternetConnection:
            return AlertMessages.noInternet
        case .decryptionProblem:
            return AlertMessages.decryptionError
        case .otherError:
            return errorMessage
        case .errorWithCode:
            return errorMessage
        case .remittanceNotAvailable:
            return AlertMessages.remittanceNotAvailable
        case .userNotFound:
            return ErrorCode.userNotFoundErrorCode
        case .wrongPin:
            return ErrorCode.wrongPin
        }
    }
}

class Service: NSObject {

    static let shared = Service()
    
    var errorCode: String = ""
    
    typealias Parameters = [String: String]
    
    fileprivate func parseData<T: Codable>(_ error: Error?, _ res: URLResponse?, _ data: Data?, completionHandler: @escaping (Swift.Result<T, RideError>) -> Void) {
        if error != nil {
            DispatchQueue.main.async {
                completionHandler(.failure(.somethingWentWrong))
            }
            return
        }
        
        let statusCode = (res as? HTTPURLResponse)?.statusCode ?? 505
        
        if statusCode == 440 {
            
            DispatchQueue.main.async {
                Commons.goToOnboarding()
            }
            return
        }
        
        if let data = data {
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.somethingWentWrong))
                    }
                    return
                }
                
                print("---------------- API RESPONSE ----------------")
                print(jsonResponse)
                
                if let status = jsonResponse["status"] as? String {
                    
                    if status == "ACTIVE" {
                        if statusCode == 201 || statusCode == 200 {
                            do {
                                print("---------------- API RESPONSE ----------------")
                                print(jsonResponse)
                                let dataReceived = try JSONDecoder().decode(T.self, from: data)
                                DispatchQueue.main.async {
                                    completionHandler(.success(dataReceived))
                                }
                            } catch let jsonErr {
                                DispatchQueue.main.async {
                                    completionHandler(.failure(.errorWithCode(message: jsonErr.localizedDescription , code: statusCode)))
                                }
                            }
                        }
                    } else if !status.uppercased().contains("FAIL") {
                        guard let encryptedResponse = jsonResponse["jsonResponse"] as? String else {
                            DispatchQueue.main.async {
                                completionHandler(.failure(.somethingWentWrong))
                            }
                            return
                        }
                    } else {
                        Commons.printLog(key: "Failed Response:", value: String(decoding: data, as: UTF8.self))
                        
                        DispatchQueue.main.async {
                            if let errorCode = jsonResponse["responseCode"] as? String, let errorMsg = jsonResponse["message"] as? String{
                                self.errorCode = errorCode
                                if errorCode == ErrorCode.forceUpdateErrorcode {
                                    //                                        Global.forceUpdateMessage = errorMsg
                                    completionHandler(.failure(.forceUpdate))
                                } else if errorCode == ErrorCode.userNotFoundErrorCode {
                                    errorMessage = ErrorCode.userNotFoundErrorCode
                                    completionHandler(.failure(.userNotFound))
                                }else if ErrorCode.remittanceNotAvailable.contains(errorCode) {
                                    errorMessage = ErrorCode.remittanceNotAvailable
                                    completionHandler(.failure(.remittanceNotAvailable))
                                } else if errorCode == ErrorCode.invalidSeasion {
                                    //                                        self.navigateToLogin()
                                } else if ErrorCode.wrongPin.contains(errorCode) {
                                    completionHandler(.failure(.wrongPin))
                                } else {
                                    errorMessage = errorMsg
                                    if errorMsg.isEmpty {
                                        errorMessage = AlertMessages.somethingwrong
                                    }
                                    completionHandler(.failure(.errorWithCode(message: errorMessage , code: statusCode)))
                                }
                            } else {
                                completionHandler(.failure(.somethingWentWrong))
                            }
                        }
                    }
                }else if let status = jsonResponse["success"] as? Bool {
                    do {
                        print("---------------- API RESPONSE ----------------")
                        print(jsonResponse)
                        let dataReceived = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completionHandler(.success(dataReceived))
                        }
                    } catch let jsonErr {
                        DispatchQueue.main.async {
                            completionHandler(.failure(.errorWithCode(message: jsonErr.localizedDescription , code: statusCode)))
                        }
                    }
                } else if let status = jsonResponse["status"] as? Int, status == 200 || status == 201{
                    do {
                        print("---------------- API RESPONSE ----------------")
                        print(jsonResponse)
                        let dataReceived = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completionHandler(.success(dataReceived))
                        }
                    } catch let jsonErr {
                        DispatchQueue.main.async {
                            completionHandler(.failure(.errorWithCode(message: jsonErr.localizedDescription , code: statusCode)))
                        }
                    }
                } else if let status = jsonResponse["code"] as? Int, status == 200 || status == 201{
                    do {
                        print("---------------- API RESPONSE ----------------")
                        print(jsonResponse)
                        let dataReceived = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completionHandler(.success(dataReceived))
                        }
                    } catch let jsonErr {
                        DispatchQueue.main.async {
                            completionHandler(.failure(.errorWithCode(message: jsonErr.localizedDescription , code: statusCode)))
                        }
                    }
                }
                else if let status = jsonResponse["statusCode"] as? Int, status == 200 || status == 201{
                    do {
                        print("---------------- API RESPONSE ----------------")
                        print(jsonResponse)
                        let dataReceived = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completionHandler(.success(dataReceived))
                        }
                    } catch let jsonErr {
                        DispatchQueue.main.async {
                            completionHandler(.failure(.errorWithCode(message: jsonErr.localizedDescription , code: statusCode)))
                        }
                    }
                } else if statusCode == 201 || statusCode == 200 {
                    do {
                        print("---------------- API RESPONSE ----------------")
                        print(jsonResponse)
                        let dataReceived = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completionHandler(.success(dataReceived))
                        }
                    } catch let jsonErr {
                        DispatchQueue.main.async {
                            completionHandler(.failure(.errorWithCode(message: jsonErr.localizedDescription , code: statusCode)))
                        }
                    }
                } else {
                    if let message = jsonResponse["message"] as? String {
                        DispatchQueue.main.async {
                            completionHandler(.failure(.errorWithCode(message: message, code: statusCode)))
                        }
                    } else if let messages = jsonResponse["message"] as? [String], let message = messages.first {
                        DispatchQueue.main.async {
                            completionHandler(.failure(.errorWithCode(message: message, code: statusCode)))
                        }
                    }
                }
            } catch let jsonErr {
                DispatchQueue.main.async {
                    print("Failed to serialize json:", jsonErr, jsonErr.localizedDescription)
                    completionHandler(.failure(.somethingWentWrong))
                }
            }
            
        }
    }
    
    /// Make a HTTP POST request to  server. Request param's must be encrypted using AES 256 algorithm.
    /// - Parameters:
    ///   - urlString: Host url to make HTTP request.
    ///   - requestParams: A Encodable request parameters object.
    ///   - isGetKeyRequest: A flag to identiy is request to be made for **GetKey** or rest of the all other API's as the response handeling for GetKey is bit different from other API's.
    ///   - offlineAccess: offlineAccess save response to storage, if network not available retrive from storage, future it will be move middleware concept
    ///   - completionHandler: Returns a decrypted Decodable response object or Error.
    func request<T: Codable, Q: Encodable>(withURL urlString: String, requestParams: Q, isGetKeyRequest: Bool = false, offlineAccess: Bool = false, method: String = "POST", completionHandler: @escaping (Swift.Result<T, RideError>) -> Void) {
        Commons.printLog(key: "API_URL", value: urlString)
        
        guard let url = URL(string: urlString) else {return}
        
        if Reachability.isConnectedToNetwork(){
            
//            if SocketIOHelper.shared.socket?.status != .connected {
//                SocketIOHelper.shared.establishConnection()
//            }

            var request = URLRequest(url: url)
            
            let param = requestParams.dictionary ?? [:]
            
            print("---------------- API REQUEST ----------------")
            print(param)
            
            do {
                //let encoded = try JSONSerializUIation.data(withJSONObject: param, options: [])
                let encoded = try JSONEncoder().encode(requestParams)
                request.httpBody = encoded
            } catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.somethingWentWrong))
                }
            }
            
            if method == "GET" {
                var components = URLComponents(string: urlString)!
                components.queryItems = param.map { (key, value) in
                    URLQueryItem(name: key, value: value as? String)
                }
                components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
                request = URLRequest(url: components.url!)
            }
            request.httpMethod = method
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("*/*", forHTTPHeaderField: "Accept")
            request.addValue(UserDefaultsConfig.sessionID, forHTTPHeaderField:"sessionid")
            request.timeoutInterval = 60
            
            //mock headers
            if method == "POST"{
                request.addValue("true", forHTTPHeaderField: "x-mock-match-request-headers")
                request.addValue("true", forHTTPHeaderField: "x-mock-response-code")
                request.addValue("true", forHTTPHeaderField: "x-mock-match-request-body")
            }


            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60
            sessionConfig.timeoutIntervalForResource = 60
            sessionConfig.urlCredentialStorage = nil
            let session = URLSession(configuration: sessionConfig)
            //            let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: .main)
            session.dataTask(with: request) { [weak self] (data, res, error) in
                guard let `self` = self else { return }
                self.parseData(error, res, data, completionHandler: completionHandler)
            }.resume()
        } else {
            completionHandler(.failure(.noInternetConnection))
        }
    }

    /// Make a HTTP POST request to  DirecPay server. Request param's must be encrypted using AES 128 algorithm without IV and new rounds of encryption
    /// - Parameters:
    ///   - urlString: Host url to make HTTP request.
    ///   - requestParams: A Encodable request parameters object.
    ///   - completion: Returns a decrypted Decodable response object or Error.
    func requestDPServer<T: Decodable>(withURL urlString: String, requestParams: String, completionHandler: @escaping (Swift.Result<T, RideError>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            
            if SocketIOHelper.shared.socket?.status != .connected && !UserDefaultsConfig.sessionID.isEmpty {
                SocketIOHelper.shared.establishConnection()
            }

            Commons.printLog(key: "API_URL", value: urlString)

            guard let url = URL(string: urlString) else {return}

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 60
            request.httpBody = requestParams.data(using: .utf8)

            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60
            sessionConfig.timeoutIntervalForResource = 60
            sessionConfig.urlCredentialStorage = nil
            let session = URLSession(configuration: sessionConfig)
            //            let session = URLSession(configurat`ion: sessionConfig, delegate: self, delegateQueue: .main)
            session.dataTask(with: request) { (data, _, error) in

                if error != nil {
                    completionHandler(.failure(.somethingWentWrong))
                    return
                }

                if let data = data {
                    guard let response = String.init(data: data, encoding: .utf8) else {
                        completionHandler(.failure(.somethingWentWrong))
                        return
                    }

                    let strResponse = response.replacingOccurrences(of: "\r\n", with: "") 

                    Commons.printLog(key: "Encrtypted Response DP:", value: strResponse)

//                    guard let jsonResponse = strResponse.decryptResponseForDPCards() else {
//                        completionHandler(.failure(.decryptionProblem))
//                        return
//                    }

//                    if let status = jsonResponse["status"] as? String {
//                        if status.uppercased().contains("SUCCESS") {
//                            do {
//
//                                let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse, options: .prettyPrinted)
//
//                                let dataReceived = try JSONDecoder().decode(T.self, from: jsonData)
//
//                                Commons.printLog(key: "Response", value: String(decoding: jsonData, as: UTF8.self))
//
//                                completionHandler(.success(dataReceived))
//
//                            } catch let jsonErr {
//                                print("Failed to serialize json:", jsonErr, jsonErr.localizedDescription)
//                                completionHandler(.failure(.somethingWentWrong))
//                            }
//                        } else {
//
//                            Commons.printLog(key: "Failed Response:", value: String(decoding: data, as: UTF8.self))
//
//                            if let errorMsg = jsonResponse["statusMessage"] as? String{
//                                errorMessage = errorMsg
//                                completionHandler(.failure(.otherError(message:errorMsg)))
//                            } else {
//                                completionHandler(.failure(.somethingWentWrong))
//                            }
//                        }
//                    } else {
//                        completionHandler(.failure(.somethingWentWrong))
//                    }
                }
            }.resume()
        } else {
            completionHandler(.failure(.noInternetConnection))
        }
    }
    
    // Multipart request
    public func sendUploadRequest<T: Codable, Q: Encodable>(
        withURL urlString: String,
        requestParams: Q,
        isGetKeyRequest: Bool = false,
        offlineAccess: Bool = false,
        method: String = "POST",
        paramters: [String:Any]? = nil,
        imagesKey: String? = nil,
        videoKey: String? = nil,
        image: Data? = nil,
        imageKey: String? = nil,
        videoData: Data? = nil,
        documentData: Data? = nil,
        imagesArr: [UIImage]? = nil,
        videosKey: String? = nil,
        videosArr: [Data]? = nil,
        documentKey: String? = nil,
        documentArr: [Data]? = nil,
        timeoutInterval: Double = 60,
        callBack: @escaping (Swift.Result<T, RideError>) -> Void) {
            
            guard let url = URL(string: urlString) else {return}
            
            var URL = try! URLRequest(url: url, method: (HTTPMethod(rawValue: method)!), headers: authHeader(isMultipart: true))
            
            print("\n\n------------Requested URL-------------\n\n")
            print(urlString as Any)
            
            print("\n\n------------Request Body-------------\n\n")
            print(paramters as Any)
            
            URL.timeoutInterval = timeoutInterval
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                if paramters != nil {
                    for (key, value) in paramters! {
                        if let value = value as? String {
                            if let data = value.data(using: .utf8) {
                                multipartFormData.append(data, withName: key)
                            }
                        }
                        
                        if let values = value as? [String] {
                            for (i, stringValue) in values.enumerated() {
                                if let data = stringValue.data(using: .utf8) {
                                    multipartFormData.append(data, withName: (key + "[" + String(i) + "]"))
                                }
                            }
                        }
                        
                        if let data = value as? Data {
                            multipartFormData.append(data, withName: key, fileName: "image.jpg", mimeType: "image/jpg")
                        }
                        
                        if let values = value as? [Data] {
                            for (i, data) in values.enumerated() {
                                multipartFormData.append(data, withName: (key + "[" + String(i) + "]"))
                            }
                        }
                    }
                }
                
                if videoData != nil {
                    multipartFormData.append(videoData!, withName: videoKey!, fileName: "file.mp4", mimeType: "video/mp4")
                }
                
                if documentData != nil {
                    multipartFormData.append(documentData!, withName: documentKey!, fileName: "docuement.pdf", mimeType: "application/pdf")            }
                
                if image != nil && imageKey != nil {
                    multipartFormData.append(image!, withName: imageKey!, fileName: "image.jpg", mimeType: "image/jpg")
                }
                
                if imagesArr != nil {
                    for i in 0..<imagesArr!.count {
                        let timestamp = "\(Date().timeIntervalSince1970)"
                        multipartFormData.append(imagesArr![i].jpegData(compressionQuality: 0.8)!, withName: imagesKey! + "[\(i)]", fileName: "\(timestamp)image.jpg", mimeType: "image/jpeg")
                    }
                }
                
                if videosArr != nil {
                    for i in 0..<videosArr!.count {
                        let timestamp = "\(Date().timeIntervalSince1970)"
                        multipartFormData.append(videosArr![i], withName: videosKey! + "[\(i)]", fileName: "\(timestamp)file.mp4", mimeType: "video/mp4")
                    }
                }
                
                if documentArr != nil {
                    for i in 0..<documentArr!.count {
                        let timestamp = "\(Date().timeIntervalSince1970)"
                        multipartFormData.append(documentArr![i], withName: documentKey! + "[\(i)]", fileName: "\(timestamp)docuement.pdf", mimeType: "application/pdf")
                    }
                }
                
            }, with: URL, encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { res in
                        self.parseData(res.error, res.response, res.data, completionHandler: callBack)
                    }
                case .failure(let encodingError):
                    callBack(.failure(RideError.errorWithCode(message: encodingError.localizedDescription, code: 400)))
                    print(encodingError)
                }
            }
            )
        }
    
    func authHeader(isMultipart: Bool = false) -> [String:String] {
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        var headers = ["DeviceID":"iOS - \(deviceID)"]
        headers["sessionid"] =  UserDefaultsConfig.sessionID
        headers["Accept"] = "application/json"
        headers["device-type"] = "iOS"
        headers["Connection"] = "Keep-alive"
        if isMultipart {
            headers["Content-type"] = "multipart/form-data"
        } else {
            headers["Content-Type"] = "application/json"
        }
        return headers
    }



    /// Makes a multipart request to server to upload the profile picture
    /// - Parameters:
    ///   - url: Host url to make multipart request.
    ///   - parameters: request body of the multipart request
    ///   - imageMediaArray: Array of media objects. Currenlty Media only supports image of JPEG type
    ///   - completionHandler: Returns a decrypted Decodable response object or Error.
//    func requestMultiPartWith(url: String, parameters: Parameters, imageMediaArray:[Media], completionHandler: @escaping (Swift.Result<ProfilePictureUploadResponse, RideError>) -> Void) {
//
//        #if DEBUG
//        print("\n\nMultipart request: \(parameters))")
//        #endif
//
//        guard let url = URL(string: url) else {
//            completionHandler(.failure(.somethingWentWrong))
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let boundary = generateBoundary()
//
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-type")
//        //        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
//
//        let dataBody = createDataBody(withParameters: parameters, media: imageMediaArray, boundary: boundary)
//        request.httpBody = dataBody
//
//        let session = URLSession.shared
//        session.dataTask(with: request) { (data, response, error) in
//            if let _ = error {
//                completionHandler(.failure(.somethingWentWrong))
//            }
//
//            if let data = data {
//                do {
//                    Utility.printLog(key: "Multipart Response", value: String(decoding: data, as: UTF8.self))
//                    let dataReceived = try JSONDecoder().decode(ProfilePictureUploadResponse.self, from: data)
//                    completionHandler(.success(dataReceived))
//                } catch {
//                    completionHandler(.failure(.somethingWentWrong))
//                }
//            }
//        }.resume()
//    }

    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

//    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
//
//        let lineBreak = "\r\n"
//        var body = Data()
//
//        if let parameters = params {
//            for (key, value) in parameters {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//                body.append("\(value + lineBreak)")
//            }
//        }
//
//        if let media = media {
//            for photo in media {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
//                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
//                body.append(photo.data)
//                body.append(lineBreak)
//            }
//        }
//
//        body.append("--\(boundary)--\(lineBreak)")
//
//        return body
//    }
}

extension Service: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)

                if errSecSuccess == status {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData)
                        let size = CFDataGetLength(serverCertificateData)
                        let cert1 = NSData(bytes: data, length: size)
//                        let fileName = Global.certificateName
//                        let fileDer = Bundle.main.path(forResource: fileName, ofType: "cer")
//
//                        if let file = fileDer {
//                            if let cert2 = NSData(contentsOfFile: file) {
//                                if cert1.isEqual(to: cert2 as Data) {
//                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
//                                    return
//                                }
//                            }
//                        }
                    }
                }
            }
        }

        // Pinning failed
        Commons.printLog(key: "SSL Pinning", value: "Failed")
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }

}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: [])).flatMap { $0 as? [String: Any] }
  }
}
