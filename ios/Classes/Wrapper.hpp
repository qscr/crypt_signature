//
//  Wrapper.h
//  KristaCrypt
//
//  Created by Кристофер Кристовский on 27.08.2020.
//  Copyright © 2020 Кристофер Кристовский. All rights reserved.
//

#import "stdlib.h"
#import "stdio.h"

#ifdef __cplusplus
extern "C" {
#endif
bool initCSP();
bool addCert();
bool removeCert();
void sign();

#ifdef __cplusplus
}
#endif
