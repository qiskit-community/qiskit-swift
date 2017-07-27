//: Playground - noun: a place where people can play

import qiskit
import Cocoa
import PlaygroundSupport
import XCPlayground

var apitoken = "NONE"

DataMove.dataMove(apitoken) {
    GHZ.ghz(apitoken) {
        Multiple.multiple(apitoken) {
            QFT.qft(apitoken) {
                RippleAdd.rippleAdd(apitoken) {
                    Teleport.teleport(apitoken)
                }
            }
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
