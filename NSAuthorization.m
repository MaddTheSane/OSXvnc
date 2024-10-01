//
//  NSAuthorization.m
//  OSXvnc
//
//  Created by Jonathan Gillaspie on Fri Dec 12 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NSAuthorization.h"

#include "unistd.h"

@implementation NSAuthorization

- (instancetype) init {
    const AuthorizationFlags myFlags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;
    OSStatus myStatus;
    AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights myRights = {1, &myItems};

    self = [super init];

    myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, myFlags, &myAuthorizationRef);

    // This will pre-authorize the authentication
    if (myStatus == errAuthorizationSuccess)
        myStatus = AuthorizationCopyRights(myAuthorizationRef, &myRights, NULL, myFlags, NULL);

    if (myStatus != errAuthorizationSuccess) {
        return nil;
    }

    return self;
}

- (BOOL) executeCommand:(NSString *) command withArgs: (NSArray *) argumentArray {
    return [self executeCommand:(NSString *) command withArgs: (NSArray *) argumentArray synchronous:TRUE];
}

- (BOOL) executeCommand:(NSString *) command withArgs: (NSArray *) argumentArray synchronous: (BOOL) sync {
    FILE *communicationStream = NULL;
    int i;
    OSStatus myStatus;
    char outputString[1024];
    time_t startTime = time(NULL);

    char **copyArguments = malloc(sizeof(char *) * (argumentArray.count + 1));

    for (i = 0; i < argumentArray.count; i++) {
        copyArguments[i] = (char *)[argumentArray[i] UTF8String];
    }
    copyArguments[i] = NULL;

    myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef,
                                                  command.UTF8String,
                                                  kAuthorizationFlagDefaults,
                                                  copyArguments,
                                                  (sync ? &communicationStream : NULL)); // FILE HANDLE for I/O

    if (myStatus==errAuthorizationSuccess && sync) {
        while (!myStatus && !feof(communicationStream) && fgets(outputString, 1024, communicationStream) && time(NULL)-startTime<10) {
            if (strlen(outputString) > 1)
                NSLog(@"NSAuthorization: %s",outputString);
        }
        fclose(communicationStream);
    }

    free(copyArguments);

    if (myStatus != errAuthorizationSuccess)
        NSLog(@"Error: Executing %@ with Authorization: %d", command, (int)myStatus);

    return (myStatus == errAuthorizationSuccess);
}


- (void) dealloc {
    AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);
}

@end
