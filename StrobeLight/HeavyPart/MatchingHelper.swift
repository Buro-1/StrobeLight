//
//  MatchingHelper.swift
//  StrobeLight
//
//  Created by Jesse Born on 15.05.23.
//

// https://www.kodeco.com/26236685-shazamkit-tutorial-for-ios-getting-started

import AVFAudio
import Foundation
import ShazamKit

class MatchingHelper: NSObject {
    var session: SHSession?

    private var matchHandler: ((SHMatchedMediaItem?, Error?) -> Void)?

    init(matchHandler handler: ((SHMatchedMediaItem?, Error?) -> Void)?) {
        matchHandler = handler
    }
    func setDelegate() {
        session?.delegate = self
    }
    
}
extension MatchingHelper: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else {
            return
          }

          if let handler = self.matchHandler {
            handler(match.mediaItems.first, nil)
              print("matched audio")
            // stop capturing audio
          }
        }
    }
    func session(
      _ session: SHSession,
      didNotFindMatchFor signature: SHSignature,
      error: Error?
    ) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else {
          return
        }

        if let handler = self.matchHandler {
          handler(nil, error)
            print("Didn't matched audio")
        }
      }
    }
}
