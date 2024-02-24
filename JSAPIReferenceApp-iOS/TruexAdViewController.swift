//
//  TruexAdViewController.swift
//  JSAPIReferenceApp-iOS
//
//  Created by Jesse Albini on 2/23/24.
//

import UIKit
import WebKit
import JavaScriptCore
import SafariServices

class TruexAdViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var placementHash:String?
    var userId:String?
    var adJson:String?

    func set(placementHash:String?, userId:String?, adJson:String?) {
        self.placementHash = placementHash
        self.userId = userId
        self.adJson = adJson
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.isInspectable = true
        
        // add event handler for javascript messages
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "truexMessageHandler")
        
        // load adLoader.html
        if let filePath = Bundle.main.url(forResource: "adLoader", withExtension: "html") {
            let contentData = FileManager.default.contents(atPath: filePath.path)
            self.webView.load(contentData!, mimeType: "html", characterEncodingName: "utf8", baseURL: URL(string:"https://media.truex.com") ?? filePath)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // TrueX will configure your placement to be either portrait locked or landscape locked, make sure to set this to
        // whichever style you've discussed with your TrueX rep
        return .portrait
    }

    // handle events from Javascript
    func userContentController(_ userContentController: WKUserContentController,didReceive message: WKScriptMessage) {
        if message.name == "truexMessageHandler" {
            guard let event = message.body as? [String : String] else {
                return
            }
            
            let eventName = event["eventName"];
            
            // event handlers
            if (eventName == "onClickthrough") {
                // handle onClickthrough event by loading URL in a separate webview

                if let url:String = event["eventData"] {
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "clickthroughvc") as! ClickthroughViewController
                    vc.url = URL(string: url);
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true, completion: nil)
                }
                    
            } else if eventName == "onCredit" {
                // handle credit event
                
                print("adCredit")
            } else if eventName == "onClose" {
                // handle close event
                dismiss(animated: true)
            }

        }
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // trigger showAd() function in adLoader.html
        let command = "showAd('\(placementHash!)','\(userId!)',\(adJson!))"
        self.webView.evaluateJavaScript(command, completionHandler: nil)
    }
}




