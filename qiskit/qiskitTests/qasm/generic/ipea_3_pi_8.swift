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

// Name of Experiment: ipea_3*pi/8 v2
struct Ipea3pi8 {
static let QASM = """
OPENQASM 2.0;
include "qelib1.inc";

qreg q[2];
creg c[4];
gate cu1fixed (a) c,t {
u1 (-a) t;
cx c,t;
u1 (a) t;
cx c,t;
}
gate cu c,t {
cu1fixed (3*pi/8) c,t;
}

h q[0];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
h q[0];
measure q[0] -> c[0];
reset q[0];
h q[0];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
cu q[0],q[1];
if(c==1) u1(-pi/2) q[0];
h q[0];
measure q[0] -> c[1];
reset q[0];
h q[0];
cu q[0],q[1];
cu q[0],q[1];
if(c==1) u1(-pi/4) q[0];
if(c==2) u1(-pi/2) q[0];
if(c==3) u1(-3*pi/4) q[0];
h q[0];
measure q[0] -> c[2];
reset q[0];
h q[0];
cu q[0],q[1];
if(c==1) u1(-pi/8) q[0];
if(c==2) u1(-2*pi/8) q[0];
if(c==3) u1(-3*pi/8) q[0];
if(c==4) u1(-4*pi/8) q[0];
if(c==5) u1(-5*pi/8) q[0];
if(c==6) u1(-6*pi/8) q[0];
if(c==7) u1(-7*pi/8) q[0];
h q[0];
measure q[0] -> c[3];
"""
}
