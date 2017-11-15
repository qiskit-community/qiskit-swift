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

#ifndef CRandom_h
#define CRandom_h

extern const int N;

struct CRandomState {
    unsigned long *mt; /* the array for the state vector  */
    int mti;           /* mti==N+1 means mt[N] is not initialized */
};

extern void init_by_array(struct CRandomState *pState,unsigned long init_key[], int key_length);
extern double genrand_res53(struct CRandomState *pState);

#endif
