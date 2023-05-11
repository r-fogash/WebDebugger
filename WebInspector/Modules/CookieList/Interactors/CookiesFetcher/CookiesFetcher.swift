//
//  CookiesFetcher.swift
//  WebInspector
//
//  Created by Robert on 09.05.2023.
//

import Foundation

protocol CookiesFetcher {
    func execute(completion: @escaping ([Cookie])->Void)
}
