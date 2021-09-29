//
//  SQLManager.swift
//  SQLProject
//
//  Created by dhanasekaran on 27/09/21.
//

import Foundation
import SQLite

class SQLManager
{
    private let db: Connection
    static let shared = createDBOnDocuments(withName: "sql_project_db.sqlite")
    
    static func createDBOnDocuments(withName name: String) -> SQLManager {
        var docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        docUrl.appendPathComponent(name)
        return try! SQLManager(dbpath: docUrl.path)
    }
    
    static var dbConnection: Connection {
        return SQLManager.shared.db
    }
    
    private init(dbpath: String) throws {
        db = try Connection(dbpath)
    }
    
    func createTable() throws {
        try UserTable().createTable()
    }
}

enum SQLError: Error {
    case invalidRow
}

struct UserTable {
    
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    
    let userTable = Table("user_table")
    
    
    func createTable() throws {
        let connection = SQLManager.dbConnection
        
        try connection.run(
            userTable.create(ifNotExists: true, block: { tb in
                tb.column(id, primaryKey: true)
                tb.column(name)
                tb.column(email)
            })
        )
    }
    
    func insert(user: User) throws {
        
        var setters = [Setter]()
        
        setters.append(name <- user.name)
        setters.append(email <- user.emailID)
        
        let connection = SQLManager.dbConnection
        
        try connection.run(
            userTable.insert(setters)
        )
    }
    
    func getUsers() throws -> [User] {
        let connection = SQLManager.dbConnection
        
        let selectQuery = userTable.select([ id, name, email ])
        
        var users = [User]()
        
        for row in try connection.prepare(selectQuery)
        {
            let user = try getUserFromRow(row)
            
            users.append(user)
        }
        
        return users
    }
    
    func getUserFromRow(_ row: Row) throws -> User {
        
        guard let user_id = try? row.get(id),
              let user_name = try? row.get(name),
              let user_email = try? row.get(email) else {
            throw SQLError.invalidRow
        }
        
        return User(id: user_id, name: user_name, emailID: user_email)
    }
    
    func removeUser(_ user: User) throws {
        let connection = SQLManager.dbConnection
        
        let selectedUser = userTable.filter(id == user.id)
        
        try connection.run(
            selectedUser.delete()
        )
    }
    
    func updateUser(_ user: User, newUserName: String) throws {
        let connection = SQLManager.dbConnection
        
        let selectedUser = userTable.filter(id == user.id)
        var setters = [Setter]()
        
        setters.append(id <- user.id)
        setters.append(name <- newUserName)
        setters.append(email <- user.emailID)
        
        
        try connection.run(
            selectedUser.update(setters)
        )
    }
}
