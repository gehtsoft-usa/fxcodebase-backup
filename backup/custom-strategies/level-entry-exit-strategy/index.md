# Level Entry/Exit Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2852  
> Forum: 31 · Topic 2852 · 9 post(s)


---

## Level Entry/Exit Strategy

**Alexander.Gettinger** · Fri Dec 03, 2010 4:42 am

The work of this strategy looks like market order.

For long position:
- When the close of the candle higher than [PriceLevel]. If already have short position close this short position.

For short position:
- When the close of the candle lower than [PriceLevel]. If already have long position, close this long position.

Download:

 [Level_EE_Strategy.lua](files/6511/Level_EE_Strategy.lua)

The Strategy was revised and updated on December 10, 2018.


---

## Re: Level Entry/Exit Strategy

**path118** · Fri Dec 03, 2010 11:13 am

Dear Alexander.Gettinger

Thank you very much!!, I really appreciate your help.
I got a problem with this strategy.
- When I use this strategy I got error message: 216 “Cannot recognize the host command” in the Events dialog, this happen after about 5 minute when the setting was established. I have to remove strategy if not the event log continue show error.
- I don’t see any line indicate that setting was established (unlike price Alert strategy)
- In the parameter I don’t see any thing that Marketscope will close the opposite position (when price cross above this price level, close the short position and buy xx lot ...).

Maybe I do something wrong, but I really don’t know what is wrong??
I am using FXCM trading station version 01.09.082610 for UK micro account.


---

## Re: Level Entry/Exit Strategy

**Alexander.Gettinger** · Mon Dec 06, 2010 1:41 am

Try update trading station, please.


---

## Re: Level Entry/Exit Strategy

**taroblaro** · Thu Jan 27, 2011 11:46 am

How about automatically setting the price level to the previous bar close/open/high/low? (This could be a question for strategy builder as well) Also to be able to set the buy/sell levels .1-100 pips above/below the price level so the trader doesn't get excessive trading around the price level. Thanks.


---

## Re: Level Entry/Exit Strategy

**STEIGO** · Wed Dec 21, 2011 8:18 pm

Please tell me if I understand this simple strategy

It opens a long position as soon as price breaks the previous candle high?

Is this right?

If not - how is the price level (to be broken) set - is it simply set in the parameters section of the strategy paraments (default 2.0)

As always a picture would help

thanks


---

## Re: Level Entry/Exit Strategy

**davidf515** · Thu Mar 08, 2012 3:01 am

I've tried this Strategy and it looks promising. However, there is a problem, at least when I tried it. The Strategy opens a position just fine. But once it does, it shuts off immediately. This renders the included Stop and Limit inoperable, so you have a position with no Stop or Limit. Ideally, this Strategy would open a position and stay running, thereby utilizing the Stop and Limit features. Then, when the Stop is hit, the strategy REMAINS RUNNING and re-enters the order should the original price get hit again. Better yet would be if it DID stop the Strategy when the Limit is hit.

Stop hit = Strategy remains running.
Limit hit = shuts off.

I'm not sure, but I assume that it doesn't open a position if there's already a position open (doesn't ADD to existing positions). If not, that would be essential so that it doesn't open multiple positions in rapid succession (and for us FIFO accounts). Also, would be great if it used tick data (price touch), just like a normal Entry order, instead of candle close data. Would make for more accurate entries.

I'm just trying to find an easy way for someone to create the particular Strategy I'm looking for. See: [viewtopic.php?f=27&t=12495](https://fxcodebase.com/code/viewtopic.php?f=27&t=12495)

If it's just a matter of adding a few lines of code to this existing Strategy, I'd be happy to do it - if I only knew how!

Thanks to anyone who can help me on this.


---

## Re: Level Entry/Exit Strategy

**eschweikert** · Thu Mar 08, 2012 8:21 pm

> I've tried this Strategy and it looks promising. However, there is a problem, at least when I tried it. The Strategy opens a position just fine. But once it does, it shuts off immediately. This renders the included Stop and Limit inoperable, so you have a position with no Stop or Limit. Ideally, this Strategy would open a position and stay running, thereby utilizing the Stop and Limit features. Then, when the Stop is hit, the strategy REMAINS RUNNING and re-enters the order should the original price get hit again. Better yet would be if it DID stop the Strategy when the Limit is hit.
>
> Stop hit = Strategy remains running.
> Limit hit = shuts off.

I couldn't have said it any better.

> I'm not sure, but I assume that it doesn't open a position if there's already a position open (doesn't ADD to existing positions). If not, that would be essential so that it doesn't open multiple positions in rapid succession (and for us FIFO accounts)

No it does not. after I hear a position open, I run back to the computer to click "play".


---

## Re: Level Entry/Exit Strategy

**sjkafeero** · Tue Apr 02, 2013 6:39 am

dear Alexander.Gettinger,

 Am using this strategy. It opens the positions fine. However, when it closes the open position it then opens another simultaneously in the opposite direction. How do I set the parameters to just close the open position. Thanks for your helpful contributions.


---

## Re: Level Entry/Exit Strategy

**Apprentice** · Fri Dec 09, 2016 4:49 am

Strategy was revised and updated.
