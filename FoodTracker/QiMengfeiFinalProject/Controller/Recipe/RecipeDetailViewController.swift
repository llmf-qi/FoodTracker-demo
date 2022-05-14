//
//  RecipeDetailViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/5/1.
//

import UIKit
import WebKit

class RecipeDetailViewController: UIViewController, WKNavigationDelegate {
    var selectedRecipe: Recipe!
    @IBOutlet weak var RecipeDetailWeb: WKWebView!
    
    @IBOutlet weak var webIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() { //load the detailed recipe
        super.viewDidLoad()
        let url = URL(string: selectedRecipe.sourceUrl)!
        let request = URLRequest(url: url)
        RecipeDetailWeb.load(request)
        RecipeDetailWeb.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webIndicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webIndicator.isHidden = true
    }
    

}
