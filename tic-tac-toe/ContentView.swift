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
    
    func makeMove(index: Int, player: SquareStatus) -> Bool {
        if squares[index].sqStatus == .empty {
            squares[index].sqStatus = player
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
    
    func buttonAction(_ index : Int) {}
    
    var body: some View {
        VStack{
            
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
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
