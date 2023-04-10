//
//  ProfileResponseModel.swift
//  Ride
//
//  Created by XintMac on 22/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct ProfileResponseModel: Codable {
    var statusCode: Int?
    var message: String?
    var data: UserProfile?
}

struct idData : Codable{
    var id : String?
    var status : String?
    var authStatus : String?
}

struct AttachmentInfo: Codable {
    var fileName: String?
    var apiKey : String?
    var url: URL?
    var data: Data?
    var mimeType: String?
}

struct UploadProfileImageRes: Codable {
    var statusCode: Int?
    var message: String?
    var data: UploadProfileData?
}

struct UploadProfileData: Codable {
    var profileImage: String?
    
}
