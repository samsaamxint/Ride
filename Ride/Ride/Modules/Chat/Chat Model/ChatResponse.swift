//
//  ChatResponse.swift
//  Ride
//
//  Created by Ali Zaib on 11/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation

struct ChatResponse : Codable{
    var messageId : String?
    var timestamp : Double?
    var senderId : Int?
    var conversationId : String?
    var chatType : ChatType?
    var messageType : Int?
    var messageContent : String?
    var status : MessageStatus?
    var receiverId : Int?
    var workerId : Int?
    var receiver : ReceiverStatus?
}

struct ReceiverStatus : Codable{
    var status : MessageStatus?
}

struct ChatListResponse: Codable {
    var statusCode: Int?
    var message: String?
    var data: [ChatResponse]?
}

enum MessageStatus: Int, Codable {
    case pending = 0
    case sent = 1
    case delivered = 3
    case read = 4
    case notDefined = 2
}


enum ChatType: Int, Codable {
    case TEXT = 1
    case IMAGE = 2
    case VIDEO = 3
    case AUDIO = 4
    case FILE = 5
}

