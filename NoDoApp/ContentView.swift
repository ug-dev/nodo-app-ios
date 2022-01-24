//
//  ContentView.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 17/01/22.
//

import SwiftUI
import ActivityIndicatorView

struct GlobalListState {
    var loading = true
}

class MyTodoData: ObservableObject {
    @Published var id = 0
    @Published var title = "some text"
    @Published var description = "some text"
    @Published var date = "some text"
    @Published var isDone = false
}

struct ModalView: View {
    @EnvironmentObject var todoDataItem: MyTodoData
    @StateObject var updateTodoDataItem = MyTodoData()
    @Binding var isShowing: Bool
    @Binding var editNodo: String
    @State var globalListState = GlobalListState()
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            if (isShowing) {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                mainView
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
    
    var mainView: some View {
        VStack {
            HStack{
            Image(systemName: "plus.circle")
                    .foregroundColor(Color.white)
        
            Group{
                TextField(
                        "What will you not do today",
                        text: self.$editNodo
                )
                    .foregroundColor(.white)
                    .onSubmit {
                        print("🚀🚀🚀🚀okay \(editNodo) isDone: \(todoDataItem.isDone) Id: \(todoDataItem.id)")
                        todoDataItem.title = editNodo
                        globalListState.loading = true
                        updateTodoApi(isDone: todoDataItem.isDone, id: todoDataItem.id, title: editNodo)
                        self.editNodo = ""
                        isShowing = false
                    }
                    .padding(.all, 12)
                    .accessibilityIgnoresInvertColors()
                    
            }.background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .shadow(radius: 4)
            
        }
        .padding(.horizontal, 14)
            
            Button {
                isShowing = false
            } label: {
                Text("Cancel")
                    .foregroundColor(.white)
                    .padding(.vertical, 30)
            }
        }
        .frame(height: UIScreen.main.bounds.size.height)
        .frame(maxWidth: .infinity)
        .background(Color("my-color"))
        .opacity(0.3)
    }
}

struct ContentView: View {
    @StateObject var todoDataItem = MyTodoData()
    @State var globalListState = GlobalListState()
    @State var nodoList = [TodoDataModel]()
    @State var showModel = false
    @State var editNodo = ""
    @State var nodo: String = ""

    
    func fetchTodos() {
        guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/") else {return}
        print("okay fetch fuck")
        URLSession.shared
            .dataTask(with: url) {
                (data, _, _) in
                guard let data = data else {return}

                let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
                print("🚀🚀🚀🚀 fetch \(dataList)")

                DispatchQueue.main.async {
                    nodoList = dataList
                    globalListState.loading = false
                    print("🚀🚀🚀🚀 nodoList \(nodoList)")
                }
            }.resume()
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    HStack{
                    Image(systemName: "plus.circle")
                  
                    Group{
                        TextField(
                                "What will you not do today",
                                text: self.$nodo
                        )
                            .foregroundColor(.white)
                            .onSubmit {
                                if (nodo != "") {
                                    print("🚀🚀🚀🚀okay \(nodo)")
                                    globalListState.loading = true
                                    addTodoApi(todo: self.nodo)
                                    fetchTodos()
                                    self.nodo = ""
                                } else {
                                    print("No Bitch!")
                                }
                                
                            }
                            .padding(.all, 12)
                            .accessibilityIgnoresInvertColors()
                            
                    }.background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .shadow(radius: 4)
                }
                .padding(.horizontal, 14)
                
                if (globalListState.loading) {
                    ZStack {
                        ActivityIndicatorView(isVisible: $globalListState.loading, type: .default)
                        
                    }.frame(width: 20, height: 20).padding(.vertical, 28)
                }
                
                if (!globalListState.loading && nodoList.count == 0) {
                    HStack {
                        Text("No Data...")
                            .font(.title2)
                    }.padding(.top, 34)
                }
                    List {
                        ForEach(nodoList) { item in
                            NodoRow(Id: item.id, nodoItem: item.title,nodoToggle: item.isDone)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button(action: {
                                            // edit
                                            todoDataItem.id = item.id
                                            todoDataItem.title = item.title
                                            todoDataItem.description = item.description
                                            todoDataItem.date = item.date
                                            todoDataItem.isDone = item.isDone
                                            print("🚀ID: \(item.id)")
                                            showModel = true
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                        }
                                        .tint(.blue)
                                    }
                                .swipeActions(allowsFullSwipe: true) {
                                    Button(action: {
                                        deleteTodo(todoDataModel: item)
                                        print("do something\(item.id)")
                                        deleteTodoApi(id: item.id)
                                    }) {
                                        Image(systemName: "trash.circle.fill")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                    .refreshable {
                        fetchTodos()
                    }
                    
                    //Modal
                    if (showModel) {
                        ModalView(isShowing: $showModel, editNodo: $editNodo)
                    }
                    
            }
                .navigationBarTitle(Text("NoDo APP"))
        }
        .onAppear {
            fetchTodos()
        }
        }
        .environmentObject(todoDataItem)
    }
    
    func deleteTodo(todoDataModel: TodoDataModel) {
        if let indexToDelete = nodoList.firstIndex(where: {$0.id == todoDataModel.id}) {
            self.nodoList.remove(at: indexToDelete)
        }
    }
}

func addTodoApi(todo: String) {
    @State var globalListState = GlobalListState()
    guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/createTodo/") else {return}
    var request = URLRequest(url: url)
    
    print("making api call....")
    
    //method headers
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: AnyHashable] = [
        "title": todo,
        "description": "",
        "isDone": false,
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) {data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
        print("🚀🚀🚀🚀 Todo Added: \(dataList)")
//        globalListState.nodoList = dataList
        globalListState.loading = false
    }
    task.resume()
}

func updateTodoApi(isDone: Bool, id: Int, title: String) {
    @EnvironmentObject var todoDataItem: MyTodoData
    @State var globalListState = GlobalListState()
    guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/updateTodo/\(id)/") else {return}
    var request = URLRequest(url: url)
    
    print("making api call....")
    print("🚀Title \(title)")
    print("🚀isDone \(isDone)")
    
    //method headers
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: AnyHashable] = [
        "title": title,
        "isDone": isDone,
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) {data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
        print("🚀🚀🚀🚀 Todo Updated: \(dataList)")
        let my = ContentView()
        my.fetchTodos()
    }
    task.resume()
}

func deleteTodoApi(id: Int) {
    @State var globalListState = GlobalListState()
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

struct NodoRow: View {
    @State var Id: Int
    @State var nodoItem: String = ""
    @State var nodoToggle: Bool = false
    @EnvironmentObject var todoDataItem: MyTodoData
    
    var body: some View {
                HStack{
                    
                    Text(nodoItem)
                        .strikethrough(self.nodoToggle, color:  Color.gray)
                        .foregroundColor(self.nodoToggle ? Color.gray : .accentColor)
                        .multilineTextAlignment(.leading)
                        .opacity(self.nodoToggle ? 0.4 : 1)
                        .lineLimit(2)
                        
                    Spacer()
                    Image(systemName:  (self.nodoToggle) ? "checkmark" : "square") //checkmark
                        .padding(.trailing, 4)
                }
                .padding(.vertical, 12)
                .cornerRadius(8)
                .lineSpacing(12)
                .onTapGesture {
                    print("🚀hello update \(!self.nodoToggle) \(Id)")
                    updateTodoApi(isDone: !self.nodoToggle, id: Id, title: nodoItem)
                    self.nodoToggle = !self.nodoToggle
                }
    }
}
