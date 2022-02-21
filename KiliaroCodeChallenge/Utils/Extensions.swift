//
//  Extensions.swift
//  KiliaroCodeChallenge
//
//  Created by qazal on 2/20/22.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    //generate UICollectionViewCell reuse identifire using class name
    static var cellId: String {
        String(describing: self)
    }
}

extension URL {
    //generate custom file name depend on api url format
    func fileName() -> String? {
        guard let imgCustomName = URLComponents(string: self.absoluteString)?.path.components(separatedBy: "/")else{
            return nil
        }
        var fileName = imgCustomName[2] + imgCustomName[5]
        fileName = fileName + ".thumbnail"
        return fileName
    }
}
