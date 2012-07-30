#import <Foundation/Foundation.h>
#import "iTunes.h"

NSString *nowPlayingInItunes ()
{
	iTunesApplication *iTunes = nil;
	iTunesTrack *currentTrack = nil;
	NSString *trackName = nil; 
	NSString *artistName = nil;
	NSString *returnString = nil;
	
	iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	if (!iTunes)
	{
		//NSLog(@"iTunes handle == nil!");
		return nil;
	}
		
	
	/*
	 now follows a bunch of try/catch stuff and seemingly senseless string copying + double checking.
	 but we must do it this way as the iTunes application could change the track anytime which would
	 lead to invalid/partial data.
	 
	 the joy of concurrency :)
	 */
		
	if (![iTunes isRunning])
	{	
		//NSLog(@"iTunes not running == nil!");
		return nil;
	}
	
	@try
	{
		currentTrack = [[iTunes currentTrack] get];
	}
	@catch(NSException *e)
	{
		//NSLog(@"#2 Exception:%@ Reason: %@ Callstack: %@ userInfo: %@",e, [e reason], [e callStackSymbols],[e userInfo] );
		return nil;
	}

	if ([currentTrack exists] && [iTunes isRunning])
	{
		@try 
		{
			trackName = [currentTrack name];
			if (trackName != nil)
				trackName= [NSString stringWithString: trackName];
			
			artistName = [currentTrack artist];
			if (artistName != nil)
				artistName = [NSString stringWithString: artistName];
		}
		@catch (NSException *e) 
		{
			/*NSLog(@"#3 Exception:%@ Reason: %@ Callstack: %@ userInfo: %@",e, [e reason], [e callStackSymbols],[e userInfo] );
			NSLog(@"name: %@", trackName);
			NSLog(@"artist: %@", artistName);
			NSLog(@"kind: %@", kind);
			NSLog(@"stream: %@", streamTitle);*/
			
			return nil;
		}
		
	}
			
	//now let's build our display string
	if (artistName && trackName)
		returnString = [NSString stringWithFormat: @"%@ - %@", artistName, trackName];
	if (artistName && !trackName)
		returnString = [NSString stringWithFormat: @"%@", artistName];
	if (!artistName && trackName)
		returnString = [NSString stringWithFormat: @"%@", trackName];
	if (!artistName && !trackName) //just to be safe. computers are magic!
		return nil;
	
	return returnString;
}


int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	
	NSString *ns_nowplaying = nowPlayingInItunes();
	
	if (!ns_nowplaying)
	{
		fprintf(stderr, "Could not connect to iTunes ...\n");
		return 1;
	}
	
	const char *str_now_playing = [ns_nowplaying cStringUsingEncoding: NSUTF8StringEncoding];
	
	fprintf(stdout, "\u266C %s\n", str_now_playing);
    
	[pool drain];
    return 0;
}
