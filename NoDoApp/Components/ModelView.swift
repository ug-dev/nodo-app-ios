//
//  ModelView.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 25/01/22.
//

import SwiftUI

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
