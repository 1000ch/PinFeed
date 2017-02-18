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

    private let realm = try! Realm()
    
    var timeline: [Bookmark] = []
    
    init() {
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

                try! self.realm.write {
                    self.realm.delete(self.realm.objects(Recents.self))
                    for timeline in self.timeline {
                        self.realm.add(Recents(bookmark: timeline))
                    }
                }
        }
    }
    
    func clear(block: @escaping () -> ()) {
        DispatchQueue.global().async {
            try! self.realm.write {
                self.realm.delete(self.realm.objects(Recents.self))
            }
            
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
