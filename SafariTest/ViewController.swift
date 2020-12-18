//
//  ViewController.swift
//  SafariTest
//
//  Created by Gavriel Rosendorn on 02.12.20.
//  Copyright © 2020 Gavriel Rosendorn. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction  func buttonTapped()
    {
        let webView = WKWebView(frame: view.frame)
        view.addSubview(webView)

        let url = URL(string: "https://www.linkedin.com/login")
        let request = URLRequest(url: url!)
        var nbrContact = 0;
        var trys = 0;
        
        webView.load(request)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // essaye d'aller sur la page des connections
            if (!((webView.url?.absoluteString as? String ?? "").contains("login")) && !((webView.url?.absoluteString as? String ?? "").contains("/mynetwork/invite-connect/connections/"))){
                webView.load(URLRequest(url:URL(string: "https://www.linkedin.com/mynetwork/invite-connect/connections/")!));
            }
            
            //verifie qu'on est sur la bonne page
            if (((webView.url?.absoluteString as? String ?? "").contains("/mynetwork/invite-connect/connections/"))){
                
                //scroll down
                webView.evaluateJavaScript("window.scrollTo(0,document.body.scrollHeight)") { (result, error) in
                
                }
                //on compte le nombre de contact en verifiant qu'on est fini de compter ou pas
                webView.evaluateJavaScript("document.querySelectorAll('.connection-entry').length") { (result, error) in
                    if (error == nil)
                    {
                        if (nbrContact == (result as? Int ?? 0))
                        {
                            trys += 1;
                        }else{
                            trys = 0;
                        }
                        nbrContact = (result as? Int ?? 0)
                    }
                }
                
                if (trys > 5){
                    print("bye")
                    self.extract(webView: webView, nbrContacts: nbrContact)
                    timer.invalidate()
                }
            }
        }
    }
    
    func extract(webView:WKWebView, nbrContacts:Int)
    {
        var i = 0;
        var imgProfil: [String] = [];
        var nomPrenom: [String] = [];
        
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if (i < nbrContacts) {
                    //recup image
                    webView.evaluateJavaScript(("document.querySelectorAll('.connection-entry')["+String(i)+"].querySelector('.entity-img- > img').currentSrc")) { (result, error) in
                        if (error == nil)
                        {
                            imgProfil.append(result as? String ?? "")
                        }else{
                            imgProfil.append("")
                        }
                    }
                    webView.evaluateJavaScript(("document.querySelectorAll('.connection-entry')["+String(i)+"].querySelector('.name span').innerText")) { (result, error) in
                        if (error == nil)
                        {
                            nomPrenom.append(result as? String ?? "")
                        }else{
                            nomPrenom.append("")
                        }
                    }
                }else{
                    if (imgProfil.count == nbrContacts && nomPrenom.count == nbrContacts)
                    {
                        print("bye 2")
                        webView.removeFromSuperview()
                        self.printProfils(img: imgProfil, name: nomPrenom)
                        timer.invalidate()
                    }
                }
            i += 1;
        }
    }
    
    func printProfils(img:[String], name:[String])
    {
        var i = 0;
        
        while (i < img.count) {
            print("")
            print("Personne " + String((i + 1)) + " :")
            print("Nom : " + name[i])
            print("Img : " + img[i])
            print("")
            print("------------------------------")
            i += 1;
        }
    }
    
    func matches(for regex:String, in text:String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch {
            return []
        }
    }
}

