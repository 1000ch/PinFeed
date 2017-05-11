import Foundation

class PinboardURLProvider {
    static var network: String? {
        get {
            let secretToken = Setting.shared.secretToken
            let userId = Setting.shared.userId

            var components = URLComponents()
            components.scheme = "https"
            components.host = "feeds.pinboard.in"
            components.path = "/json/secret:\(secretToken)/u:\(userId)/network/"
            components.queryItems = [URLQueryItem(name: "count", value: "400")]
            return components.string
        }
    }
    
    static var bookmark: String? {
        get {
            let secretToken = Setting.shared.secretToken
            let userId = Setting.shared.userId

            var components = URLComponents()
            components.scheme = "https"
            components.host = "feeds.pinboard.in"
            components.path = "/json/secret:\(secretToken)/u:\(userId)/"
            components.queryItems = [URLQueryItem(name: "count", value: "400")]
            return components.string
        }
    }
    
    static var apiToken: String? {
        get {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.pinboard.in"
            components.path = "/v1/user/api_token/"
            components.user = Setting.shared.userId
            components.password = Setting.shared.password
            components.queryItems = [URLQueryItem(name: "format", value: "json")]
            return components.string
        }
    }
    
    static var secretToken: String? {
        get {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.pinboard.in"
            components.path = "/v1/user/secret/"
            components.user = Setting.shared.userId
            components.password = Setting.shared.password
            components.queryItems = [URLQueryItem(name: "format", value: "json")]
            return components.string
        }
    }
    
    static func getPost(tag: String?, dt: String?, url: String?, meta: Bool?) -> String? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.pinboard.in"
        components.path = "/v1/posts/get"
        components.user = Setting.shared.userId
        components.password = Setting.shared.password
        components.queryItems = [URLQueryItem(name: "format", value: "json")]
        if let tag = tag {
            components.queryItems?.append(URLQueryItem(name: "tag", value: tag))
        }
        if let dt = dt {
            components.queryItems?.append(URLQueryItem(name: "dt", value: dt))
        }
        if let url = url {
            components.queryItems?.append(URLQueryItem(name: "url", value: url))
        }
        if let meta = meta {
            components.queryItems?.append(URLQueryItem(name: "meta", value: meta ? "yes" : "no"))
        }
        return components.string
    }
    
    static func addPost(url: String, description: String, extended: String?, tags: String?, dt: String?, replace: Bool?, isPrivate: Bool?, isReadLater: Bool?) -> String? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.pinboard.in"
        components.path = "/v1/posts/add"
        components.user = Setting.shared.userId
        components.password = Setting.shared.password
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "url", value: url),
            URLQueryItem(name: "description", value: description)
        ]
        if let extended = extended {
            components.queryItems?.append(URLQueryItem(name: "extended", value: extended))
        }
        if let tags = tags {
            components.queryItems?.append(URLQueryItem(name: "tags", value: tags))
        }
        if let dt = dt {
            components.queryItems?.append(URLQueryItem(name: "dt", value: dt))
        }
        if let replace = replace {
            components.queryItems?.append(URLQueryItem(name: "replace", value: replace ? "yes" : "no"))
        }
        if let isPrivate = isPrivate {
            components.queryItems?.append(URLQueryItem(name: "shared", value: isPrivate ? "no" : "yes"))
        }
        if let isReadLater = isReadLater {
            components.queryItems?.append(URLQueryItem(name: "toread", value: isReadLater ? "yes" : "no"))
        }
        return components.string
    }
    
    static func deletePost(url: String) -> String? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.pinboard.in"
        components.path = "/v1/posts/delete"
        components.user = Setting.shared.userId
        components.password = Setting.shared.password
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "url", value: url)
        ]
        return components.string
    }
}
