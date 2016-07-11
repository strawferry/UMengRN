//
//  EMSDKBridge.m
//  UMengRN
//
//  Created by 苍小米 on 16/7/4.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "EMSDKBridge.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
//EMSDK
#import "EMSDK.h"

@interface EMSDKBridge ()
@property (nonatomic, strong)NSArray *mesArr;
@end


@implementation EMSDKBridge
@synthesize bridge = _bridge;



RCT_EXPORT_MODULE();

#pragma mark ---注册registerWithUsername:&password:
RCT_EXPORT_METHOD(registerWithUsername:(NSString *)name password:(NSString *)password callback:(RCTResponseSenderBlock)callback)
{
  EMError *error = [[EMClient sharedClient] registerWithUsername:name password:password];
  NSArray *events;
  if (error==nil) {
    NSLog(@"注册成功");
    events = [NSArray arrayWithObjects:@"1", nil];
  }else{
    NSLog(error.errorDescription);
    events = [NSArray arrayWithObjects:error.errorDescription, nil];
  }
  callback(@[[NSNull null], events]);
}

#pragma mark ---登录loginWithUsername:&password:&autoLogin:
RCT_EXPORT_METHOD(loginWithUsername:(NSString *)name password:(NSString *)password autoLogin:(BOOL)autoLogin callback:(RCTResponseSenderBlock)callback)
{
  NSArray *events;
  BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
  if (!isAutoLogin) {
  EMError *error = [[EMClient sharedClient] loginWithUsername:name password:password];
  if (!error) {
    NSLog(@"登录成功");
    events = [NSArray arrayWithObjects:@"1", nil];
    //设置自动登录
     [[EMClient sharedClient].options setIsAutoLogin:autoLogin];
    //消息回调:EMChatManagerChatDelegate
    [self addDelegate];
  }else{
    NSLog(error.errorDescription);
    events = [NSArray arrayWithObjects:error.errorDescription, nil];
  }
  }else{
    //消息回调:EMChatManagerChatDelegate
    [self addDelegate];
  }
  callback(@[[NSNull null], events]);
}

- (void)addDelegate{
  //消息回调:EMChatManagerChatDelegate
  //注册消息回调
  [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

#pragma mark ---退出登录logout
RCT_EXPORT_METHOD(logout:(RCTResponseSenderBlock)callback)
{
  NSArray *events;
  EMError *error = [[EMClient sharedClient] logout:YES];
  if (!error) {
    events = [NSArray arrayWithObjects:@"1", nil];
    NSLog(@"退出成功");
    //移除消息回调
    [[EMClient sharedClient].chatManager removeDelegate:self];
  }else{
    NSLog(error.errorDescription);
    events = [NSArray arrayWithObjects:error.errorDescription, nil];
  }
  callback(@[[NSNull null], events]);
}

#pragma mark ---发文字消息sendWithMessage:
RCT_EXPORT_METHOD(sendWithMessage:(NSString *)message to:(NSString *)toWho callback:(RCTResponseSenderBlock)callback)
{
  EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:message];
  NSString *from = [[EMClient sharedClient] currentUsername];
  //生成Message
  EMMessage *mes = [[EMMessage alloc] initWithConversationID:toWho from:from to:toWho body:body ext:nil];
  mes.chatType = EMChatTypeChat;// 设置为单聊消息
  //message.chatType = EMChatTypeGroupChat;// 设置为群聊消息
  //message.chatType = EMChatTypeChatRoom;// 设置为聊天室消息
 [[EMClient sharedClient].chatManager asyncSendMessage:mes progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
   NSArray *events;
   if(!aError){
     NSLog(@"-=-sucess-=-");
     events = [NSArray arrayWithObjects:@"1", nil];
   }
   else{
     NSLog(@"-=-=-fail-=%@-=-",aError.errorDescription);
     events = [NSArray arrayWithObjects:aError.errorDescription, nil];
   }
   callback(@[[NSNull null], events]);
 }];
}

#pragma mark ---删除单个会话deleteConversationWithId:
RCT_EXPORT_METHOD(deleteConversationWithId:(NSString *)conversationId )
{
  [[EMClient sharedClient].chatManager deleteConversation:conversationId deleteMessages:YES];
}

