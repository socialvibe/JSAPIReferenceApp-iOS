//
//  ViewController.swift
//  JSAPIReferenceApp-iOS
//
//  Created by Jesse Albini on 2/23/24.
//

import UIKit
import AdSupport

struct AdResponse:Decodable{
    let error: String?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var hashInput: UITextField!
    @IBOutlet weak var adResponseView: UITextView!
    
    @IBOutlet weak var showAdButton: UIButton!
    var truexAdResponseJson:String?
    
    // This is a default placement hash, replace this with the hash provided to you from your TrueX rep
    let defaultPlacementHash = "90425c0792375347a08fbf5c48f4f2d8cccfced5"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        hashInput.text = defaultPlacementHash
    }

    @IBAction func makeAdRequest(_ sender: Any) {
        adResponseView.text = "Loading..."
        showAdButton.isEnabled = false;
        
        // trigger ad request
        Task {
            do {
                truexAdResponseJson = try await fetchAdJson()
                
                if (truexAdResponseJson != nil) {
                    // Ad was returned
                    adResponseView.text = truexAdResponseJson
                    showAdButton.isEnabled = true;
                }
                else
                {
                    // No ads available
                    adResponseView.text = "No ads available"
                }
            } catch {
                print("fetchAdJson() error: ", error)
            }
        }
    }
    
    @IBAction func showAd(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "truexvc") as? TruexAdViewController else {
            return
        }
        vc.set(placementHash: hashInput.text, userId: getIDFA(), adJson: truexAdResponseJson)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func fetchAdJson() async throws -> String? {        
        // can pass other parameters like age/gender
        // https://github.com/socialvibe/truex-ads-docs/blob/master/web_service_ad_api.md#get-parameters
        let requestParams = [
            URLQueryItem(name: "user.id", value: getIDFA()),
            URLQueryItem(name: "placement.key", value: hashInput.text)
        ]
                
        // build URL
        guard var urlComponents = URLComponents(string: "https://get.truex.com/v2") else {
            return nil
        }
        urlComponents.queryItems = requestParams
        let url = urlComponents.url!
        
        print("fetchAdJson() Ad Request Url: ", url)
        
        // make ad request
        var adRequest = URLRequest(url: url)
        adRequest.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let jsonString = String(data:data, encoding: .utf8)
        let adResponse = try JSONDecoder().decode(AdResponse.self, from: data)
        
        if adResponse.error == nil {
            return jsonString
        }
        
        return nil
    }
    
    func getIDFA() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}

