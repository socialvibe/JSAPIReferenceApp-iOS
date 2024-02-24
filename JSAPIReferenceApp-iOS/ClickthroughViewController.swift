//
//  ClickthroughViewController.swift
//  JSAPIReferenceApp-iOS
//
//  Created by Jesse Albini on 2/23/24.
//

import UIKit
import WebKit

class ClickthroughViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var url:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: url))
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
}
