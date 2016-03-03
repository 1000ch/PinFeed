import Foundation

class PinboardURLProvider {
    static var network: String? {
        get {
            let secretToken = Setting.sharedInstance.secretToken
            let userId = Setting.sharedInstance.userId

            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "feeds.pinboard.in"
            components.path = "/json/secret:\(secretToken)/u:\(userId)/network/"
            components.queryItems = [NSURLQueryItem(name: "count", value: "400")]
            return components.string
        }
    }
    
    static var bookmark: String? {
        get {
            let secretToken = Setting.sharedInstance.secretToken
            let userId = Setting.sharedInstance.userId

            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "feeds.pinboard.in"
            components.path = "/json/secret:\(secretToken)/u:\(userId)/"
            components.queryItems = [NSURLQueryItem(name: "count", value: "400")]
            return components.string
        }
    }
    
    static var apiToken: String? {
        get {
            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "api.pinboard.in"
            components.path = "/v1/user/api_token/"
            components.user = Setting.sharedInstance.userId
            components.password = Setting.sharedInstance.password
            components.queryItems = [NSURLQueryItem(name: "format", value: "json")]
            return components.string
        }
    }
    
    static var secretToken: String? {
        get {
            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "api.pinboard.in"
            components.path = "/v1/user/secret/"
            components.user = Setting.sharedInstance.userId
            components.password = Setting.sharedInstance.password
            components.queryItems = [NSURLQueryItem(name: "format", value: "json")]
            return components.string
        }
    }
    
    static func getPost(tag: String?, dt: String?, url: String?, meta: Bool?) -> String? {
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.pinboard.in"
        components.path = "/v1/posts/get"
        components.user = Setting.sharedInstance.userId
        components.password = Setting.sharedInstance.password
        components.queryItems = [NSURLQueryItem(name: "format", value: "json")]
        if let tag = tag {
            components.queryItems?.append(NSURLQueryItem(name: "tag", value: tag))
        }
        if let dt = dt {
            components.queryItems?.append(NSURLQueryItem(name: "dt", value: dt))
        }
        if let url = url {
            components.queryItems?.append(NSURLQueryItem(name: "url", value: url))
        }
        if let meta = meta {
            components.queryItems?.append(NSURLQueryItem(name: "meta", value: meta ? "yes" : "no"))
        }
        return components.string
    }
    
    static func addPost(url: String, description: String, extended: String?, tags: String?, dt: String?, replace: Bool?, isPrivate: Bool?, isReadLater: Bool?) -> String? {
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.pinboard.in"
        components.path = "/v1/posts/add"
        components.user = Setting.sharedInstance.userId
        components.password = Setting.sharedInstance.password
        components.queryItems = [
            NSURLQueryItem(name: "format", value: "json"),
            NSURLQueryItem(name: "url", value: url),
            NSURLQueryItem(name: "description", value: description)
        ]
        if let extended = extended {
            components.queryItems?.append(NSURLQueryItem(name: "extended", value: extended))
        }
        if let tags = tags {
            components.queryItems?.append(NSURLQueryItem(name: "tags", value: tags))
        }
        if let dt = dt {
            components.queryItems?.append(NSURLQueryItem(name: "dt", value: dt))
        }
        if let replace = replace {
            components.queryItems?.append(NSURLQueryItem(name: "replace", value: replace ? "yes" : "no"))
        }
        if let isPrivate = isPrivate {
            components.queryItems?.append(NSURLQueryItem(name: "shared", value: isPrivate ? "no" : "yes"))
        }
        if let isReadLater = isReadLater {
            components.queryItems?.append(NSURLQueryItem(name: "toread", value: isReadLater ? "yes" : "no"))
        }
        return components.string
    }
    
    static func deletePost(url: String) -> String? {
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.pinboard.in"
        components.path = "/v1/posts/delete"
        components.user = Setting.sharedInstance.userId
        components.password = Setting.sharedInstance.password
        components.queryItems = [
            NSURLQueryItem(name: "format", value: "json"),
            NSURLQueryItem(name: "url", value: url)
        ]
        return components.string
    }
}