//
//  XMPPMessage.m
//  Monal
//
//  Created by Anurodh Pokharel on 7/13/13.
//
//

#import "XMPPMessage.h"

@interface MLXMLNode()
@property (atomic, strong, readwrite) NSString* element;
@end

@implementation XMPPMessage

NSString* const kMessageChatType = @"chat";
NSString* const kMessageGroupChatType = @"groupchat";
NSString* const kMessageErrorType = @"error";
NSString* const kMessageNormalType = @"normal";
NSString* const kMessageHeadlineType = @"headline";

-(id) init
{
    self = [super init];
    self.element = @"message";
    [self setXMLNS:@"jabber:client"];
    self.id = [[NSUUID UUID] UUIDString];       //default value, can be overwritten later on
    return self;
}

-(id) initWithXMPPMessage:(XMPPMessage*) msg
{
    self = [self initWithElement:msg.element withAttributes:msg.attributes andChildren:msg.children andData:msg.data];
    return self;
}

//this oerwrites the setter of XMPPStanza
-(void) setId:(NSString*) idval
{
    [super setId:idval];
    //add origin id to indicate we are using uuids for our stanza ids
    //(modify origin id, if already present)
    if([self check:@"{urn:xmpp:sid:0}origin-id"])
        ((MLXMLNode*)[self findFirst:@"{urn:xmpp:sid:0}origin-id"]).attributes[@"id"] = idval;
    else
        [self addChild:[[MLXMLNode alloc] initWithElement:@"origin-id" andNamespace:@"urn:xmpp:sid:0" withAttributes:@{@"id":idval} andChildren:@[] andData:nil]];
}

-(void) setBody:(NSString*) messageBody
{
    MLXMLNode* body = [self findFirst:@"body"];
    if(body)
        body.data = messageBody;
    else
        [self addChild:[[MLXMLNode alloc] initWithElement:@"body" withAttributes:@{} andChildren:@[] andData:messageBody]];
}

-(void) setOobUrl:(NSString*) link
{
    MLXMLNode* oobElement = [self findFirst:@"{jabber:x:oob}x"];
    MLXMLNode* oobElementUrl = [self findFirst:@"{jabber:x:oob}x/url"];
    if(oobElement && oobElementUrl == nil)
        [oobElement addChild:[[MLXMLNode alloc] initWithElement:@"url" withAttributes:@{} andChildren:@[] andData:link]];
    else if(oobElement && oobElementUrl)
        oobElementUrl.data = link;
    else
        [self addChild:[[MLXMLNode alloc] initWithElement:@"x" andNamespace:@"jabber:x:oob" withAttributes:@{} andChildren:@[
            [[MLXMLNode alloc] initWithElement:@"url" withAttributes:@{} andChildren:@[] andData:link]
        ] andData:nil]];
    [self setBody:link];    //http filetransfers must have a message body equal to the oob link to be recognized as filetransfer
}

-(void) setLMCFor:(NSString*) id
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"replace" andNamespace:@"urn:xmpp:message-correct:0" withAttributes:@{@"id": id} andChildren:@[] andData:nil]];
}

/**
 @see https://xmpp.org/extensions/xep-0184.html
 */
-(void) setReceipt:(NSString*) messageId
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"received" andNamespace:@"urn:xmpp:receipts" withAttributes:@{@"id":messageId} andChildren:@[] andData:nil]];
}

-(void) setChatmarkerReceipt:(NSString*) messageId
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"received" andNamespace:@"urn:xmpp:chat-markers:0" withAttributes:@{@"id":messageId} andChildren:@[] andData:nil]];
}

-(void) setDisplayed:(NSString*) messageId
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"displayed" andNamespace:@"urn:xmpp:chat-markers:0" withAttributes:@{@"id":messageId} andChildren:@[] andData:nil]];
}

-(void) setStoreHint
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"store" andNamespace:@"urn:xmpp:hints"]];
}

-(void) setNoStoreHint
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"no-store" andNamespace:@"urn:xmpp:hints"]];
    [self addChild:[[MLXMLNode alloc] initWithElement:@"no-storage" andNamespace:@"urn:xmpp:hints"]];
}

@end
