//
//  ContentView.swift
//  tic-tac-toe
//
//  Created by Katie Rose Murphy Crowe on 06/06/2023.
//

import SwiftUI

// constants
let num_sq : Int = 9
let row_col_sz : Int = 3

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
    @Published var currentPlayer : Int = 0
    @Published var currentPlayerText : String = "player x's turn"
    @Published var winnerText : String = "draw"
    
    init(){
        for _ in 0...(num_sq-1) {
            squares.append(Square(status: .empty))
        }
    }
    
    func resetGame() {
        for i in 0...(num_sq-1) {
            squares[i].sqStatus = .empty
        }
        
        currentPlayer = 0
        currentPlayerText = "player x's turn"
        winnerText = "draw"
    }
    
    var gameOver : (SquareStatus, Bool) {
        get{
            if yesWinner != .empty {
                if yesWinner == .x {
                    self.winnerText = "player x wins"
                } else {
                    self.winnerText = "player o wins"
                }
                return (yesWinner, true)
            } else {
                for i in 0...(num_sq-1) {
                    if squares[i].sqStatus == .empty {
                        return (.empty, false)
                    }
                }
            }
            
            return (.empty, true)
        }
    }
    
    private var yesWinner: SquareStatus {
        get {
            for i in 0...(row_col_sz-1) {
                if let check = self.checkIndexes([i*row_col_sz, i*row_col_sz + 1, i*row_col_sz + 2]) {
                    return check
                }
                
                if let check = self.checkIndexes([i, i + row_col_sz, i + 2*row_col_sz]) {
                    return check
                }
            }
            
            if let check = self.checkIndexes([0, 4, 8]) {
                return check
            }
            
            if let check = self.checkIndexes([2, 4, 6]) {
                return check
            }
            
            return .empty
        }
    }
    
    private func checkIndexes(_ indexes : [Int]) -> SquareStatus? {
        guard let firstIndex = indexes.first else { return nil }
        let firstSqStatus = squares[firstIndex].sqStatus
        
        let allEq = indexes.allSatisfy({ squares[$0].sqStatus == firstSqStatus })
            
        if allEq && firstSqStatus != .empty {
            return firstSqStatus
        }
        
        return nil
    }
    
    /*
     private func checkIndexes(_ indexes : [Int]) -> SquareStatus? {
         var homeCounter : Int = 0
                 var visitorCounter : Int = 0
                 for index in indexes {
                     let square = squares[index]
                     if square.sqStatus == .x {
                         homeCounter += 1
                     } else if square.sqStatus == .o {
                         visitorCounter += 1
                     }
                 }
                 if homeCounter == 3 {
                     return .x
                 } else if visitorCounter == 3 {
                     return .o
                 }
                 return nil
     }
    */
    
    func makeMove(index: Int) -> Bool {
        if squares[index].sqStatus == .empty {
            if self.currentPlayer == 0 {
                squares[index].sqStatus = .x
                self.currentPlayerText = "player o's turn"
            } else {
                squares[index].sqStatus = .o
                self.currentPlayerText = "player x's turn"
            }
            
            self.currentPlayer = (self.currentPlayer + 1) % 2
            //if player == .x {
                // do ai move for o if playing against ai
            //}
            return true
        }
        return false
    }
}

struct SquareView : View {
    @ObservedObject var dataSource : Square
    
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            Text(self.dataSource.sqStatus == .x ? "X" : self.dataSource.sqStatus == .o ? "O" : " ")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .frame(width:70, height:70, alignment: .center)
                .background(Color.gray.opacity(0.3).cornerRadius(10))
                .padding(4)
        })
    }
}

struct ContentView: View {
    @StateObject var tttModel = TTTModel()
    @State var gameOver : Bool = false
    
    func buttonAction(_ index : Int) {
        _ = self.tttModel.makeMove(index: index)
        self.gameOver = self.tttModel.gameOver.1
    }
    
    var body: some View {
        VStack{
            Text("Tic Tac Toe")
                .bold()
                .foregroundColor(Color.black.opacity(0.7))
                .padding(.bottom)
                .font(.title2)
            
            ForEach(0 ..< row_col_sz, id: \.self, content: {
                row in
                HStack {
                    ForEach(0 ..< row_col_sz, id: \.self, content: {
                        col in
                        let index = row * 3 + col
                        SquareView(dataSource: tttModel.squares[index], action: {self.buttonAction(index)})
                    })
                }
            })
            
            Text(tttModel.currentPlayerText)
                .bold()
                .foregroundColor(Color.black.opacity(0.7))
                .padding(.bottom)
                .font(.title2)
        }.alert(isPresented: self.$gameOver, content: {
            Alert(title: Text("Game Over"), message: Text(self.tttModel.winnerText), dismissButton: Alert.Button.destructive(Text("OK"), action: {
                self.tttModel.resetGame()
                }))
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
