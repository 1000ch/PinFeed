import UIKit
import MisterFusion

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    private let indicatorView = UIActivityIndicatorView()
    
    private let notificationView = UINib.instantiate(nibName: "URLNotificationView", ownerOrNil: TimelineViewController.self) as? URLNotificationView
    
    var timeline: [Bookmark] = []
    
    var timelineDisplayed: [Bookmark] = []
    
    var limit: Int {
        return timeline.count >= 50 ? 50 : timeline.count
    }
    
    var isLoading = false

    var faviconCache: [URL: Data] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        title = "Timeline"
        indicatorView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        indicatorView.activityIndicatorViewStyle = .gray
        view?.addSubview(indicatorView)
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.register(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "data")
        timelineTableView.alwaysBounceVertical = true
        timelineTableView.addSubview(refreshControl)
        timelineTableView.rowHeight = UITableViewAutomaticDimension
        timelineTableView.estimatedRowHeight = 2
        
        if let notificationView = notificationView {
            notificationView.isHidden = true
            notificationView.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
            view?.addLayoutSubview(notificationView, andConstraints:
                notificationView.top |==| view.bottom |-| 103,
                notificationView.right,
                notificationView.left,
                notificationView.bottom |==| view.bottom |-| 49
            )
        }

        URLNotificationManager.shared.listen(observer: self, selector: #selector(didCopyURL), object: nil)
        
        refreshControl.addTarget(self, action: #selector(didRefresh), for: UIControlEvents.valueChanged)

        timeline = (TimelineManager.shared.timeline +
            BookmarkManager.shared.bookmark).sorted { a, b in
                return a.date.compare(b.date).rawValue > 0
        }
        
        if timeline.count != 0 {
            if indicatorView.isAnimating {
                indicatorView.stopAnimating()
            }
            
            loadNext(clear: true)
        } else {
            indicatorView.startAnimating()
            
            refresh {
                if self.indicatorView.isAnimating {
                    self.indicatorView.stopAnimating()
                }
                
                self.loadNext(clear: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
    }
    
    func loadNext(clear: Bool = false) {
        if isLoading {
            return
        }
        
        isLoading = true

        DispatchQueue.main.async {
            if clear {
                self.timelineDisplayed.removeAll()
            }

            var insertList: [IndexPath] = [];
            let from = self.timelineDisplayed.count
            let to = self.timelineDisplayed.count + self.limit
            
            for i in from..<to {
                insertList.append(IndexPath(row: i, section: 0))
            }

            self.timelineDisplayed.append(contentsOf: self.timeline[0..<self.limit])
            self.timeline.removeFirst(self.limit)
            
            if clear {
                self.timelineTableView.reloadData()
            } else {
                self.timelineTableView.insertRows(at: insertList, with: .none)
            }
            
            self.isLoading = false
        }
    }
    
    func refresh(block: (() -> ())?) {
        let concurrent = DispatchGroup()
        TimelineManager.shared.fetch(group: concurrent)
        BookmarkManager.shared.fetch(group: concurrent)
        
        concurrent.notify(queue: .global()) {
            self.timeline = (TimelineManager.shared.timeline +
                BookmarkManager.shared.bookmark).sorted { a, b in
                    return a.date.compare(b.date).rawValue > 0
            }
            
            DispatchQueue.global().async {
                TimelineManager.shared.sync()
                BookmarkManager.shared.sync()
            }
            
            block?()
        }
    }
    
    @objc func didRefresh() {
        refresh {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.loadNext(clear: true)
        }
    }
    
    @objc func didCopyURL(notification: Notification?) {
        guard let url = notification?.userInfo?["url"] as? URL else {
            return
        }
        
        guard let notificationView = notificationView else {
            return
        }
        
        notificationView.isHidden = false
        notificationView.url = url
        notificationView.urlLabel.text = url.absoluteString

        if let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(url.absoluteString)") {
            DispatchQueue.global().async {
                if let faviconData = try? Data(contentsOf: faviconURL) {
                    DispatchQueue.main.async {
                        notificationView.faviconImageView?.image = UIImage(data: faviconData)
                    }
                }
            }
        }
        
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(didTimeoutNotification), userInfo: nil, repeats: false)
    }
    
    @objc func didTapNotification(sender: UIControl) {
        guard let webViewController = UIStoryboard.instantiateViewController(name: "Main", identifier: "WebViewController") as? WebViewController else {
            return
        }
        
        guard let notificationView = sender as? URLNotificationView else {
            return
        }
        
        notificationView.isHidden = true
        webViewController.url = notificationView.url

        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @objc func didTimeoutNotification() {
        notificationView?.isHidden = true
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading {
            return
        }
        
        if timeline.count == 0 {
            return
        }
        
        if indexPath.row != timelineDisplayed.count - 1 {
            return
        }
        
        loadNext()
    }
}

extension TimelineViewController: UITableViewDataSource {
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineDisplayed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = timelineDisplayed[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "data", for: indexPath) as! BookmarkCell
        cell.authorLabel?.text = data.author
        cell.dateTimeLabel?.text = data.relativeDateTime
        cell.faviconImageView?.image = nil
        cell.descriptionLabel?.text = data.description
        cell.titleLabel?.text = data.title

        if let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(data.url.absoluteString)") {
            DispatchQueue.global().async {
                if let cachedData = self.faviconCache[faviconURL] {
                    DispatchQueue.main.async {
                        cell.faviconImageView?.image = UIImage(data: cachedData)
                    }
                } else if let faviconData = try? Data(contentsOf: faviconURL) {
                    self.faviconCache[faviconURL] = faviconData

                    DispatchQueue.main.async {
                        cell.faviconImageView?.image = UIImage(data: faviconData)
                    }
                }
            }
        }

        return cell
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let webViewController = UIStoryboard.instantiateViewController(name: "Main", identifier: "WebViewController") as? WebViewController else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        webViewController.url = timelineDisplayed[indexPath.row].url

        navigationController?.pushViewController(webViewController, animated: true)
    }
}

extension TimelineViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let cellPosition = timelineTableView?.convert(location, from: view) else {
            return nil
        }
        
        guard let indexPath = timelineTableView.indexPathForRow(at: cellPosition) else {
            return nil
        }
        
        guard let webViewController = UIStoryboard.instantiateViewController(name: "Main", identifier: "WebViewController") as? WebViewController else {
            return nil
        }
        
        webViewController.url = timelineDisplayed[indexPath.row].url

        return webViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension TimelineViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
    }
}
