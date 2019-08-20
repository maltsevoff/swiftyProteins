//
//  TabViewViewController.swift
//  swiftyProteins
//
//  Created by Yaroslava HLIBOCHKO on 7/17/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import UIKit

class TabViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var ozButton: UIButton!
    @IBOutlet weak var zoButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBar: UINavigationItem!
    let fileManager = FileManager()
    let activityIndicator = UIActivityIndicatorView()
    var ligands: [String] = []
    var filterLigands: [String] = []
    var file: String?
    var name: String?

    @IBAction func normalSort(_ sender: UIButton) {
        filterLigands =  filterLigands.sorted(by: {$0.self < $1.self})
        tableView.reloadData()
    }
    @IBAction func reversSort(_ sender: UIButton) {
        filterLigands = filterLigands.sorted(by: {$0.self > $1.self})
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ozButton.layer.cornerRadius = 5
        zoButton.layer.cornerRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.backgroundColor = .clear
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                var ligandsArray = data.components(separatedBy: .newlines)
                if ligandsArray.last == "" {
                    ligandsArray.removeLast()
                }
                ligands = ligandsArray
                filterLigands = ligands
            } catch {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = true
        self.view.endEditing(false)
        searchBarSearchButtonClicked(self.searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterLigands = searchText.isEmpty ? ligands : ligands.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterLigands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? LigandTableViewCell {
            cell.contentView.layer.cornerRadius = 5
            cell.titleLabel.text = filterLigands[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LigandModelViewController {
            if (segue.identifier == "show3DModel" && sender != nil) {
                vc.file = self.file!
                vc.name = self.name!
                vc.info = sender as! String
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActivityIndicator()
        name = filterLigands[indexPath.row]
        self.view.isUserInteractionEnabled = false
        self.tableView.cellForRow(at: indexPath)?.isSelected = true
        fileManager.findFileForLigandModel(name: filterLigands[indexPath.row], completionHandler: {response in
            if response!.isEmpty {
                self.makeAlert(title: "Error", message: "Source file doesn't exist ☹️")
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
            } else if response != nil {
                self.file = response
                self.fileManager.findFileForLigandInformation(name: self.filterLigands[indexPath.row], completionHandler: { response in
                    if response!.isEmpty {
                        self.makeAlert(title: "Error", message: "Source file doesn't exist ☹️")
                        self.view.isUserInteractionEnabled = true
                        self.hideActivityIndicator()
                    } else if response != nil {
                        self.performSegue(withIdentifier: "show3DModel", sender: response)
                        self.tableView.cellForRow(at: indexPath)?.isSelected = false
                        self.hideActivityIndicator()
                    }
                })
            }
            else {
                self.makeAlert(title: "Error", message: "Ligand not found")
            }
        })
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.style = .whiteLarge
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80) //or whatever size you would. like
            self.activityIndicator.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.height / 2)
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
}
