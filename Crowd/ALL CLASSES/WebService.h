//
//  WebService.h
//  Demo
//
//  Created by MAC107 on 09/05/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#ifndef Demo_WebService_h
#define Demo_WebService_h

#pragma mark - Web Service Section

#define IMG_BASE_URL @"http://192.168.0.4/crowdwcf/ImageUpload/"
#define BASE_URL @"http://192.168.0.4/crowdwcf/Service1.svc/"
//#define BASE_URL @"http://183.182.91.146/"
#define Web_IS_USER_EXIST BASE_URL@"IsUserExists"
#define Web_IS_USER_REGISTER_OR_UPDATE BASE_URL@"AddEditUserDetails"

#define Web_GET_USER_DETAILS BASE_URL@"GetUserDetails"

#define Web_POST_JOB BASE_URL@"AddEditJob"

#define Web_JOB_LIST BASE_URL@"SearchJob"
#define Web_CANDIDATE_LIST BASE_URL@"SearchCandidates"

#define Web_JOB_DETAIL BASE_URL@"GetJobDetails"



#define Web_JOB_FAVOURITE BASE_URL@"FavoriteJob"
#define Web_JOB_APPLY BASE_URL@"ApplyToJob"

#endif
