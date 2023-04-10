//
//  PdfWebViewController.swift
//  Ride
//
//  Created by Mac on 07/12/2022.
//  Copyright © 2022 Xint Solutions. All rights reserved.
//

import UIKit
import WebKit

class PdfWebViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: - Constants and Variables
    var tripId: String?
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLoader()
        let urlStringToLoad = ServerUrls.download_pdf_invoice + (tripId ?? DefaultValue.string)
        if let url = URL(string: urlStringToLoad) {
            webView.load(URLRequest(url: url))
        }
        
        webView.navigationDelegate = self
        
        setLeftBackButton(selector: #selector(backButtonTapped),rotate: false)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func downloadPDF(url: URL?) {
        guard let url = url else { return }
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let _ = documentsUrl?.appendingPathComponent(url.lastPathComponent) else { return }
        
        Downloader.load(url: url) { [weak self] data in
            guard let `self` = self else { return }
            
            if let data = data {
                let objectsToShare = [data] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                
                activityVC.popoverPresentationController?.sourceView = self.view
                
                self.navigationController?.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    func makePDF(webView: WKWebView) throws {
     
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(webView.viewPrintFormatter(), startingAtPageAt: 0);


        let page = CGRect(x: 0, y: 10, width: webView.frame.size.width, height: webView.frame.size.height) // take the size of the webView
        let printable = page.insetBy(dx: 0, dy: 0)
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")

        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        for i in 1...render.numberOfPages {

            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        UIGraphicsEndPDFContext();
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        print(documentsPath)

        pdfData.write(toFile: "\(documentsPath)/RideInvoice\(tripId ?? "1234").pdf", atomically: true)
        Commons.showErrorMessage(controller:  self.navigationController ?? self,backgroundColor: .lightGreen,textColor: .greenTextColor, message: "PDF saved")
        //self.navigationController?.dismiss(animated: true)
//        self.pdfPath = "\(documentsPath)/pdfName.pdf"
//        self.pdfTitle = "pdfName"
//        self.performSegue(withIdentifier: "showPDFSegue", sender: nil)
//        webView.removeFromSuperview()
//        self.loadingScreenViewController.view.removeFromSuperview()
    }
}

extension PdfWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.stopLoader()
        if webView.url?.scheme == "blob" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                do {
                    try  self.makePDF(webView:self.webView )
                }  catch {
                    // handle other errors
                    Commons.showErrorMessage(controller: self.navigationController ?? self, message: "Unable to save PDF")
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
            return
        }

        if urlAsString.range(of: "the url that the button redirects the webpage to") != nil {
        // do something
        }
     }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.stopLoader()
    }

}

class Downloader {
    class func load(url: URL, completion: @escaping (Data?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            if error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                    DispatchQueue.main.async {
                        completion(data)
                    }
                }
            } else {
                print("Failure: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
}
