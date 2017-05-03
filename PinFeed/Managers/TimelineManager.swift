import Alamofire
import SwiftyJSON
import RealmSwift

class TimelineManager {
    class var sharedInstance: TimelineManager {
        struct Static {
            static let instance = TimelineManager()
        }
        return Static.instance
    }
    
    var timeline: [Bookmark] = []
    
    init() {
        autoreleasepool {
            let realm = try! Realm()

            for recent in realm.objects(Recents.self) {
                timeline.append(Bookmark(
                    title: recent.d,
                    tag: recent.t,
                    url: recent.u,
                    dateTime: recent.dt,
                    author: recent.a,
                    description: recent.n
                ))
            }
        }
    }
    
    func fetch(block: (() -> ())?) {
        Alamofire
            .request(PinboardURLProvider.network ?? "")
            .responseJSON { response in
                guard let data = response.result.value else {
                    block?()
                    return
                }
                
                self.timeline.removeAll()
                
                JSON(data).forEach { (_, json) in
                    self.timeline.append(Bookmark(json: json))
                }
                
                block?()
                
                DispatchQueue.global().async {
                    autoreleasepool {
                        let realm = try! Realm()

                        try! realm.write {
                            realm.delete(realm.objects(Recents.self))

                            for timeline in self.timeline {
                                realm.add(Recents(bookmark: timeline))
                            }
                        }
                    }
                }
        }
    }
    
    func clear(block: @escaping () -> ()) {
        DispatchQueue.global().async {
            autoreleasepool {
                let realm = try! Realm()

                try! realm.write {
                    realm.delete(realm.objects(Recents.self))
                }
            }
            
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
