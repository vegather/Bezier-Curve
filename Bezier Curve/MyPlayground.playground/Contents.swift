//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

private func nCi(n: Int, i: Int) -> Int {
    return fac(n) / (fac(i) * fac(n-i))
}

private func fac(n: Int) -> Int {
    return n <= 1 ? 1 : n * fac(n-1)
}

let test = nCi(3, i: 2)