//
//  PlaceWebsiteViewController.swift
//  TripKey2
//
//  Created by Peter on 2/1/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class PlaceWebsiteViewController: UIViewController, UIWebViewDelegate {
    
   // var flights = [Dictionary<String,String>]()
    var urlString:String!
    @IBOutlet var webView: UIWebView!
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    /*
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return checkRequestForCallbackURL(request: request)
    }
    
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PlaceWebsiteViewController")
        
        webView.delegate = self
        /*
        if UserDefaults.standard.object(forKey: "urlString") != nil {
            
            urlString = UserDefaults.standard.object(forKey: "urlString") as! String
            print("urlString = \(urlString)")
            UserDefaults.standard.removeObject(forKey: "urlString")
            
        } else {
            
            urlString = ""
        }
        */
        
        UserDefaults.standard.set(true, forKey: "userSwipedBack")
        
        //if UserDefaults.standard.object(forKey: "flights") != nil {
            
            //flights = UserDefaults.standard.object(forKey: "flights") as! [Dictionary<String,String>]
        //}
        
        //unSignedRequest()
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webiview did start loading")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webview did finish load")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        //webViewDidFinishLoad(webView)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("error = \(error)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.object(forKey: "urlString") != nil {
            
            urlString = UserDefaults.standard.object(forKey: "urlString") as! String
            print("urlString = \(urlString)")
            UserDefaults.standard.removeObject(forKey: "urlString")
            
        } else {
            
            urlString = ""
            
        }
        
        
        if let url = URL(string: urlString!) {
            
            print("url = \(url)")
            
            let request = NSURLRequest(url: url)
            
            DispatchQueue.main.async {
                
                self.webView.loadRequest(request as URLRequest)
                
            }
            
            
            
            
        } else {
            
            print("that is not a valid url")
            
            let alert = UIAlertController(title: NSLocalizedString("Sorry no website registered", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        self.webView.loadRequest(urlRequest)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
    }
    
    func handleAuth(authToken: String)  {
        print("Instagram authentication token ==", authToken)
    }
        
    
    struct INSTAGRAM_IDS {
        
        static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
        
        static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
        
        static let INSTAGRAM_CLIENT_ID  = "4db355440a544579b3a8454ac4c32040"
        
        static let INSTAGRAM_CLIENTSERCRET = "fcdeadcab744455bb6003ace0541a8c5"
        
        static let INSTAGRAM_REDIRECT_URI = "REPLACE_YOUR_REDIRECT_URI_HERE"
        
        static let INSTAGRAM_ACCESS_TOKEN =  "access_token"
        
        static let INSTAGRAM_SCOPE = "likes+comments+relationships"
        
    }



}
