// Copyright 2018, Ralf Ebert
// License   https://opensource.org/licenses/MIT
// License   https://creativecommons.org/publicdomain/zero/1.0/
// Source    https://www.ralfebert.de/ios-examples/uikit/choicepopover/

import UIKit

class ArrayChoiceTableViewController<Element> : UITableViewController, UISearchBarDelegate {
    
    typealias SelectionHandler = (Element) -> Void
    typealias LabelProvider = (Element) -> String
    
    private var values: [Element]
    private var filtered: [Element] = []
    private let labels: LabelProvider
    private let onSelect: SelectionHandler?
    private var searchActive: Bool = false
    private var searchText: String = ""
    private let selectable: Bool
    private let delegateViewController: AnnotateImageViewController
    
    init(delegateViewController: AnnotateImageViewController, _ values: [Element], labels: @escaping LabelProvider = String.init(describing:), selectable: Bool, onSelect : SelectionHandler? = nil) {
        self.values = values
        self.onSelect = onSelect
        self.labels = labels
        self.delegateViewController = delegateViewController
        self.selectable = selectable
        super.init(style: .plain)
        tableView.allowsSelection = selectable
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        
        // First cell in the table view is a search field
        let searchBar:UISearchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search or add new..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            if selectable {
                return filtered.count + 2
            } else {
                return filtered.count + 1
            }
        }
        return values.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if indexPath.row == 0 {
            cell.textLabel?.text = ""
        } else {
            if searchActive {
                // Last item should be add <search word> to taxonomy button
                if indexPath.row == filtered.count + 1 {
                    cell.textLabel?.text = "Add \"\(searchText)\" to the dictionary... "
                } else {
                    cell.textLabel?.text = labels(filtered[indexPath.row - 1])
                }
            } else {
                cell.textLabel?.text = labels(values[indexPath.row - 1])
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        if searchActive {
            if indexPath.row == filtered.count + 1 {
                // We should add the new word to the dictionary
                if !values.contains(where: { (element) in element as! String == searchText}) {
                    delegateViewController.activeCampaign?.taxonomy.append(searchText)
                }
                onSelect?(searchText as! Element)
            } else {
                onSelect?(filtered[indexPath.row - 1])
            }
        } else {
            onSelect?(values[indexPath.row - 1])
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if searchText == "" {
            searchActive = false
            self.tableView.reloadData()
            return
        }
        filtered = values.filter({ (text) -> Bool in
            let tmp: NSString = NSString(string: text as! String)
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        searchActive = true
        self.tableView.reloadData()
    }
}
