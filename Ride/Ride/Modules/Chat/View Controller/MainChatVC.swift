//
//  MainChatVC.swift
//  Ride
//
//  Created by Ali Zaib on 11/11/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MainChatVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var msgText: UITextField!
    @IBOutlet weak var chatTV: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var microPhoneBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var ChatTVHeight: NSLayoutConstraint!
    @IBOutlet weak var outsideView: UIView!
    
    
    //MARK: - Constants and Variables
    private var chatVM = ChatViewModel()
    var receiverChatId: String?
    var chatName: String?
    var chatImage: String?
    private var typingStatus = false
    
    
    //MARK: - View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.view.bringSubviewToFront(outsideView)
        if let receiverChatId = receiverChatId {
            chatVM.getChatMessages(with: receiverChatId)
        }
        
        self.ChatTVHeight.constant = self.view.frame.height - self.safeAreaSpacing()
        bindViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if Commons.isArabicLanguage() {
            self.navigationItem.titleView?.semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
        } else {
            
            self.navigationItem.titleView?.semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
        }
        //self.navigationController?.navigationBar.backgroundColor = .systemBackground
    }
 
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            chatTV.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: -(keyboardSize.height + chatTV.rowHeight), right: 0)
            self.ChatTVHeight.constant = self.view.frame.height - self.safeAreaSpacing() - keyboardSize.height
            self.view.bringSubviewToFront(outsideView)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {

        self.ChatTVHeight.constant = self.view.frame.height - self.safeAreaSpacing()
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            chatTV.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.chatTV.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//        self.setNavBar(title: chatName ?? "Customer Care".localizedString(), image: chatImage )
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.systemBackground //current new color
        self.navigationController?.hidesBarsOnSwipe = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        self.setNavBar(title: chatName ?? "Customer Care".localizedString(), image: chatImage )
        self.microPhoneBtn.isHidden = true
        self.imageBtn.isHidden = true
        DispatchQueue.main.async { [weak self] in
            self?.bottomStackView.layoutIfNeeded()
            self?.msgText.layoutIfNeeded()
            self?.msgText.addDoubleBorder(with: .sepratorColor, and: .primaryGreen,cornerRadius: (self?.msgText.frame.height ?? 40)/2)
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear  //other vc's color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = nil
    }
    
    private func setupViews() {
        //setLeftBackButton(selector: #selector(backButtonTapped))
        //Sets the navigation title with text and image
        
      
        self.setupTV()
        
        msgText.placeholder = "Write a message".localizedString()
        
        msgText.addDoubleBorder(with: .sepratorColor, and: .primaryGreen,cornerRadius: self.msgText.frame.height/2)
        msgText.setLeadingPadding(15)
        msgText.setRightPadding(15)
        //msgText.textAlignment = Commons.isArabicLanguage() ? .right : .left
        msgText.delegate = self
        listenSockets()
        sendBtn.rotateBtnIfNeeded()
    }
    
    private func setupTV() {
        chatTV.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: chatTV.bounds.size.width - 10)
        chatTV.transform = CGAffineTransform(scaleX: 1, y: -1)
        chatTV.estimatedRowHeight = UITableView.automaticDimension
        chatTV.rowHeight = UITableView.automaticDimension
        chatTV.register(UINib(nibName: ChatRecieverCell.className, bundle: nil), forCellReuseIdentifier: ChatRecieverCell.className)
        chatTV.register(UINib(nibName:ChatSenderCell.className, bundle: nil), forCellReuseIdentifier: ChatSenderCell.className)
        msgText.textAlignment = Commons.isArabicLanguage() ? .right : .left
        msgText.font = Commons.isArabicLanguage() ? UIFont.MadaniArabicRegular : UIFont.SFProDisplayRegular
    }
    
    private func listenSockets() {
        listenMessage()
        listenSelfMessage()
        listenMessageDeliver()
        listenMessageRead()
    }
    
    private func listenMessage() {
        SocketIOHelper.shared.listenChatEvent(eventName: "receive-message") { [weak self] res in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.chatVM.addItemToChatList(with: res)
                self.chatTV.reloadData()
                
                var dict = [String: Any]()
                dict["userID"] = UserDefaultsConfig.user?.userId ?? DefaultValue.string
               
                
                var dataDict = [String: Any]()
                dataDict["receiverId"] = res.senderId
                dataDict["senderId"] = res.receiverId
                dataDict["messageId"] = res.messageId ?? DefaultValue.string
                
                dict["data"] = dataDict
                SLog("message-read == \(dict.debugDescription)")
                SocketIOHelper.shared.emitEvent(eventName: "message-read", dict: dict)
            }
        }
    }
    
    private func listenMessageDeliver() {
        SocketIOHelper.shared.listenChatEvent(eventName: "message-delivered") { [weak self] res in
            guard let `self` = self else { return }
            var updatedRes = res
            let recStatus = ReceiverStatus(status: res.status)
            updatedRes.receiver = recStatus
            self.chatVM.updateChatItem(with: updatedRes)
            self.chatTV.reloadData()
        }
    }
    
    private func listenMessageRead() {
        SocketIOHelper.shared.listenChatEvent(eventName: "message-read") { [weak self] res in
            guard let `self` = self else { return }
            var updatedRes = res
            let recStatus = ReceiverStatus(status: res.status)
            updatedRes.receiver = recStatus
            self.chatVM.updateChatItem(with: updatedRes)
            self.chatTV.reloadData()
        }
    }
    
    private func listenSelfMessage() {
        SocketIOHelper.shared.listenChatEvent(eventName: "send-message-ack") { [weak self] res in
            guard let `self` = self else { return }
            var updatedRes = res
            let recStatus = ReceiverStatus(status: res.status)
            updatedRes.receiver = recStatus
            self.chatVM.updateLastChatItem(with: updatedRes)
            self.chatTV.reloadData()
        }
    }
    
    private func removeMessageHandler() {
        SocketIOHelper.shared.socket?.off("receive-message")
        SocketIOHelper.shared.socket?.off("message-delivered")
        SocketIOHelper.shared.socket?.off("message-read")
        SocketIOHelper.shared.socket?.off("send-message-ack")
    }
    
    private func updateTypingStatus(isStart: Bool) {
        var dict = [String: Any]()
        dict["userID"] = UserDefaultsConfig.user?.userId ?? DefaultValue.string
        
        var dataDict = [String: Any]()
        dataDict["receiverId"] = receiverChatId
        dataDict["action"] = isStart ? "start" : "stop"
        
        dict["data"] = dataDict
        SLog("message-read == \(dict.debugDescription)")
        SocketIOHelper.shared.emitEvent(eventName: "typing-event", dict: dict)
    }
    
    // MARK: - Navigation
    
    func setNavBar(title : String, image: String?){
        let backButton = Commons.isArabicLanguage() ? getAppNavRightBackButton() : getAppNavBackButton()
       // backButton.rotateBtnIfNeeded()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let title = getTitleLabel(title : title)
        let userImage = ImageBarButton(withUrl: URL(string: image ?? ""))
        userImage.frame.size = CGSize(width: 44, height: 44)
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton) ,UIBarButtonItem(customView: userImage),UIBarButtonItem(customView: title)]
        //self.navigationItem.titleView = navTitleWithImageAndText(titleText: title)
    }
    
    func getTitleLabel(title : String) -> UILabel{
        let label = UILabel()
        label.text = title
        label.sizeToFit()
        label.textColor = .primaryDarkBG
        label.font = !Commons.isArabicLanguage() ? UIFont(name: "SFProDisplay-Semibold", size: 16) : UIFont(name: "Madani Arabic SemiBold", size: 16)
        return label
    }
    
    @objc private func backButtonTapped() {
        
        updateTypingStatus(isStart: false)
        typingStatus = false
        
        removeMessageHandler()
        navigationController?.popViewController(animated: true)
    }
    
    func safeAreaSpacing() -> CGFloat {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        return (topPadding + bottomPadding + 81)
    }
    
    func navTitleWithImageAndText(titleText: String) -> UIView {
        // Creates a new UIView
        let titleView = UIView()
        // Creates a new text label
        let label = UILabel()
        label.text = titleText
        label.sizeToFit()
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = UIFont(name: "SFProDisplay-Semibold", size: 16)
        label.center = titleView.center
        label.textAlignment = NSTextAlignment.center
        titleView.addSubview(label)
        titleView.sizeToFit()
        return titleView
    }
    
    private func openPhoto() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Open Camera".localizedString(), style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.openCamera(forVideo: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "Open Gallery".localizedString(), style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.openGallary(forVideo: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString(), style: UIAlertAction.Style.cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func openGallary(forVideo: Bool){
        self.view.endEditing(true)
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .custom
        present(picker, animated: true, completion: nil)
    }
    
    private func openCamera(forVideo: Bool) {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            callCamera(forVideo: false)
        } else  {
            let alert  = UIAlertController(title: "Warning".localizedString(), message: "You dont have camera".localizedString(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func callCamera(forVideo: Bool){
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.allowsEditing = true
        myPickerController.sourceType = UIImagePickerController.SourceType.camera
        myPickerController.modalPresentationStyle = .overCurrentContext
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    // MARK: - Target Method
    @objc func scrollToBottom(animation: Bool = true) {
        if ((self.chatVM.chats.count - 1) > 0){
            DispatchQueue.main.async {
                self.chatTV.scrollToRow(at: IndexPath.init(row: self.chatVM.chats.count - 1, section: 0), at: .bottom, animated: animation)
            }
        }
    }
    
    //MARK: - UIACTIONS
    @IBAction func didTapChatSend(_ sender: Any) {
        
        if msgText.text.isSome && !msgText.text!.trimmingCharacters(in: .whitespaces).isEmpty{
            
            updateTypingStatus(isStart: false)
            typingStatus = false
            
            var mainDictionary = [String: Any]()
            mainDictionary["userID"] = UserDefaultsConfig.user?.userId ?? DefaultValue.string
            var subDictionary = [String: Any]()
            subDictionary["chatType"] = 1
            subDictionary["receiverId"] = receiverChatId ?? DefaultValue.string
            subDictionary["messageType"] = 1
            subDictionary["messageContent"] = msgText.text ?? ""
            mainDictionary["data"] = subDictionary
            SocketIOHelper.shared.socket?.emit("send-message", mainDictionary)
            let timestamp = (NSDate().timeIntervalSince1970) * 1000
            let newMsg = ChatResponse.init(messageId: nil, timestamp: timestamp, senderId: Int(UserDefaultsConfig.user?.userId ?? DefaultValue.string), conversationId: "", chatType: .TEXT, messageType: 1, messageContent:  msgText.text ?? "", status: .pending, receiverId: Int(receiverChatId ?? DefaultValue.string), receiver: ReceiverStatus.init(status: .pending))
            chatVM.addItemToChatList(with: newMsg)
            self.chatTV.reloadData()
            self.msgText.text = ""
        }else{
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: "Message is empty".localizedString())
        }
    }
    
    @IBAction func didTapMedia(_ sender: Any) {
        openPhoto()
    }
}

//MARK: - Tableview delegate and datasource
extension MainChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatVM.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = chatVM.chats[indexPath.row]
        if String(model.senderId ?? 0) != UserDefaultsConfig.user?.userId ?? DefaultValue.string{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRecieverCell.className, for: indexPath) as? ChatRecieverCell else { return ChatRecieverCell() }
            cell.item = chatVM.chats[indexPath.row]
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatSenderCell.className, for: indexPath) as? ChatSenderCell else { return ChatSenderCell() }
            cell.item = chatVM.chats[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            cell.layoutIfNeeded()
        }
    }
}

