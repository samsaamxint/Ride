//
//  SocketIOManager.swift
//  Ride
//
//  Created by Mac on 08/09/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import SocketIO
import CoreLocation

class SocketIOHelper: NSObject {
    static let shared = SocketIOHelper()
    
    var socket: SocketIOClient? = nil
    var socketManager = SocketManager(socketURL: URL(string: ServerUrls.BaseUrlSocket)!, config: [.log(false), .compress, .forceNew(true), .reconnects(true), .reconnectAttempts(-1)])

    var isUserSubscribe = false
    
    override init() {
        super.init()
        socket = socketManager.defaultSocket
    }
    
    func establishConnection() {
        socket?.connect()
        socket?.once(clientEvent: .connect) {data, ack in
            SLog("socket connected \(data)")
            //self.subscribeUser()
            self.isUserSubscribe = false
            if let mainVC = self.topMostViewController() as? MainDashboardViewController{
                mainVC.listenRequestForDriverAccept()
            }
        }
        
        socket?.once(clientEvent: .disconnect, callback: { _, _ in
            SLog("socket DISCONNECTED")
        })
        
        socket?.once(clientEvent: .reconnect, callback: { _, _ in
            SLog("socket reconnected")
        })
        
        self.socket?.on(clientEvent: .ping) {data, ack in
            SLog("socket ping client id === \(String(describing: self.socket?.sid))")
        }
        self.socket?.on(clientEvent: .pong) {data, ack in
            SLog("socket pong ack === \(ack.debugDescription)")
        }
        self.socket?.on(clientEvent: .error) {data, ack in
            SLog("socket error === \(data)")
        }
        self.socket?.on(clientEvent: .statusChange, callback: { [weak self] (data, ack) in
            guard let `self` = self else { return }
            SLog("socket status change === \(data)")
            if (self.socket?.status == .notConnected || self.socket?.status == .disconnected) && UIApplication.shared.applicationState == .active {
                if UserDefaultsConfig.isUserLoggedIn {
                    self.removeHandlerAndDefault()
                    self.establishConnection()
                }
            }
            if self.socket?.status == .connecting {
                self.removeHandlerAndDefault()
                self.establishConnection()
                self.isUserSubscribe = false
            }
            if self.socket?.status == .connected {
                self.subscribeUser()
                self.isUserSubscribe = true
            }
            
//            DispatchQueue.main.async { [weak self] in
//                guard let `self` = self else { return }
//                UIApplication.shared.statusBarUIView?.backgroundColor = self.socket?.status == .connected ? .green : .red
//            }
        })
        
        SocketIOHelper.shared.socket?.onAny({ event in
            if self.socket?.status == .connected {
                print("Check Status: \(event.description)")
            } else {
                print("Check Status (not connected): \(event.description)")
            }
        })
    }
    
    func subscribeUser() {
        let dict = NSMutableDictionary()
        dict.setValue(UserDefaultsConfig.user?.userId ?? "", forKey: "userID")
        SLog("subscribe-user dict ====== \(dict)")
        self.socket?.emit("subscribe-user", dict)
        
        self.socket?.once("user-general", callback: { (data, ack) in
            let dataInfo = data as NSArray
            if let info = dataInfo.object(at: 0) as? [String: AnyObject] {
                SLog("user general ====== \(info)")
            }
        })
        
        if let location = LocationManager.shared.locationManager?.location {
            SocketIOHelper.shared.updateCaptainLocation(driverId: UserDefaultsConfig.user?.userId ?? "", location: location)
        }
    }
    
    func removeHandlerAndDefault() {
        socket?.removeAllHandlers()
    }
    
    func listenChatEvent(eventName: String, completion: @escaping (ChatResponse) -> Void) {
        listenGenericEvent(eventName: eventName, completion: completion)
    }
    
    func listenFindDriverEvent(eventName: String, completion: @escaping (FindDriversReponse) -> Void) {
        listenGenericEvent(eventName: eventName, completion: completion)
    }
    
    func listenDriverAcceptEvent(eventName: String, completion: @escaping (TripDetailResponse) -> Void) {
        listenGenericEvent(eventName: eventName, completion: completion)
    }
    
    func listenTimeEstimateEvent(eventName: String, completion: @escaping (TimeEstimateResponse) -> Void) {
        listenGenericEvent(eventName: eventName, completion: completion)
    }
    
    func listenForCaptainLocationUpdate(eventName: String, completion: @escaping (DriverLocationDetailResponse) -> Void) {
        listenGenericEvent(eventName: eventName, completion: completion)
    }
    
    func emitEvent(eventName: String, dict: [String: Any]) {
        if socket?.status != .connected {
            socket?.connect()
            socket?.once(clientEvent: .connect, callback: { _, _ in
                self.socket?.emit(eventName, dict)
            })
            return
        }
        socket?.emit(eventName, dict)
        SLog("\(eventName) socket request === \(dict)")
    }
    
    private func listenGenericEvent<T: Codable>(eventName: String, completion: @escaping (T) -> Void) {
        socket?.on(eventName, callback: { data, ack in
            DispatchQueue.main.async {
                let dataInfo = data as NSArray
                if let info = dataInfo.object(at: 0) as? [String: AnyObject] {
                    do {
                        let dat = try JSONSerialization.data(withJSONObject: info)
                        let res = try JSONDecoder().decode(T.self, from: dat)
                        completion(res)
                    } catch {
                        SLog("find-driver socket error === \(error)")
                    }
                }
            }
        })
    }
    
    func updateCaptainLocation(driverId: String = "Should be driver's id from login user Object", location: CLLocation = LocationManager.shared.previousLocation ?? CLLocation(latitude: Double("0")!, longitude: Double("0")!)) { // TODO by Nabeel
        
        if socket?.status == SocketIOStatus.notConnected {
            self.removeHandlerAndDefault()
            self.establishConnection()
            return
        }
        let dict = NSMutableDictionary()
        dict.setValue(UserDefaultsConfig.user?.userId ?? "", forKey: "userID")
        let dataDict = NSMutableDictionary()
        dataDict.setValue(UserDefaultsConfig.user?.userId ?? "", forKey: "driverId")
        dataDict.setValue(location.coordinate.latitude, forKey: "latitude")
        dataDict.setValue(location.coordinate.longitude, forKey: "longitude")
        dict.setValue(dataDict, forKey: "data")
        if UserDefaultsConfig.isDriver {
            SLog("update-captain-location == \(dict.debugDescription)")
            self.socket?.emit("update-captain-location", dict)
        } else {
            SLog("update-customer-location == \(dict.debugDescription)")
            self.socket?.emit("update-customer-location", dict)
        }

    }
}
