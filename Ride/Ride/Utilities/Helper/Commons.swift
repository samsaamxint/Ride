//
//  Commons.swift
//  Ride
//
//  Created by Mac on 02/08/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps
import Kingfisher
import Adjust


class Commons {
    
    //var player: AVAudioPlayer!
    
    static func showErrorMessage(controller: UIViewController, backgroundColor: UIColor = .ErrorRedLight, textColor: UIColor = .errorRed, message: String, timerInterval: TimeInterval = 3) {
        
        if let errorView = controller.view.viewWithTag(CustomTag.ErrorviewTag) {
            errorView.removeFromSuperview()
        }
        
        let errorImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        errorImageView.image = UIImage(named: "ErrorIcon")
        errorImageView.tintColor = textColor
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        errorImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.font = UIFont.SFProDisplayMedium?.withSize(13)
        messageLbl.textColor = textColor
        messageLbl.numberOfLines = 2
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = backgroundColor
        backgroundView.cornerRadius = 8
        backgroundView.tag = CustomTag.ErrorviewTag
        
        controller.view.addSubview(backgroundView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -(getSafeAreaInset().top  + 15)).isActive = true
        controller.view.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: -15).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 15).isActive = true
        
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        stackView.addArrangedSubview(errorImageView)
        stackView.addArrangedSubview(messageLbl)
        
        backgroundView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -15).isActive = true
        stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -15).isActive = true
        
        let y = -getSafeAreaInset().top - 100
        backgroundView.transform = CGAffineTransform(translationX: 0, y: y)
        
        UIView.animate(withDuration: 0.5) {
            backgroundView.transform = .identity
        } completion: { finished in
            Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: false) { _ in
                UIView.animate(withDuration: 0.5) {
                    backgroundView.transform = CGAffineTransform(translationX: 0, y: y)
                }
            }
        }
    }
    
    static func printLog(key: String, value: Any) {
        print("\(key) = ")
        print("\(value)\n\n\n")
    }
    
    static func getSafeAreaInset() -> UIEdgeInsets {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    static func goToMain(type: DashboardType , isSignUp : Bool = false) {
        UserDefaultsConfig.isUserLoggedIn = true
        UserDefaultsConfig.isDriver = type != .rider
        
        //        Constants.userID = type == .rider ? Constants.riderID : Constants.driverID
        //        Constants.sessionID = type == .rider ? Constants.riderSessionId : Constants.driverSessionId
        //
        //        if type == .driver {
        //            Constants.driverID = UserDefaultsConfig.driverID
        //            Constants.driverSessionId = UserDefaultsConfig.driverSessionID
        //
        //            Constants.userID = Constants.driverID
        //            Constants.sessionID = Constants.driverSessionId
        //        }else{
        ////            Constants.riderID = UserDefaultsConfig.riderID
        ////            Constants.riderSessionId = UserDefaultsConfig.riderSessionID
        //
        //            Constants.userID = Constants.riderID
        //            Constants.sessionID = Constants.riderSessionId
        //        }
        SocketIOHelper.shared.establishConnection()
        if let vc: MainDashboardNavViewController = UIStoryboard.instantiate(with: .mainDashboard) {
            vc.type = type
//            if type == DashboardType.rider{
//                UserDefaultsConfig.isRider = true
//            }
            vc.isFromSignup = isSignUp
            if let window =  UIApplication.shared.windows.first{
                window.rootViewController?.dismiss(animated: false, completion: nil)
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                               window.rootViewController = vc
                           }, completion: nil)
            }
//            UIApplication.shared.windows.first?.rootViewController = vc
//            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
       
               
    }
    
    static func goToOnboarding(isLogout : Bool = false) {
        UserDefaultsConfig.isUserLoggedIn = false
        UserDefaultsConfig.isDriver = false
        UserDefaultsConfig.tripId = nil
        UserDefaultsConfig.rideCount = 0
        UserDefaultsConfig.isRiderKYCRequired = true
        UserDefaultsConfig.subscriptionId = ""
        UserDefaultsConfig.carSequenceNo = ""
        UserDefaultsConfig.carPlateNo = ""
        UserDefaultsConfig.cab = ""
        UserDefaultsConfig.carLicenceType = nil
        
        globalMobileNumber = nil
        //self.isUserSubscribe = false
        UserDefaultsConfig.user = nil
        
        SocketIOHelper.shared.socket?.disconnect()
        SocketIOHelper.shared.socket?.removeAllHandlers()
        SocketIOHelper.shared.isUserSubscribe = false
        
        UserDefaultsConfig.sessionID = ""
        
        if let vc: OnboardingViewController = UIStoryboard.instantiate(with: .onboarding) {
            vc.isLogout = isLogout
            DispatchQueue.main.async {
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }
    
    static func isArabicLanguage() -> Bool {
        let language = (UserDefaults.standard.value(forKey: languageKey) as? String) ?? "en"
        return language == "ar"
    }
    
    // Validates the enail address returns true or false
    /// - Parameter email: Pass the email-id to be validated
    static func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func geocodeAddressFromGoogleMap(lat: Double, lng: Double, completion: @escaping (String) -> Void){
        GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: lat,
                                                                      longitude: lng)) { res, error in
            if let address = res?.firstResult(), let lines = address.lines {
                let address = lines.joined(separator: ", ")
                completion(address)
            } else {
                completion("Unnamed Location")
            }
        }
    }
    
    static func geocode(latitude: Double, longitude: Double, localeIdentifier: String = "en", completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), preferredLocale: Locale(identifier: localeIdentifier)) { completion($0?.first, $1) }
    }
    
    static func getAddressStrFromPlaceMark(place: CLPlacemark?) -> String {
        if let place = place {
            
            var addressStr = ""
            if let name = place.name {
                addressStr = name
            }
            
            if let subLocality = place.subLocality {
                addressStr += addressStr.isEmpty ? subLocality : ", \(subLocality)"
            }
            
            if let locality = place.locality {
                addressStr += addressStr.isEmpty ? locality : ", \(locality)"
            }
            return addressStr
        }
        return ""
    }
    
    static func getAddressFrom(location: CLLocation, identifier: String = "en", completion: @escaping (String) -> Void){
        geocode(latitude: location.coordinate.latitude ,
                longitude: location.coordinate.longitude ,
                localeIdentifier: identifier) { placemark, error in
            guard error.isNone else {
                completion("")
                return
            }
            
            completion(getAddressStrFromPlaceMark(place: placemark))
        }
    }
    
    static func getRouteSteps(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, mode: String = "driving",needSnapShot : Bool = false, isDrawPolyLine: Bool = false , isUpdateDistance: Bool = false, onCompletionBlock: ((GMSPolyline?, [GMSPolyline]?, RouteData?) -> Void)?) {
        
        
        
        
        let previousPath = PathSave.shared
        if !isDrawPolyLine && previousPath.isSetValues() {
            if isUpdateDistance {
                onCompletionBlock!(nil, nil, nil)
            } else {
                onCompletionBlock!(previousPath.getPolyline(), previousPath.getPolylineArray(), previousPath.getRouts())
            }
//
            
            return
        }
        
        //        self.route = nil
        let objRoute = RouteData()
        let session = URLSession.shared
        UserDefaults.standard.setValue(((UserDefaults.standard.integer(forKey: "directionsCount")) + 1), forKey: "directionsCount")
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=\(mode)&key=\(APIKeys.GooglePlacesKey)&language=\(Commons.isArabicLanguage() ? "ar" : "en")")!
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                DLog(error!.localizedDescription)
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            /*if let responseString = NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue) {
             }*/
            
            guard let routes = jsonResult["routes"] as? [Any], routes.count > 0 else {
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            guard let legs = route["legs"] as? [Any] else {
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            guard let leg = legs[0] as? [String: Any] else {
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            if let obj = leg["distance"] as? [String: Any], let dist = obj["text"] as? String, let travelDistance = obj["value"] as? Int {
                objRoute.routeDistanceValue = travelDistance
                objRoute.routeDistance = dist
            }
            
            if let obj = leg["duration"] as? [String: Any], let timee = obj["text"] as? String, let travelDurationn = obj["value"] as? Int {
                objRoute.travelTime = timee
                objRoute.travelDuration = travelDurationn
                //DLog("objRoute.travelTime ==== \(objRoute.travelTime)")
                //DLog("objRoute.travelDuration ==== \(objRoute.travelDuration)")
            }
            
            var points = ""
            if let overview = route["overview_polyline"] as? [String: Any], let point = overview["points"] as? String {
                objRoute.points = point.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                points = point
            }
            
            if points.count > 0 {
                objRoute.points = points.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                
                if needSnapShot {
                    //self.route = objRoute
                    
                    objRoute.staticDriverImageURL = Commons.getStaticImageUrl(routePoint: "\(objRoute.points)", sourceLat: source.latitude, sourceLong: source.longitude, destLat: destination.latitude, destLong: destination.longitude,isDriver: true,type: RideSingleton.shared.tripDetailObject?.data?.status?.rawValue ?? 1)
                    objRoute.staticRiderImageURL = Commons.getStaticImageUrl(routePoint: "\(objRoute.points)", sourceLat: source.latitude, sourceLong: source.longitude, destLat: destination.latitude, destLong: destination.longitude,isDriver: false,type: RideSingleton.shared.tripDetailObject?.data?.status?.rawValue ?? 1)
                    print("")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        Commons.uploadStaticImageOfMap(type: UserDefaultsConfig.isDriver ? 5 : 4, imageStr: objRoute.staticRiderImageURL , route : objRoute)
                    })
                }
            }
            
            guard let steps = leg["steps"] as? [[String: Any]] else {
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            guard let step = steps.first else {
                onCompletionBlock!(nil, nil, objRoute)
                return
            }
            
            if let obj = step["distance"]  as? [String: Any] {
                objRoute.travelInstruction = obj["text"]  as? String ?? ""
            }
            
            DispatchQueue.main.async {
                
                let routes : NSArray = jsonResult["routes"] as? NSArray ?? []
                if(jsonResult["status"] as? String == "ZERO_RESULTS"){}
                else if(jsonResult["status"] as? String == "NOT_FOUND"){}
                else if routes.count == 0{}
                else{
                    let routes : NSArray = jsonResult["routes"] as? NSArray ?? []
                    let pathv : NSArray = routes.value(forKey: "overview_polyline") as? NSArray ?? []
                    let paths : NSArray = pathv.value(forKey: "points") as? NSArray ?? []
                    let newPath = GMSPath.init(fromEncodedPath: paths[0] as? String ?? "")
                    let polyLine = GMSPolyline(path: newPath)
                    polyLine.strokeColor = UIColor.primaryGreen
                    polyLine.strokeWidth = 3.0
                    let rideLightGreen = GMSStrokeStyle.solidColor( .primaryGreen)
                    let LgreenTodGreen = GMSStrokeStyle.gradient(from:  .primaryGreen, to:  .greenTextColor)
                    polyLine.spans = [GMSStyleSpan(style: rideLightGreen),
                                      GMSStyleSpan(style: LgreenTodGreen)]
                    objRoute.polyLine = [polyLine]
                    PathSave.shared.setValues(polyline: objRoute.polyLine.first, polylineArray: objRoute.polyLine, rout: objRoute, location: CLLocation(latitude: source.latitude, longitude: source.longitude))
                    onCompletionBlock!(objRoute.polyLine.first, objRoute.polyLine, objRoute)
                }
                return
            }
            
        })
        task.resume()
    }
    
    static func uploadStaticImageOfMap(type: Int = 4, imageStr: String = "", route : RouteData) {
        RLog("urlString-\(imageStr)")
        let imgStrrr = type == 1 ? route.staticRiderImageURL.replacingOccurrences(of: "|", with: "%7C") : route.staticRiderImageURL.replacingOccurrences(of: "|", with: "%7C")
        let url = URL(string: "\(imgStrrr )")
        guard let url = url else {
            return
        }
        let resource = ImageResource(downloadURL: url)
        
        KingfisherManager.shared.retrieveImage(with: resource) { result in
            switch result {
            case .success(let value):
                let image = value.image
                let mainDBVM = MainDashbaordViewModel()
                let tripId = RideSingleton.shared.tripDetailObject?.data?.id
                mainDBVM.uploadMapImage(tripid: tripId ?? "", image: image)
            case .failure:
                return
            }
        }
    }
    
    
    static func getAddedTime(time : Int) -> String{
        let estimatedTime = (time ) / 60
        let dateTime = Date().adding(minutes: estimatedTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: dateTime)
    }
    
    
    //    CREATED = 1,
    //      STARTED = 2,
    //      DESTINATION_CHANGED = 3,
    //      CANCELLED_BY_RIDER = 4,
    //      CANCELLED_BY_DRIVER = 5,
    //      COMPLETED = 6,
    
    static func getStaticImageUrl(routePoint: String, sourceLat: Double, sourceLong: Double, destLat: Double, destLong: Double, isDriver: Bool = false, type: Int = 1) -> String {
        
        if isDriver {
            switch type {
            case 2,3:
                
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GoogleMapsKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                return staticImageUrl
            case 4,5:
                
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GooglePlacesKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                
                return staticImageUrl
            case 6:
                
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GooglePlacesKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                
                return staticImageUrl
                
            default:
                
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GooglePlacesKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                
                return staticImageUrl
            }
        } else {
            switch type {
            case 2,3:
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GooglePlacesKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                
                return staticImageUrl
            case 4,5:
                
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GooglePlacesKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                
                return staticImageUrl
            case 6:
                
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GooglePlacesKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                
                return staticImageUrl
                
            default:
                
                let staticImageUrl = "https://maps.googleapis.com/maps/api/staticmap?size=640x300&path=color:0x00FF00%7Cweight:6%7Cenc%3A\( routePoint)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(sourceLat)%2C\(sourceLong)&markers=icon%3Ahttp://uat-dashboard.ride.sa/images/CustomMap.png%7C\(destLat)%2C\(destLong)&key=\(APIKeys.GooglePlacesKey)&style=feature:poi%7Cvisibility:off&style=feature:road%7Ccolor:0xffffff%7Cvisibility:simplified"
                
                return staticImageUrl
                
            }
        }
        
    }
    
    static func adjustEventTracker(eventId: String) {
        let event = ADJEvent(eventToken: eventId)
        Adjust.trackEvent(event)
        
    }
    
}



