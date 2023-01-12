//
//  DatabaseManager.swift
//  Thoughts
//
//  Created by Alisher Abdulin on 28.12.2022.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    
    private init() {}
    
    public func insert(
        blogPost: StreamPost,
        email: String,
        completion: @escaping (Bool) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data: [String: Any] = [
            "id": blogPost.identifier,
            "title": blogPost.title,
            "body": blogPost.text,
            "created": blogPost.timestamp,
            "headerImageurl": blogPost.headerImageUrl?.absoluteString ?? ""
        ]
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(blogPost.identifier)
            .setData(data) { error in
                completion(error == nil)
                
            }
    }
    
    public func getAllPosts(
        completion: @escaping ([StreamPost]) -> Void
    ) {
        //get all users
        //from each user get their posts
        var result: [StreamPost] = []
        
        database
            .collection("users")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }), error == nil else {
                    return
                }
                
                let emails: [String] = documents.compactMap({ return $0["email"] as? String })
                
                print(emails)
                guard !emails.isEmpty else {
                    completion([])
                    return
                }
                
                let group = DispatchGroup()
                
               
                
                for email in emails {
                    group.enter()
                    self?.getPosts(for: email) { userPosts in
                        defer {
                            group.leave()
                        }
                        result.append(contentsOf: userPosts )
                    }
                }
                
                group.notify(queue: .global()) {
                    print("Feed posts: \(result.count)")
                    completion(result)
                }
            }
        
        
    }
    
    public func getPosts(
        for email: String,
        completion: @escaping ([StreamPost]) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .getDocuments { snapshot, error in
                guard let documents =
                        snapshot?.documents.compactMap({ $0.data()}),
                        error == nil else {
                    return
                }
                
                let posts: [StreamPost] = documents.compactMap( { dictinary in
                    guard let id = dictinary["id"] as? String,
                          let title = dictinary["title"] as? String,
                          let body = dictinary["body"] as? String,
                          let created = dictinary["created"] as? TimeInterval,
                          let headerImageurl = dictinary["headerImageurl"] as? String else {
                    print("Invalid post fetch converion")
                        return nil
                    }
                   
                    let post = StreamPost(
                        identifier: id,
                        title: title,
                        timestamp: created,
                        headerImageUrl: URL(string: headerImageurl),
                        text: body)
                    return post
                } )
                
                completion(posts)
                
                
            }
    }
    
    public func insert(
        user: User,
        completion: @escaping (Bool) -> Void
    ) {
        let documentId = user.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data = [
            "email": user.email,
            "name": user.name
        ]
        database
            .collection("users")
            .document(documentId)
            .setData(data) { error in
                completion(error == nil)
                
            }
    }
    
    public func getUser(
        email: String,
        completion: @escaping (User?) -> Void) {
        let documentId = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        database
            .collection("users")
            .document(documentId)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() as? [String: String],
                      let name = data["name"],
                      error == nil else {
                    return
                }
                
                let ref = data["profile_photo"]
                
                let user = User(name: name, email: email, profilePictureRef: ref)
                completion(user)
               
            }
    }
    
    func updateProfilePhoto(
        email: String,
        completion: @escaping (Bool) -> Void
    ) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        let photoReference = "profile_picture/\(path)/photo.png"
        
        let dbRef = database
            .collection("users")
            .document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {
                return
            }
            data["profile_photo"] = photoReference
            
            dbRef.setData(data) {error in
                completion(error == nil)
            }
        }
        
        
        
        
    }
   
    
    
}
