//
//  PullToRefreshViewController.m
//  PullToRefresh
//
//  Created by Gabriel Vincent on 28/04/12.
//  Copyright (c) 2012 _A_Z. All rights reserved.
//

#import "PullToRefreshViewController.h"

@interface PullToRefreshViewController ()

@end

@implementation PullToRefreshViewController

- (void) setUpdateDate {
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MM/dd/yyyy"];
	NSDate *now = [[NSDate alloc] init];
	
	NSString *dateString = [dateFormat stringFromDate:now];
	NSString *objectString = [[NSString alloc] initWithFormat:@"Last updated on %@", dateString];
	
	lastUpdateLabel.text = objectString;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"LastUpdateDate.txt"];
	[objectString writeToFile:documentsFolderPath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
	
}

- (void) stopSpinner {
	[spinner removeFromSuperview];
	updateImageView.hidden = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	[UIView commitAnimations];
	isUpdating = NO;
}

- (void) startSpinner {
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.color = [UIColor lightGrayColor];
	spinner.center = updateImageView.center;
	updateImageView.hidden = YES;
	[spinner startAnimating];
	[self.view addSubview:spinner];
	updateLabel.text = @"Updating...";
	isUpdating = YES;
	
}

- (void) updateMethod {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update!" message:@"Perform whatever action you want!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
	
	[self performSelectorOnMainThread:@selector(startSpinner) withObject:nil waitUntilDone:NO];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self stopSpinner];
	[self setUpdateDate];
}

- (void) playAudioWithAudioFileName:(NSString *) fileName {
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	
	resourcePath = [resourcePath stringByAppendingString:fileName];
	NSError* err;
	
	//Initialize our player pointing to the path to our resource
	audio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
	[audio prepareToPlay];
	
	if( err ){
		NSLog(@"Failed with reason: %@", [err localizedDescription]);
	}
	else{
		audio.volume = 0.3;
		[audio play];
	}
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -40, 320, 20)];
	updateLabel.textAlignment = UITextAlignmentCenter;
	updateLabel.text = @"Pull down to refresh...";
	updateLabel.textColor = [UIColor darkGrayColor];
	updateLabel.backgroundColor = [UIColor clearColor];
	
	lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 320, 20)];
	lastUpdateLabel.textAlignment = UITextAlignmentCenter;
	lastUpdateLabel.textColor = [UIColor darkGrayColor];
	lastUpdateLabel.backgroundColor = [UIColor clearColor];
	lastUpdateLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"LastUpdateDate.txt"];
	lastUpdateLabel.text = [NSString stringWithContentsOfFile:documentsFolderPath encoding:NSStringEncodingConversionAllowLossy error:nil];
	
	updateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"updateArrow.png"]];
	
	updateImageView.frame = CGRectMake(40, -50, 27, 40);
	
	[self.tableView addSubview:updateLabel];
	[self.tableView addSubview:lastUpdateLabel];
	[self.tableView addSubview:updateImageView];
	
	data = [NSArray arrayWithObjects:@"Bulbasaur", @"Ivysaur", @"Venusaur", @"Charmander", @"Charmeleon", @"Charizard", @"Squirtle", @"Wartortle", @"Blastoise", nil];
	
	shouldUpdate = NO;
	shouldPlaySound = NO;
	isUpdating = NO;
	
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	resourcePath = [resourcePath stringByAppendingString:@"/releaseSound.mp3"];
	NSError* err;
	
	//Initialize our player pointing to the path to our resource
	audio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
	audio.delegate = self;
	[audio prepareToPlay];
	[audio play];
	[audio stop];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)targetContentOffset {
	if (shouldUpdate) {
		queue = [NSOperationQueue new];
		NSInvocationOperation *updateOperation = [[NSInvocationOperation alloc] initWithTarget:self  selector:@selector(updateMethod)  object:nil];
		[queue addOperation:updateOperation];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
		[UIView commitAnimations];
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)sender {
	
    offset = self.tableView.contentOffset.y;
	offset *= -1;
	
	
	if (offset < 60) {
		if (shouldPlaySound) {
			queue = [NSOperationQueue new];
			NSInvocationOperation *playOperation = [[NSInvocationOperation alloc] initWithTarget:self  selector:@selector(playAudioWithAudioFileName:)  object:@"/releaseSound.mp3"];
			[queue addOperation:playOperation];
			shouldPlaySound = NO;
		}
	}
	else if (offset >= 60) {
		if (!shouldUpdate && !isUpdating) {
			queue = [NSOperationQueue new];
			NSInvocationOperation *playOperation = [[NSInvocationOperation alloc] initWithTarget:self  selector:@selector(playAudioWithAudioFileName:)  object:@"/pullSound.mp3"];
			[queue addOperation:playOperation];
		}
	}
	
	if (offset > 0 && offset < 60) {
		
		if(!isUpdating) updateLabel.text = @"Pull down to refresh...";
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.2];
		updateImageView.transform = CGAffineTransformMakeRotation(0);
		[UIView commitAnimations];
		shouldUpdate = NO;
	}
	
	if (offset >= 60) {
		
		if(!isUpdating) updateLabel.text = @"Release to refresh...";
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.2];
		updateImageView.transform = CGAffineTransformMakeRotation(3.14159265);
		[UIView commitAnimations];
		shouldUpdate = YES;
		shouldPlaySound = YES;
	}
	
	if (isUpdating) {
		shouldUpdate = NO;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [data objectAtIndex:indexPath.row];
	
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
