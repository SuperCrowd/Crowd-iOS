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

#warning - Live server use - 183 (192 for local)

#if TARGET_IPHONE_SIMULATOR
//Simulator
#define IMG_BASE_URL @"http://192.168.0.4/crowdwcf/ImageUpload/"
#define BASE_URL @"http://192.168.0.4/crowdwcf/Service1.svc/"
#else
// Device
#define IMG_BASE_URL @"http://183.182.91.146/crowdwcf/ImageUpload/"
#define BASE_URL @"http://183.182.91.146/crowdwcf/Service1.svc/"

#endif



#define Web_IS_USER_EXIST BASE_URL@"IsUserExists"
#define Web_IS_USER_REGISTER_OR_UPDATE BASE_URL@"AddEditUserDetails"

#define Web_GET_USER_DETAILS BASE_URL@"GetUserDetails"

#define Web_POST_JOB BASE_URL@"AddEditJob"


//section 
#define Web_JOB_LIST BASE_URL@"SearchJob"
#define Web_CANDIDATE_LIST BASE_URL@"SearchCandidates"




//section 1
#define Web_DASHBOARD BASE_URL@"GetActivityFeeds"

// my jobs + other user jobs
#define Web_JOB_FAVOURITE BASE_URL@"FavoriteJob"
#define Web_JOB_APPLY BASE_URL@"ApplyToJob"
#define Web_MY_JOBS_DELETE BASE_URL@"DeleteJob"
#define Web_MY_JOBS_FILL_REOPEN BASE_URL@"FillReopenJob"

// get own or other user job details
#define Web_JOB_DETAIL BASE_URL@"GetJobDetails"

//message
#define Web_GET_MESSAGES_LIST BASE_URL@"GetMessageList"
#define Web_GET_MESSAGES_RECENT BASE_URL@"GetMessageThread"
#define Web_GET_MESSAGES_PAST BASE_URL@"GetMessageList"

//follow unfollow
#define Web_FOLLOW_UNFOLLOW BASE_URL@"FollowUnfollowUser"


//section 6-7
#define Web_MY_CROWD BASE_URL@"GetMyCrowd"
#define Web_MY_JOBS BASE_URL@"GetUserJobs"
#endif
