//
//  ViewController.swift
//  API_Test
//
//  Created by Константин Машейченко on 01.02.2022.
//

import UIKit

class UserListViewController: UIViewController {
    
    private let requestManager = RequestManager()
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var currentPage = 0
    private var data = [GitHubUserAtList]()
    private var fetchingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(GitTableViewCell.nib, forCellReuseIdentifier: GitTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setup()
    }
    
}

private extension UserListViewController {
    
    func setup() {
        fetchingMore = true
        loadUsers()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc
    func handleRefresh() {
        if !tableView.isDragging {
            refreshTable()
        }
    }
    
    func refreshTable() {
        let randomInt = Int.random(in: 0 ... 10000)
        DispatchQueue.main.async {
            self.data = []
            self.tableView.reloadData()
            self.tableView.refreshControl?.beginRefreshing()
        }
        currentPage = 0
        fetchingMore = true
        loadUsers(since: randomInt)
    }
    
    func loadUsers(since: Int = 0) {
        requestManager.requestFor(page: currentPage, since: since) { result in
            self.fetchingMore = false
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
            guard result,
                  let fetchedData = self.requestManager.resultRequestList else { return }
            fetchedData.map( { self.data.append($0) } )
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.currentPage += 1
        }
    }
    
    func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:
                                                        GitTableViewCell.identifier, for: indexPath) as? GitTableViewCell {
            cell.setDefaultImage()
            cell.fillData(imageUrl: data[indexPath.row].avatarUrl,
                          title: data[indexPath.row].login,
                          subTitle: data[indexPath.row].id)
            
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: GitTableViewCell.identifier,
                                             for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyBoard.instantiateViewController(withIdentifier: "details")
                as? UserDeatilsViewController else { return }
        let cell = tableView.cellForRow(at: indexPath) as? GitTableViewCell
        guard let avatar = cell?.giveImage(),
              let login = cell?.giveLogin() else { return }
        detailsVC.avatar = avatar
        detailsVC.login = login
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (scrollView.contentSize.height - scrollView.frame.height * 1.1) {
            guard !fetchingMore else { return }
            fetchingMore = true
            self.tableView.tableFooterView = createSpinnerFooter()
            loadUsers(since: data.last?.id ?? 0)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.refreshControl?.isRefreshing == true {
            refreshTable()
        }
    }
}

