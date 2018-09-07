//
//  PagerViewExample.swift
//  Example
//
//  Created by Dominic Miller on 9/7/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit

import DMPagerView

class PagerViewExample: UIViewController, DMPagerViewDelegate, DMPagerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate var SpanichWhite : UIColor = UIColor(red: 0.996, green: 0.992, blue: 0.941, alpha: 1)
    
    @IBOutlet weak var pagerView: DMPagerView!
    
    var tableView: UITableView!
    var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init pages
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = SpanichWhite
        
        webView = UIWebView()
        let url = URL(string: "https://github.com/DominicMDev")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        
        //Init title
        navigationItem.title = "Page 0"
        
        //Setup pager
        pagerView.gutterWidth = 20
        
        //Register UITextView as page
        pagerView.register(UITextView.self, forPageReuseIdentifier: "TextPage")
    }
    
    @IBAction func previous(sender: AnyObject) {
        pagerView.showPage(at: (pagerView.indexForSelectedPage - 1), animated: true)
    }
    
    @IBAction func next(sender: AnyObject) {
        pagerView.showPage(at: (pagerView.indexForSelectedPage + 1), animated: true)
    }
    
    // MARK: - Pager view delegate
    
    func pagerView(_ pagerView: DMPagerView, didMoveToPage page: UIView, at index: Int) {
        navigationItem.title = "Page \(index)"
    }
    
    // MARK: - Pager view data source
    
    func numberOfPages(in pagerView: DMPagerView) -> Int {
        return 10
    }
    
    func pagerView(_ pagerView: DMPagerView, viewForPageAt index: Int) -> UIView {
        if index < 2 {
            return [tableView, webView][index]
        }
        
        let page = pagerView.dequeueReusablePage(withIdentifier: "TextPage") as! UITextView
        let filePath = Bundle.main.path(forResource: "LongText", ofType: "txt")
        page.text = try! String(contentsOfFile:filePath!, encoding: String.Encoding.utf8)
        page.backgroundColor = SpanichWhite
        
        return page
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = (indexPath.row % 2 > 0) ? "Text" : "Web"
        cell.backgroundColor = SpanichWhite
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath.row % 2) + 1
        pagerView.showPage(at: index, animated:true)
    }
}