//MARK: - Text Field Delegate
extension MainChatVC : UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? DefaultValue.string
        if text.isEmpty {
            sendBtn.isHidden = true
            microPhoneBtn.isHidden = true
            imageBtn.isHidden = true
        } else {
            sendBtn.isHidden = false
            microPhoneBtn.isHidden = true
            imageBtn.isHidden = true
        }
        DispatchQueue.main.async { [weak self] in
            self?.bottomStackView.layoutIfNeeded()
            self?.msgText.layoutIfNeeded()
            self?.msgText.addDoubleBorder(with: .sepratorColor, and: .primaryGreen,cornerRadius: (self?.msgText.frame.height ?? 40)/2)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !typingStatus {
            updateTypingStatus(isStart: true)
            typingStatus = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTypingStatus(isStart: false)
        typingStatus = false
    }
}

//MARK: - Image Picker Delegate
extension MainChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: false)
        if let type = info[UIImagePickerController.InfoKey.mediaType] as? String, type == "public.movie" {
            if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] {
                
//                if let url = URL(string: "\(videoUrl)") {
//                    let asset = AVURLAsset(url: url)
//                    guard let videoData = try? Data(contentsOf: url) else {
//                        failureMessage(message: "Getting error from library to fetch video")
//                        return
//                    }
//                    let newVC: VideoCaptionViewController = VideoCaptionViewController.instantiate(fromAppStoryboard: .Chat)
//                    newVC.video = asset
//                    newVC.delegate = self
//                    newVC.videoUrl = url
//                    newVC.videoData = videoData
//                    self.navigationController?.pushViewController(newVC, animated: false)
//                }
            }
        } else {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let mediaUrl = info[UIImagePickerController.InfoKey.imageURL]  {
                if let vc: ChatAttachmentViewController = UIStoryboard.instantiate(with: .chat) {
                    vc.image = image
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    present(vc, animated: false, completion: nil)
                }
            }
        }
    }
}

