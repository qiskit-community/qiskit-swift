//
//  Complex.swift
//  qiskit
//
//  Created by Manoel Marques on 7/19/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

struct Complex: Equatable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {

    public var real: Double {
        get { return _real }
        set { _real = newValue }
    }
    public var imag: Double {
        get { return _imag }
        set { _imag = newValue }
    }

    private var _real: Double = 0
    private var _imag: Double = 0

    public init() {
        self.init(0, 0)
    }

    public init(_ real: Double, _ imag: Double) {
        self._real = real
        self._imag = imag
    }

    public init(real: Double) {
        self.init(real, 0)
    }

    public init(integerLiteral value: Int) {
        self.init(real: Double(value))
    }

    public init(floatLiteral value: Double) {
        self.init(real: value)
    }

    public init(imag: Double) {
        self.init(0, imag)
    }

    public var radiusSquare: Double { return self.real * self.real + self.imag * self.imag }
    public var radius: Double { return sqrt(self.radiusSquare) }
    public var arg: Double { return atan2(self.imag, self.real) }

    public var hashValue: Int {
        return self.real.hashValue &+ self.imag.hashValue
    }

    public var description: String {
        if self.real != 0 {
            if self.imag > 0 {
                return "\(self.real)+\(self.imag)𝒊"
            } else if self.imag < 0 {
                return "\(self.real)-\(-self.imag)𝒊"
            } else {
                return "\(self.real)"
            }
        } else {
            if self.imag == 0 {
                return "0"
            } else {
                return "\(self.imag)𝒊"
            }
        }
    }

    public func abs() -> Double {
        return self.radiusSquare
    }

    // e ** x+iy = e**x * (cos(y) + i sin(y))
    public func exp() -> Complex {
        let first: Double = pow(M_E,self.real)
        let second = Complex(cos(self.imag), sin(self.imag))
        return second.multiply(first)
    }

    public func conjugate() -> Complex {
        return Complex(self.real, -self.imag)
    }


    public func add(_ n: Complex) -> Complex {
        return Complex(self.real + n.self.real, self.imag + n.imag)
    }


    public func subtract(_ n: Complex) -> Complex {
        return Complex(self.real - n.self.real, self.imag - n.imag)
    }


    public func multiply(_ n: Double) -> Complex {
        return Complex(self.real * n, self.imag * n)
    }


    public func multiply(_ n: Complex) -> Complex {
        return Complex(self.real * n.real - self.imag * n.imag, self.real * n.imag + self.imag * n.real)
    }


    public func divide(_ n: Complex) -> Complex {
        return self.multiply((n.conjugate().divide(n.radiusSquare)))
    }


    public func divide(_ n: Double) -> Complex {
        return Complex(self.real / n, self.imag / n)
    }


    public func power(_ n: Double) -> Complex {
        return pow(radiusSquare, n / 2) *  Complex(cos(n * arg), sin(n * arg))
    }

    public func power(_ n: Int) -> Complex {
        switch n {
        case 0: return 1
        case 1: return self
        case -1: return Complex(real: 1).divide(self)
        case 2: return self.multiply(self)
        case -2: return Complex(real: 1).divide(self.multiply(self))
        default: return power(Double(n))
        }
    }

    public mutating func conjugateInPlace() {
        self.imag = -self.imag
    }

    public mutating func addInPlace(_ n: Complex) {
        self.real += n.real
        self.imag += n.imag
    }

    public mutating func subtractInPlace(_ n: Complex) {
        self.real -= n.real
        self.imag -= n.imag
    }

    public mutating func multiplyInPlace(_ n: Double) {
        self.real *= n
        self.imag *= n
    }

    public mutating func multiplyInPlace(_ n: Complex) {
        self = self.multiply(n)
    }

    public mutating func divideInPlace(_ n: Complex) {
        self = self.divide(n)
    }

    public mutating func divideInPlace(_ n: Double) {
        self.real /= n
        self.imag /= n
    }
}

func ==(left: Complex, right: Complex) -> Bool {
    return left.real == right.real && left.imag == right.imag
}

precedencegroup PowerPrecedence {
    higherThan: MultiplicationPrecedence
    associativity: left
    assignment: false
}

infix operator ^ : PowerPrecedence
infix operator * : MultiplicationPrecedence
infix operator / : MultiplicationPrecedence
infix operator + : AdditionPrecedence
infix operator - : AdditionPrecedence

infix operator += : AssignmentPrecedence
infix operator -= : AssignmentPrecedence
infix operator *= : AssignmentPrecedence
infix operator /= : AssignmentPrecedence


func + (left: Complex, right: Complex) -> Complex {
    return left.add(right)
}
func + (left: Double,  right: Complex) -> Complex {
    return Complex(real: left).add(right)
}
func + (left: Complex, right: Double ) -> Complex {
    return left.add(Complex(real: right))
}

func - (left: Complex, right: Complex) -> Complex {
    return left.subtract(right)
}
func - (left: Double,  right: Complex) -> Complex {
    return Complex(real: left).subtract(right)
}
func - (left: Complex, right: Double ) -> Complex {
    return left.subtract(Complex(real: right))
}

func * (left: Complex, right: Complex) -> Complex {
    return left.multiply(right)
}
func * (left: Double,  right: Complex) -> Complex {
    return right.multiply(left)
}
func * (left: Complex, right: Double ) -> Complex {
    return left.multiply(right)
}

func / (left: Complex, right: Complex) -> Complex {
    return left.divide(right)
}
func / (left: Double,  right: Complex) -> Complex {
    return Complex(real: left).divide(right)
}
func / (left: Complex, right: Double ) -> Complex {
    return left.divide(right)
}

func ^ (left: Complex, right: Double) -> Complex {
    return left.power(right)
}
func ^ (left: Complex, right: Int) -> Complex {
    return left.power(right)
}

func += (left: inout Complex, right: Complex) {
    left.addInPlace(right)
}
func += (left: inout Complex, right: Double) {
    left.addInPlace(Complex(real: right))
}
func -= (left: inout Complex, right: Complex) {
    left.subtractInPlace(right)
}
func -= (left: inout Complex, right: Double) {
    left.subtractInPlace(Complex(real: right)) }
func *= (left: inout Complex, right: Complex) {
    left.multiplyInPlace(right)
}
func *= (left: inout Complex, right: Double) {
    left.multiplyInPlace(right)
}
func /= (left: inout Complex, right: Complex) {
    left.divideInPlace(right)
}
func /= (left: inout Complex, right: Double) {
    left.divideInPlace(right)
}
