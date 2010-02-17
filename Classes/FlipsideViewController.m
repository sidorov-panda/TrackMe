//
//  FlipsideViewController.m
//  TrackMe
//
//  Created by Steve Baker on 2/15/10.
//  Copyright Beepscore LLC 2010. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      
}


- (IBAction)done {
	[self.delegate flipsideViewControllerDidFinish:self];	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait == interfaceOrientation)
            || (UIInterfaceOrientationLandscapeLeft == interfaceOrientation)
            || (UIInterfaceOrientationLandscapeRight == interfaceOrientation));
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
