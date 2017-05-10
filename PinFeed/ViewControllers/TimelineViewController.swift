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

        URLNotificationManager.sharedInstance.listen(observer: self, selector: #selector(didCopyURL), object: nil)
        
        refreshControl.addTarget(self, action: #selector(didRefresh), for: UIControlEvents.valueChanged)

        timeline = (TimelineManager.sharedInstance.timeline +
            BookmarkManager.sharedInstance.bookmark).sorted { a, b in
                return a.date.compare(b.date).rawValue > 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadNext(clear: Bool) {
        DispatchQueue.main.async {
            if clear {
                self.timelineDisplayed.removeAll()
            }

            self.timelineDisplayed.append(contentsOf: self.timeline[0..<self.limit])
            self.timeline.removeFirst(self.limit)
            self.timelineTableView.reloadData()
        }
    }
    
    func refresh(block: (() -> ())?) {
        let concurrent = DispatchGroup()
        TimelineManager.sharedInstance.fetch(group: concurrent)
        BookmarkManager.sharedInstance.fetch(group: concurrent)
        
        concurrent.notify(queue: .global()) {
            self.timeline = (TimelineManager.sharedInstance.timeline +
                BookmarkManager.sharedInstance.bookmark).sorted { a, b in
                    return a.date.compare(b.date).rawValue > 0
            }
            
            DispatchQueue.global().async {
                TimelineManager.sharedInstance.sync()
                BookmarkManager.sharedInstance.sync()
            }
            
            block?()
        }
    }
    
    func didRefresh() {
        refresh {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.loadNext(clear: true)
        }
    }
    
    func didCopyURL(notification: Notification?) {
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
    
    func didTapNotification(sender: UIControl) {
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
    
    func didTimeoutNotification() {
        notificationView?.isHidden = true
    }
}

extension TimelineViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !timelineTableView.isDragging {
            return
        }
        
        if timeline.count == 0 {
            return
        }
        
        let offsetY = timelineTableView.contentOffset.y
        let contentHeight = timelineTableView.contentSize.height
        let frameHeight = timelineTableView.bounds.size.height
        
        if offsetY >= contentHeight - frameHeight {
            loadNext(clear: false)
        }
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
