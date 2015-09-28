//
//  ViewController.m
//  ChatClient
//
//  Created by Zack Zhu on 28/09/2015.
//  Copyright © 2015 zhuyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "ChatClient-Swift.h"

@interface ViewController () <NSURLSessionDelegate>
@property (strong, nonatomic) SocketIOClient * client;
@property (weak, nonatomic) IBOutlet UISwitch * switchButton;

@end

@implementation ViewController


- (IBAction)handleConnectButton:(id)sender
{
    [self connect];
}

- (IBAction)handleDisconnectButton:(id)sender
{
    [_client disconnect];
}

- (void)connect {
    NSDictionary * opts = nil;
    
    if (_switchButton.on) {
        opts = @{@"sessionDelegate":self};
    }
        
    _client = [[SocketIOClient alloc] initWithSocketURL:@"https://127.0.0.1:3000" opts:opts];
    
    [_client on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connected");
    }];
    
    [_client on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"disconnected");
    }];
    
    [_client on:@"reconnectAttempt" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"reconnect");
    }];
    
    [_client connect];
}



- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    // need this for self signed SSL cert
    NSLog(@"receive challenge");
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"invalid:%@", error);
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"finish");
}

@end
