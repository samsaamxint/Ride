//
//  ChatViewModel.swift
//  Ride
//
//  Created by Mac on 18/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import PromiseKit

protocol ChatVMProtocol: AnyObject {
    func getChatMessages(with receiverId: String)
    func addItemToChatList(with item: ChatResponse)
    func updateChatItem(with item: ChatResponse)
}

class ChatViewModel {
    final var isLoading: Combine<Bool> = Combine(false)
    final var messageWithCode: Combine<ErrorResponseWithCode> = Combine(ErrorResponseWithCode())
    final var getMessagesData: Combine<ChatListResponse> = Combine(ChatListResponse())
    
    private(set) var chats : [ChatResponse] = []
}

extension ChatViewModel: ChatVMProtocol{
    func addItemToChatList(with item: ChatResponse) {
        chats.insert(item, at: 0)
    }
    
    func updateChatItem(with item: ChatResponse) {
        if let index = self.chats.firstIndex(where: { $0.messageId == item.messageId }) {
            if item.status == .read {
                for i in index..<chats.count {
                    if chats[i].receiver?.status == .read {
                        break
                    }
                    chats[i].receiver?.status = item.receiver?.status
                }
            } else {
                chats[index].receiver?.status = item.receiver?.status
            }
            
        }
    }
    
    func updateLastChatItem(with item: ChatResponse) { // TODO
        if let index = self.chats.firstIndex(where: { $0.messageId == nil }) {
            chats[index] = item
        }
    }
    
    func getChatMessages(with receiverId: String) {
        isLoading.value = true
        
        ChatAPI.shared.getChatMessages(with: receiverId)
            .done { [weak self] (res) in
                self?.isLoading.value = false
                if res.statusCode == 201 || res.statusCode == 200 {
                    self?.chats = res.data ?? []
                    self?.getMessagesData.value = res
                } else {
                    self?.messageWithCode.value = ErrorResponseWithCode(message: res.message, code: res.statusCode)
                }
            }
            .catch { [weak self] (error) in
                self?.isLoading.value = false
                let myError = error as? RideError
                switch myError {
                case .errorWithCode(let message, let code):
                    self?.messageWithCode.value = ErrorResponseWithCode(message: message, code: code)
                default:
                    self?.messageWithCode.value = ErrorResponseWithCode(message: error.localizedDescription)
                }
            }
            .finally { [weak self] in
                self?.isLoading.value = false
            }
    }
}

class ChatAPI {
    static let shared = ChatAPI()
    
    func getChatMessages(with receiverId: String) -> Promise<ChatListResponse> {
        return Promise { seal in
            
            let request = EmptyRequest()

            Service.shared.request(withURL: ServerUrls.RideBASE_URL + RequestType.getChatList + "\(receiverId)", requestParams: request, method: "GET") { (response: Swift.Result<ChatListResponse, RideError>) in
                switch response {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