class PathSave {
    static var shared = PathSave()
    private var polyline: GMSPolyline?
    private var polylineArray: [GMSPolyline]?
    private var rout: RouteData?
    private var previouslocation: CLLocation?
    private var isValueSet: Bool = false
    
    func setValues(polyline: GMSPolyline?, polylineArray: [GMSPolyline]?, rout: RouteData?, location: CLLocation?) {
        self.polyline = polyline
        self.polylineArray = polylineArray
        self.rout = rout
        self.previouslocation = location
        self.isValueSet = true
    }
    
    func getPolyline() -> GMSPolyline? {
        return self.isValueSet ? self.polyline : nil
    }
    
    func getPolylineArray() -> [GMSPolyline]? {
        return self.isValueSet ? self.polylineArray : nil
    }

    func getRouts() -> RouteData? {
        return self.isValueSet ? self.rout : nil
    }
    
    func isSetValues() -> Bool {
        return self.isValueSet
    }
    
    func removePath(path: GMSPolyline?) {
        self.polylineArray = self.polylineArray?.filter(){$0 != path}
    }
    
    func removeValue() {
        self.polyline = nil
        self.polylineArray = nil
        self.rout = nil
        self.previouslocation = nil
        self.isValueSet = false
    }
    
    func getPreviousLocation() -> CLLocation? {
        return previouslocation
    }
}