#pragma mark ---批量删除会话deleteConversationWithArray
RCT_EXPORT_METHOD(deleteConversationWithArray:(NSArray *)conversations )
{
  [[EMClient sharedClient].chatManager deleteConversations:conversations deleteMessages:YES];
}

#pragma mark ---获取或创建对话getConversationWithId:callback:
RCT_EXPORT_METHOD(getConversationWithId:(NSString *)aConversationId callback:(RCTResponseSenderBlock)callback)
{
  EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aConversationId type:EMConversationTypeChat createIfNotExist:YES];
  NSArray *arr = [conversation loadMoreMessagesFrom:0 to:1000000000 maxCount:100];
  NSArray *arr2 = [conversation loadMoreMessagesFromId:nil limit:10 direction:EMMessageSearchDirectionUp];
//  NSLog(@"",conversation.conversationId ,conversation.latestMessage);
}

#pragma mark ---getAllConversations 获取内存中所有会话
RCT_EXPORT_METHOD(getAllConversations:(RCTResponseSenderBlock)callback)
{
  NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
  NSArray *events = [NSArray arrayWithObjects:@"1",@"2",@"3", nil];
  callback(@[[NSNull null], events]);
}

#pragma mark ---收到消息的回调，带有附件类型的消息可以用 SDK 提供的下载附件方法下载（后面会讲到）
- (void)didReceiveMessages:(NSArray *)aMessages
{
  
  for (EMMessage *message in aMessages) {
    EMMessageBody *msgBody = message.body;
    switch (msgBody.type) {
      case EMMessageBodyTypeText:
      {
        // 收到的文字消息
        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
        NSString *txt = textBody.text;
        NSLog(@"收到的文字是 txt -- %@",txt);
        [self.bridge.eventDispatcher sendAppEventWithName:@"EventReminder"
                                                     body:@{@"name": txt}];
      }
        break;
      case EMMessageBodyTypeImage:
      {
        // 得到一个图片消息body
        EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
        NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
        NSLog(@"大图local路径 -- %@"    ,body.localPath); // // 需要使用sdk提供的下载方法后才会存在
        NSLog(@"大图的secret -- %@"    ,body.secretKey);
        NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
        NSLog(@"大图的下载状态 -- %u",body.downloadStatus);
        
        
        // 缩略图sdk会自动下载
        NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
        NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
        NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
        NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
        NSLog(@"小图的下载状态 -- %u",body.thumbnailDownloadStatus);
      }
        break;
      case EMMessageBodyTypeLocation:
      {
        EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
        NSLog(@"纬度-- %f",body.latitude);
        NSLog(@"经度-- %f",body.longitude);
        NSLog(@"地址-- %@",body.address);
      }
        break;
      case EMMessageBodyTypeVoice:
      {
        // 音频sdk会自动下载
        EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
        NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
        NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
        NSLog(@"音频的secret -- %@"        ,body.secretKey);
        NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
        NSLog(@"音频文件的下载状态 -- %u"   ,body.downloadStatus);
        NSLog(@"音频的时间长度 -- %d"      ,body.duration);
      }
        break;
      case EMMessageBodyTypeVideo:
      {
        EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
        
        NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
        NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
        NSLog(@"视频的secret -- %@"        ,body.secretKey);
        NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
        NSLog(@"视频文件的下载状态 -- %u"   ,body.downloadStatus);
        NSLog(@"视频的时间长度 -- %d"      ,body.duration);
        NSLog(@"视频的W -- %f ,视频的H -- %f", body.thumbnailSize.width, body.thumbnailSize.height);
        
        // 缩略图sdk会自动下载
        NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
        NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailLocalPath);
        NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
        NSLog(@"缩略图的下载状态 -- %u"      ,body.thumbnailDownloadStatus);
      }
        break;
      case EMMessageBodyTypeFile:
      {
        EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
        NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
        NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
        NSLog(@"文件的secret -- %@"        ,body.secretKey);
        NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
        NSLog(@"文件文件的下载状态 -- %u"   ,body.downloadStatus);
      }
        break;
        
      default:
        break;
    }
  }
}


@end
