//
//  NodoRow.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 25/01/22.
//

import SwiftUI

struct NodoRow: View {
    @State var Id: Int
    @State var nodoItem: String = ""
    @State var nodoToggle: Bool = false
    @EnvironmentObject var todoDataItem: MyTodoData
    
    var body: some View {
                HStack{
                    Text(todoDataItem.id == Id ? todoDataItem.title : nodoItem)
                        .strikethrough(self.nodoToggle, color:  Color.gray)
                        .foregroundColor(self.nodoToggle ? Color.gray : .accentColor)
                        .multilineTextAlignment(.leading)
                        .opacity(self.nodoToggle ? 0.4 : 1)
                        .lineLimit(2)
                        .onAppear {
                            print("this \(todoDataItem.id == Id ? "true":"false")")
                        }
                        
                    Spacer()
                    Image(systemName:  (self.nodoToggle) ? "checkmark" : "square") //checkmark
                        .padding(.trailing, 6)
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
