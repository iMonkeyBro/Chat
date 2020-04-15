//
//  ViewController.m
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "ViewController.h"
#import "CQChatViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)presentChatViewController:(id)sender {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:CQChatViewController.new];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}


@end
