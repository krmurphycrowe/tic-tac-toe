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
    @Published var currentPlayerText : String = "Player X's Turn"
    
    init(){
        for _ in 0...(num_sq-1) {
            squares.append(Square(status: .empty))
        }
    }
    
    func resetGame() {
        for _ in 0...(num_sq-1) {
            squares.append(Square(status: .empty))
        }
    }
    
    var gameOver : (SquareStatus, Bool) {
        get{
            if yesWinner != .empty {
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
            for i in 0...row_col_sz {
                if let check = self.checkIndexes([i*row_col_sz, i*row_col_sz + 1, i*row_col_sz + 2]) {
                    return check
                }
                
                if let check = self.checkIndexes([i, i + row_col_sz, i + 2*row_col_sz]) {
                    return check
                }
            }
            
            if let check = self.checkIndexes([0, 4, 9]) {
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
        let allEq = indexes.dropFirst().allSatisfy({ squares[$0].sqStatus == squares[firstIndex].sqStatus })
        if allEq {
            if squares[indexes[firstIndex]].sqStatus != .empty {
                return squares[indexes[firstIndex]].sqStatus
            }
        }
        
        return nil
    }
    
    func makeMove(index: Int) -> Bool {
        if squares[index].sqStatus == .empty {
            if self.currentPlayer == 0 {
                squares[index].sqStatus = .x
                self.currentPlayerText = "Player O's Turn"
            } else {
                squares[index].sqStatus = .o
                self.currentPlayerText = "Player X's Turn"
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
    
    func buttonAction(_ index : Int) {
        _ = self.tttModel.makeMove(index: index)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
