// Copyright 2018, Ralf Ebert
// License   https://opensource.org/licenses/MIT
// License   https://creativecommons.org/publicdomain/zero/1.0/
// Source    https://www.ralfebert.de/ios-examples/uikit/choicepopover/

import UIKit

class ArrayChoiceTableViewController<Element> : UITableViewController, UISearchBarDelegate {
    
    typealias SelectionHandler = (Element) -> Void
    typealias LabelProvider = (Element) -> String
    
    private let values: [Element]
    private var filtered: [Element] = []
    private let labels: LabelProvider
    private let onSelect: SelectionHandler?
    var searchActive: Bool = false
    
    init(_ values: [Element], labels: @escaping LabelProvider = String.init(describing:), onSelect : SelectionHandler? = nil) {
        self.values = values
        self.onSelect = onSelect
        self.labels = labels
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        
        // First cell in the table view is a search field
        let searchBar:UISearchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count + 1
        }
        return values.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if indexPath.row == 0 {
            cell.textLabel?.text = ""
        } else {
            if searchActive {
                cell.textLabel?.text = labels(filtered[indexPath.row - 1])
            } else {
                cell.textLabel?.text = labels(values[indexPath.row - 1])
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        if searchActive {
            onSelect?(filtered[indexPath.row - 1])
        } else {
            onSelect?(values[indexPath.row - 1])
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchActive = false
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
