// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

// Implementation of Deutsch algorithm with two qubits for f(x)=x
struct Deutsch {
static let QASM = """
OPENQASM 2.0;
include "qelib1.inc";

qreg q[5];
creg c[5];

x q[4];
h q[3];
h q[4];
cx q[3],q[4];
h q[3];
measure q[3] -> c[3];
"""
}
