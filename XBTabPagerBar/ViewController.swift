//
//  ViewController.swift
//  XBTabPagerBar
//
//  Created by xiaobin liu on 2019/2/14.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - 演示控制器
final class ViewController: UIViewController {

    /// 列表
    private lazy var tableView: UITableView = {
        let temTableView = UITableView()
        temTableView.frame = self.view.bounds
        temTableView.backgroundColor = UIColor.white
        temTableView.rowHeight = 50
        temTableView.separatorInset = .zero
        temTableView.tableFooterView = UIView()
        temTableView.dataSource = self
        temTableView.delegate = self
        temTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return temTableView
    }()
    
    private var array: [String] = ["none", "progress", "progressBounce", "progressElastic", "cover"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "演示Demo"
        self.view.addSubview(tableView)
    }
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.textLabel?.text = array[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TabPagerBarDemo()
        vc.tabPagerBar.backgroundColor = UIColor.white
        switch indexPath.row {
        case 0:
            vc.tabPagerBar.layout.barStyle = .none
            vc.tabPagerBar.layout.selectedTextColor = UIColor.red
        case 1:
            vc.tabPagerBar.layout.barStyle = .progress
            vc.tabPagerBar.layout.selectedTextColor = UIColor.red
        case 2:
            vc.tabPagerBar.layout.barStyle = .progressBounce
            vc.tabPagerBar.layout.selectedTextColor = UIColor.red
        case 3:
            vc.tabPagerBar.layout.barStyle = .progressElastic
            vc.tabPagerBar.layout.selectedTextColor = UIColor.red
        default:
            vc.tabPagerBar.backgroundColor = UIColor.white
            vc.tabPagerBar.layout.barStyle = .cover
            vc.tabPagerBar.layout.progressRadius = 4
            vc.tabPagerBar.layout.selectedTextColor = UIColor.white
            vc.tabPagerBar.progressView.backgroundColor = UIColor.red
        }
        
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
