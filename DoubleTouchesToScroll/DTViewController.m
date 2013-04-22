//
//  DTViewController.m
//  DoubleTouchesToScroll
//
//  Created by Zhou.Bin on 13-4-22.
//  Copyright (c) 2013年 Zhou.Bin. All rights reserved.
//

#import "DTViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface DTViewController ()
{
    BOOL _shouldResponseToScroll;
    CMMotionManager *_motionManager;
    double _preGravityZ;
    NSTimer *_currentTimer;
}

@end

static float lowFilter = 0.06;

@implementation DTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
    longG.numberOfTouchesRequired = 2;
    longG.minimumPressDuration = 0.1;
    [self.view addGestureRecognizer:longG];
    [longG release];
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    
    if (_motionManager.isDeviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdates];
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _shouldResponseToScroll = NO;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollWithDifference:(double)difference
{
    CGFloat currentOffset = _tableView.contentOffset.y;
    CGFloat newOffset = currentOffset + 1*(int)(difference*10);
    [_tableView setContentOffset:CGPointMake(0.0,newOffset) animated:NO];
}

-(void)tick:(NSTimer *)timer
{
    if (!_shouldResponseToScroll) {
        return;
    }
    double gravityZ = _motionManager.deviceMotion.gravity.z;

    if (fabsf(gravityZ - _preGravityZ) > lowFilter)
    {
        double difference = gravityZ - _preGravityZ;
        [self scrollWithDifference:difference];
    }
    
}


-(void)actionDetected
{
    _shouldResponseToScroll = YES;
    double roll    = _motionManager.deviceMotion.attitude.roll;
    double pitch   = _motionManager.deviceMotion.attitude.pitch;
    double yaw     = _motionManager.deviceMotion.attitude.yaw;
    NSLog(@"\nroll:%f,pitch:%f,yaw:%f\n\n",roll,pitch,yaw);
    
    double gravityX = _motionManager.deviceMotion.gravity.x;
    double gravityY = _motionManager.deviceMotion.gravity.y;
    double gravityZ = _motionManager.deviceMotion.gravity.z;
    _preGravityZ = gravityZ;
    NSLog(@"\ngravityX:%f,gravityY:%f,gravityZ:%f\n",gravityX,gravityY,gravityZ);
}

-(void)actionEnded
{
    _shouldResponseToScroll = NO;
}

#pragma mark - UILongPressGrsture Handler
-(void)longPressGestureHandler:(UILongPressGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"gesture state %d",gestureRecognizer.state);
    
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _currentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
            [self actionDetected];
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            [self actionEnded];
            [_currentTimer invalidate];
            break;
        default:
            break;
    }
}

#pragma mark - TableView Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normalCell = @"normal";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalCell];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    
    return cell;
}


- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
@end
