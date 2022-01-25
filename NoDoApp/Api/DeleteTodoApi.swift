//
//  DeleteTodoApi.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 25/01/22.
//

import Foundation

func deleteTodoApi(id: Int) {
    guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/deleteTodo/\(id)/") else {return}
    var request = URLRequest(url: url)
    
    print("making api call....")
    
    //method headers
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) {data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
        print("🚀🚀🚀🚀 Todo Deleted: \(dataList)")
//        globalListState.nodoList = dataList
    }
    task.resume()
}
