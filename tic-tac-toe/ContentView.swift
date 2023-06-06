//
//  ContentView.swift
//  tic-tac-toe
//
//  Created by Katie Rose Murphy Crowe on 06/06/2023.
//

import SwiftUI

enum SquareStatus {
    case empty
    case x // user 1
    case o // user 2
}

class Square : ObservableObject {
    @Published var sqStatus : SquareStatus
    init(status:SquareStatus) {
        self.sqStatus = status
    }
}

class TTTModel : ObservableObject {
    @Published var squares = [Square]()
    
    init(){
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }
}

struct ContentView: View {
    @StateObject var tttModel = TTTModel()
    
    var body: some View {
        VStack{
            
            ForEach(0 ..< Int(tttModel.squares.count / 3), content: {
                row in
                HStack {
                    ForEach(0 ..< 3, content: {
                        column in
                        Color.gray.frame(width:70, height:70, alignment: .center)
                    })
                }
            })
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
