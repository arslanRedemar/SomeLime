//
//  UserLoginFunctions.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/31.
//

import Foundation
import Firebase

protocol UserLoginFunctions {
    
    func signIn(ID: String, PW: String) async throws -> Void
    
    func logOut() throws -> Void
    
    func isLoggedIn() -> Bool
    
}

class FirebaseLoginFunctions: UserLoginFunctions {
    
    func signIn(ID: String, PW: String) async throws {
        
        do {
            try await FirebaseAuth.Auth.auth().signIn(withEmail: ID, password: PW)
        } catch{
            throw UserLoginFailures.LoginFailed
        }
        
    }
    
    func logOut() throws
    {
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch{
            throw UserLoginFailures.LogOutFailed
        }
        
    }

    
    func isLoggedIn() -> Bool {
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
        
    }
    
    
}




