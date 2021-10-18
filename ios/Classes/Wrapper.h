//
//  Wrapper.h
//  KristaCrypt
//
//  Created by Кристофер Кристовский on 27.08.2020.
//  Copyright © 2020 Кристофер Кристовский. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "stdlib.h"
#import "stdio.h"

#ifdef __cplusplus
extern "C" {
#endif
int initCSP();
NSString* addCert(NSString* pathtoCertFile, NSString* password);
bool removeCert();
void sign();

#ifdef __cplusplus
}
#endif