extension MainChatVC {
    func bindViewModel() {
        chatVM.isLoading.bind { value in
            self.showLoader(startAnimate: value)
        }
        
        chatVM.messageWithCode.bind { [weak self] err in
            guard let `self` = self else { return }
            guard !(err.message?.isEmpty ?? true) else { return }
            Commons.showErrorMessage(controller: self.parent?.parent?.navigationController ?? self, message: err.message ?? DefaultValue.string)
        }
        
        chatVM.getMessagesData.bind { [weak self] res in
            guard let `self` = self else { return }
            
            guard res.statusCode == 200 else { return }
            
            if UserDefaultsConfig.user?.userId != "\(res.data?.first?.senderId ?? 0)" {
                var dict = [String: Any]()
                dict["userID"] = UserDefaultsConfig.user?.userId ?? DefaultValue.string
                
                var dataDict = [String: Any]()
                dataDict["receiverId"] = res.data?.first?.senderId
                dataDict["senderId"] = res.data?.first?.receiverId
                dataDict["messageId"] = res.data?.first?.messageId
                
                dict["data"] = dataDict
                SLog("message-read == \(dict.debugDescription)")
                SocketIOHelper.shared.emitEvent(eventName: "message-read", dict: dict)
                
            }
            
            self.chatTV.reloadData()
        }
    }
}
