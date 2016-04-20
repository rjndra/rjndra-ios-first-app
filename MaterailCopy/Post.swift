//
//  Post.swift
//  MaterailCopy
//
//  Created by User on 4/8/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Post {

    private var _username: String!
    private var _like: Int!
    private var _postDescrption: String!
    private var _imageUrl: String?
    
    private var _postKey: String!
    private var _postRef : Firebase!
    
    var username: String {
        return _username
    }
    
    var like: Int {
        return _like
    }
    
    var postDescription: String {
        return _postDescrption
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var postKey: String {
        return _postKey
    }
    
    var postRef : Firebase {
        return _postRef
    }
    
    init(description: String, imageUrl : String?, username :String) {
        self._postDescrption = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postKey: String, dict: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dict["likes"] as? Int {
            self._like = likes
        }
        
        if let description = dict["description"] as? String {
            self._postDescrption = description
        }
        
        if let imageUrl = dict["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
    }
    
    func adjustLike(addLike: Bool) {
        if addLike {
            _like = _like + 1
        } else {
            _like = _like  - 1
        }
        _postRef.childByAppendingPath("likes").setValue(_like)
    }
    
}
