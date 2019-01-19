//
//  Game+Notation.swift
//  Leela
//
//  Created by Douglas Pedley on 1/18/19.
//  Copyright © 2019 d0. All rights reserved.
//

/*
[Event "F/S Return Match"]
[Site "Belgrade, Serbia JUG"]
[Date "1992.11.04"]
[Round "29"]
[White "Fischer, Robert J."]
[Black "Spassky, Boris V."]
[Result "1/2-1/2"]

1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called the Ruy Lopez.}
4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7
11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5
Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6
23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5
hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5
35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6
Nf2 42. g4 Bd3 43. Re6 1/2-1/2
*/

import Foundation

extension Chess.Game {
    public enum PGNResult: String {
        case blackWon = "0-1"
        case whiteWon = "1-0"
        case draw = "1/2-1/2"
        case other = "*"
    }
    
    public struct AnnotatedMove {
        var side: Chess.Side
        var move: String
        var fenAfterMove: String
        var annotation: String? = nil
    }
    
    public struct PortableNotation { // PGN
        var eventName: String // the name of the tournament or match event.
        var site: String      // the location of the event. This is in City, Region COUNTRY format,
                              // where COUNTRY is the three-letter International Olympic Committee code
                              // for the country. An example is New York City, NY USA.
        var date: Date        // the starting date of the game, in YYYY.MM.DD form. ?? is used for unknown values.
        var round: Int        // the playing round ordinal of the game within the event.
        var black: String     // the player of the black pieces, in Lastname, Firstname format.
        var white: String     // the player of the white pieces, same format as black.
        var result: PGNResult // the result of the game. This can only have four possible values:
                              // 1-0 (White won), 0-1 (Black won), 1/2-1/2 (Draw),
                              // or * (other, e.g., the game is ongoing).
        var tags: [String: String] = [:]
        var moves: [AnnotatedMove]
        
        var formattedString: String {
            var PGN = "[Event \"\(eventName)\"]\n[Site \"\(site)\"]\n[Date \"\(date)\"]\n[Round \"\(round)\"]\n[White \"\(white)\"]\n[Black \"\(black)\"]\n[Result \"\(result.rawValue)\"]\n"
            for (key, value) in tags {
                PGN.append("[\(key) \"\(value)\"]\n")
            }
            var numberPrefix = 1
            var lineLength = 0
            for move in moves {
                // TODO annotations
                let movePrefix: String
                if (move.side == .white) {
                    movePrefix = "\(numberPrefix). "
                    numberPrefix += 1
                } else {
                    movePrefix = ""
                }
                let moveString = "\(movePrefix)\(move)"
                if lineLength == 0 {
                    PGN.append(moveString)
                    lineLength = moveString.count
                } else if (lineLength + moveString.count) > 80 {
                    PGN.append("\n\(moveString)")
                    lineLength = moveString.count
                } else {
                    PGN.append(" \(moveString)")
                    lineLength += moveString.count
                }
            }
            PGN.append(" \(result.rawValue)")
            return PGN
        }
        
        // When creating game PGNs we note the device info for elo stats.
        // No personal information is tapped here, the string created is in the format "iPhone10,1"
        // See https://stackoverflow.com/questions/11197509/how-to-get-device-make-and-model-on-ios
        internal static func deviceSite() -> String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
    }
}
