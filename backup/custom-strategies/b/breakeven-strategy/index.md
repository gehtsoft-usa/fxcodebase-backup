# Breakeven Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=13498  
> Forum: 31 · Topic 13498 · 68 post(s)

---

## Breakeven Strategy

**Apprentice** · Thu Feb 16, 2012 2:21 pm

[Breakeven Strategy.lua](files/26164/Breakeven%20Strategy.lua)

 [Per-instrument Breakeven Strategy.lua](files/26164/Per-instrument%20Breakeven%20Strategy.lua)

This strategy set stop to breakeven when the position reaches a set amount of pips in profit.

---

## Re: Breakeven Strategy

**oritzbaba** · Fri Feb 17, 2012 5:46 pm

Dear Apprentice,

Apart from setting stop breakeven, does it lock in profit by resuming its trailing stop?

---

## Re: Breakeven Strategy

**Apprentice** · Sat Feb 18, 2012 4:23 am

Not for now.

---

## Re: Breakeven Strategy

**SJB944** · Sat Feb 18, 2012 8:34 am

Seem to get an error when I use this strategy on more than one position on the same pair -- despite ensure that the correct ticket no. is picked for each Strategy.

I'll try again and copy Error report, if that helps.

---

## Re: Breakeven Strategy

**SJB944** · Mon Feb 20, 2012 10:10 pm

Can any one else get this to work?

I enter two positions with 45pip stop, then open Breakeven Strategy, and set profit to 10 pips, for each position (order), when 10 pips profit is reach I get the following error pertaining to each position:

"Failed create/change stop Cannot place more than one order of this type for each trade."

---

## Re: Breakeven Strategy

**PipGrabber** · Tue Feb 21, 2012 9:55 am

Hi Apprentice,

Thanks for making this new breakeven strategy, as the previous version of this strategy did not worked. This one works perfectly as expected.

Would it be possible if it can automatically update the ticket number of a newly open trade? Because along the way, the open trade is either closed by other strategies or hits limit/stops. It's tedious closing and reopening this breakeven strategy every time a new trade is opened.

---

## Re: Breakeven Strategy

**Apprentice** · Wed Feb 22, 2012 4:41 am

In theory, yes.
I hope I will find time soon.

---

## Re: Breakeven Strategy

**eyalbrin** · Thu Feb 23, 2012 4:31 am

Dear Apprentice
I try to set the breakeven strategy and i get this message:Failed create/change stop Cannot place more than one order of this type for each trade."
i run the strategy on one chart.what is the reason i get this message.
Best Regards
eyal

---

## Re: Breakeven Strategy

**SJB944** · Thu Feb 23, 2012 4:44 am

Still can't get it to work. Following error:

"Failed create/change stop Cannot place more than one order of this type for each trade."

Seems to not work if there is more than one position in any pair -- this is despite making sure different orders are picked in Breakeven Strategy.

---

## Re: Breakeven Strategy

**SJB944** · Thu Feb 23, 2012 11:20 pm

Still can't get it to work even if only have one position open on a chart at a time. Same error.

---

## Re: Breakeven Strategy

**SJB944** · Fri Feb 24, 2012 1:44 am

OK, I can get it to work only if the position doesn't already have a stop loss!

Is it possible to update so that an initial stop loss is moved to Break Even after a set profit target is reached.

Cheers

---

## Re: Breakeven Strategy

**PipGrabber** · Fri Feb 24, 2012 1:55 am

> **SJB944 wrote:**
> Still can't get it to work even if only have one position open on a chart at a time. Same error.

Hi SJB944,

Maybe you should stop the strategy and open it again with a new opened trade by default. I think your just updating the breakeven strategy by the drop down list of the ticket number and press apply. As per my observation. It does not work in that manner (don't know why, the strategy detects the trade ticket, but doesn't seem to be loaded during initialization). That's why I have to close and open again the strategy manually each time.

And occasionally you'll get those errors you've mentioned. Just have to open and close again...no choice.

---

## Re: Breakeven Strategy

**SJB944** · Sun Feb 26, 2012 5:21 pm

Nope, was opening Break Even Strategy new for each trade.

---

## Re: Breakeven Strategy

**Alokasi** · Fri Mar 02, 2012 2:37 am

I've hacked up this code for my own use. I managed to get it to detect the existing stops (I think). It seems to detect a Net Stop and move it anyway. I also have it detect the position of the stop so that you can move it manually.

I added another feature too - a gap from the price action, essentially I've made this work as a stepping trailing stop.

If you want it to move to break even and stay there set the "min profit" to 0.0 and the "lead gap" to whatever (i.e. 20 pips). When the price at the close of the time frame bar exceeds the gap the stop will move to the open price. If min profit is set to a number (i.e. 1.0) then the stop will move when the bar closes at gap+lead and will move to open + profit pips.

For example:
Timeframe: m1
Min profit: 1.0
Lead gap: 20.0

This will move the stop to open price +1 pip profit when a 1 minute bar closes at open price +21 pips. If another 1 minute bar closes at stop price + 21 pips, the stop will move up to open price +2 pips. There will always be greater than 20 pips gap every time the stop moves.

Timeframe: m5
Min profit: 10.0
Lead gap: 5.0

In this case the first stop move will occur when a 5 minute bar closes at open price + 15 pips and it will be set at open price + 10 pips with a 5 pip cushion. When another 5 minute bar closes at Stop price + 15 pips, the stop will move to open price + 20 pips with a minimum of 5 pips cushion. Thus this setup protects profits in 10 pip increments.

---

## Re: Breakeven Strategy

**subliminal** · Thu Mar 08, 2012 7:27 pm

Thank you for an amazing indi! and thank you for the improvements Alokasi they are great!

I wanted to ask if its possible to add a fractal option and scaling option?

My idea is that when price reaches a predefined level two things will happen.
1) The indi will automically close a predefined portion of the lots
2)The indi will move the stop to breakeven or lower according to lead gap

Then from there the fractal option takes over and the stop is moved according to fractals to get as much pips as possible. When price finally reaches the stop it will close the rest of lots.

Example

I go long 1.3100 risking 10 lots. My predefined 'Take Profit' is 15 pips and I want half the lots (5) to be closed at that level. I also want the lead gap to be 5 pips.

Price goes to 1.3115 and automatically 5 lots are closed and my stop is moved to 1.3110 (lead gap for a bit of breathing space).

Then from there the stop is moved according to fractals and lets say i'm stopped at 100 pips then the remaining 5 lots are closed.

---

## Re: Breakeven Strategy

**TraderKen** · Mon Mar 12, 2012 1:47 am

Hi Apprentice and other forum members,

This strategy only works for one position of one pair at anytime. If you open multiple positions, all will be closed when any position meets its criteria. This is extremely dangerous for your trading account.

Please help fix this issue. Thanks.

---

## Re: Breakeven Strategy

**PipGrabber** · Wed Aug 08, 2012 9:02 am

Hope somebody can update this strategy that it can automatically detect new open trades. So no need to manually choose a new ticket every time a the open position is closed and a new open ticket is issued.

---

## Re: Breakeven Strategy

**PipGrabber** · Thu Jan 17, 2013 8:49 am

Hi Apprentice,

Still waiting for the update on this strategy to automatically detect new opened positions by other strategies, rather than manually choosing the ticket number each time a new position is opened. (Very tedious if in 1min time frame). Looking forward to it soon.. Thanks!

---

## Re: Breakeven Strategy

**PipGrabber** · Thu Aug 08, 2013 5:51 am

> **Apprentice wrote:**
> In theory, yes.
> I hope I will find time soon.

Still looking forward when you'll have time to automatically update the trade ticket. So that this strategy would continuously run and function on every new trade is being opened.

---

## Re: Breakeven Strategy

**Silverthorn** · Thu Feb 06, 2014 11:03 am

Does this work on trades that are opened by other strategies?

---

## Re: Breakeven Strategy

**Apprentice** · Fri Feb 07, 2014 3:08 am

It should work on all open positions.

---

## Re: Breakeven Strategy

**PipGrabber** · Fri Feb 07, 2014 3:15 am

> **Apprentice wrote:**
> It should work on all open positions.

does it? Silverthorn did say if opened by other strategies.

maybe manually, yes.

that brings back to my request. that this strategy automatically detect opened positions.. till now i'm still waiting..

and i think Silvethorn has the same sentiments with me..

unless your doing manually run this strategy everytime..

---

## Re: Breakeven Strategy

**chimpy** · Fri Feb 07, 2014 5:44 am

> **PipGrabber wrote:**
>
>
> > **Apprentice wrote:**
> > It should work on all open positions.
>
>
>
> that brings back to my request. that this strategy automatically detect opened positions.. till now i'm still waiting..
>
>
> unless your doing manually run this strategy everytime..

A quicker route to making the break even strategy detect open positions is if its linked to or part of some other stretegy or signal. If it could be made to work with the Strategy Builder, then when this strategy is eventually fixed there wont be endless requests to make it work with this, that or the other strategy.
The Highly adaptable RSI and Advanced Fractal strategies are well thought out and have many options, if all these other goodies were developed to a standard template then I think it would benefit everyone and save a lot of requests and development time.

I'd personally like to see the break even strategy working with the Advanced Fractal. If it works with anything reasonable then it would be great.

---

## Re: Breakeven Strategy

**Silverthorn** · Fri Feb 07, 2014 7:29 pm

It needs to be able to be set so that when applied to a pair it monitors ALL open positions reguardless of how they were opened.

---

## Re: Breakeven Strategy

**chimpy** · Sat Feb 08, 2014 5:44 am

> **Silverthorn wrote:**
> It needs to be able to be set so that when applied to a pair it monitors ALL open positions reguardless of how they were opened.

an option like that is desirable for some but you may not want it to close some positions for that symbol. e.g. long term positions with an intentionaly big stop or positions generated by a different strategy.
both is best.

---

## Re: Breakeven Strategy

**moomoofx** · Fri Feb 14, 2014 6:36 am

Hi all,

I have re-written this strategy to support all open trades so you do not have to specify the trade in advance and it only works per account and per symbol so if you don't want your trade to be impacted by this strategy, put it on another account. I also tried to implement trailing stop losses as someone requested that.

HOWEVER - there are some conditions for FIFO users that I'll explain.

Firstly, FIFO accounts are very difficult to work with. It appears there is no way to link an existing Entry Stop order with the trade it is supposed to stop, for FIFO accounts. Therefore, if you have a FIFO account, the system has no idea which stop order is for which trade - and it doesn't matter since it is FIFO anyway.

The problem is that when this strategy runs, it also cannot tell if an existing trade has an associated Entry Stop order and therefore cannot know if it should update a possibly existing order, or create a new one.

The problem becomes worse if you are FIFO and Hedging is enabled, because if a stop order was attached to the original trade, and this strategy created another one, you'll end up with an open position in the opposite direction. Even worse still, this strategy would normally then go create a stop order for that trade, but I've coded it to detect it's own trade and not do that at least.

Therefore, I'm sorry FIFO users, the strategy does not, and cannot, support trades with existing stop orders very well. It will presume all trades do not have stop orders already created.

For regular Non-FIFO users, it updates existing stop orders as required.

I don't have a FIFO account so I haven't tested except in the debugger. On my Non-FIFO demo it worked fine. Let me know how it looks guys.

Cheers,
MooMooFX

---

## Re: Breakeven Strategy

**Vantages** · Wed Jun 18, 2014 9:24 pm

Hello moomooFx,

Fortunately, all your works and revisions for a lot of strategies are the
ones I ever planned to develop, not by me, but with someone else more
capable but it always came out with a lot of challenges. I just registered
in this site to give compliments to all your accomplishments in this venue.
Thank you very much! You're amazing!

I tried all versions and updates of HIGHLY ADAPTABLE RSI and it works
perfectly fine in line with my approach. What I only notice is it's not working
with longer periods beyond 100 and "valid interval for operation in second"
is a bit tricky-not really sure if it's working- can we replace this with number of
touches or crosses instead to minimise the multiples?

To complete my overall portfolio setup I included your version of BREAKEVENALL,
but unfortunately not performing the way it should be- ERROR ON STOP.
I tried to set it to (10,10) , (10,1) , (10,0) with only one currency pair.

My setup will continuously place new positions-unlimited base on
HIGHLY ADAPTABLE RSI without stops and limits and trailings and filters,
purely base on level crosses, but the BREAKEVENALL is supposed to reduce
the said positions should the price bounces back. Last night, the setup
entered more than 100's of new positions, but the BREAKEVENALL is giving
me headaches-should have closed more than half of those new positions...

Please help me on this issue. The BREAKEVENALL will complete my setup.

Thanks a lot!

Vantages

---

## Re: Breakeven Strategy

**moomoofx** · Sun Jun 22, 2014 1:16 pm

Hi Vantages,

Apologies for the late reply, I am travelling at the moment.

Thank you for the nice comments. I'm glad to hear you are generally happy with my work. Sorry to hear you are having some problems.

Regarding the HA RSI strategy, this is the wrong forum topic to discuss this strategy. However, in short:
- Periods up to 10000 should be fine. If you have any specific examples of it not working, please post the details on the HA RSI strategy's topic.
- An enhancement instead of "Valid interval for operation in second" is also possible, please post the details on the HA RSI strategy's topic.

Regarding the BreakEvenAll troubles you are having... if you are creating positions without any stops via the HA RSI strategy then I cannot see any reason why it should not work.
- You said it errors on stop? What is the error message you are seeing?
- Can you please let me know which currency pair are you using and if your account type is FIFO or Non-FIFO?
- If you configure the HA RSI strategy to create a stop on those trades, does the HA RSI strategy successfully create stop orders on newly opened positions?

If I can reproduce the problem, then I can fix it. Although, I am travelling so please be patient.

Cheers,
MooMooFX

---

## Re: Breakeven Strategy

**Vantages** · Sun Jun 22, 2014 8:16 pm

Hello MooMooFx,

Thank you so much for your response. Highly Appreciated.

The account is non-FIFO.

With regards to BREAKEVENALL, I explored the strategy a bit more with your HA RSI and here are some of my inquiries and suggestions:

-The logics of the strategy is very useful & brilliant, the data inputs necessary :
>LEADGAP:Initial positive gain(pips) that will act as cushion and exit level should the price retraces,
>MINPROFITS: Trails the initial positive gain from or starting from the LEADGAP,
>SETTRAILING: YES or NO to trail the positive gained, otherwise will stay at the LEADGAP level?

-Attachment to any other strategy MUST have a stoplevel to begin with? (I think my error is in here)
-Attachment to any other strategy WITH MAGICNUMBER to avoid interference in any forex,indices,CFD's and commodities in any amount and frequency of trades in any one account/login?

In my case which I will explain further in HA RSI forum is taking hundreds (thousands in the future)
of new positions everyday, would it be possible to add CLOSEALL (symbol specific) with certain
TOTALPROFIT (pips) should there be any exaggerations in price and not just taking the retracements of it? I think with this, PROTECTION and PROFIT are combined...

Thank you for your time. Looking forward for your response. Have a safe & nice day!

Vantages

---

## Re: Breakeven Strategy

**Vantages** · Mon Jun 23, 2014 9:23 pm

Hello MooMooFx,

In addition to my recent post, I just want to share the recent scenario with the BREAKEVENALL strategy yesterday in my live account. HA RSI was set to m1>100period>50levelcross>multiplesell>nofilters>noentries>withcustomid>1000secondinterval
>1000trailingstop>1000limit; BREAKEVENALL was set to m1>10minprofit>10leadgap>trailing.

What happened was that more than 50 positions was entered by HA RSI, 12 of those got more than +30pips profit each, but those 12 positions with more than +30pips profit each was exited at just +10pips profit each. My confusion here is I thought that with my setup when or each +10pips profit the leadgap will also move by +10pips making it +20pips cushion and in my case yesterday should have been +30pips profit cushion in each position when the price retraces to some previous level.

I also noticed that the strategy must be PAUSED-RESTART for 5 to 10 times before it works out.

Hope you could give clarity to my case. Thank you and have a nice day.

Vantages

---

## Re: Breakeven Strategy

**Vantages** · Tue Jun 24, 2014 8:03 pm

Hello MooMooFx,

I'm thinking about how to maximise the BREAKEVENALL strategy a bit more. Since, I think it would be better if it will trail the profits more efficiently and a modifications to add CLOSEALL at certain total profits or CLOSEALLPROFITS(when the market price reaches the average of all open positions<half of those are in negative and another half are in positive> will only close all positions with positive) this will ensure protection and profitability even if market price are very volatile.
OR
What about the ability to enter new positions progressively ? By the time it moves the stop to breakeven level and so much more if it starts to trail the profits, would it be a lot better and more profitable to any one if it starts to open new positions ( only when there are profits to risks going forward ) ? This is like adding to a winning positions and to go for the jugular trades. There will be no added risks here in trying to accumulate new positions as long as we are only risking what we gain and not our capital.

Please let me know your thoughts on the idea. Thank you and have a nice day!

Vantages

---

## Re: Breakeven Strategy

**Apprentice** · Fri Jun 27, 2014 3:59 am

Your request is added to the development list.

---

## Re: Breakeven Strategy

**moomoofx** · Sat Jun 28, 2014 1:15 am

Hi Vantages,

Thank you for your suggestions and feedback. You have posted numerous times, each with different content and leading to different directions.

The point of the BREAKEVENALL strategy is to capture a certain amount of pips (or zero for break-even) once a certain profit level is reached. This is done by simply creating a stop order at the specified gap - trailing can also be set. It is not designed to be a trading strategy at all, and never will be.

Two things concern me:
1) You said in the first post there was an error, and I asked for details but you never mentioned it again. I am very interested to know if there are bugs or errors in the strategy - please clarify this.
2) It seems to me like you do not know what you really want as your request enhancements are always changing. Please have a good think about what you want and when you are finalized in this, post your request on the Indicator and Signals request forum: [viewforum.php?f=27](https://fxcodebase.com/code/viewforum.php?f=27)

Thanks,
MooMooFX

---

## Re: Breakeven Strategy

**Vantages** · Sat Jun 28, 2014 2:24 am

Hi MooMooFx,

Thank you for your response.

First, sorry if I gave confusion to my posting by relaying the day-to-day
scenario of my live account using HA RSI together with BREAKEVENALL.
I thought I'm giving a clear picture by doing that.
Second, the error appears only when I don't put stop in HA RSI(because I never put stop in all my positions before). I am managing that already. It works fine now. However, settings <PROFIT10><GAP5> making the profits gained steady to 5 even if the position/s gained 30pips or more. TRAILING function confuses me, I thought with my settings the limit will move each 10 by 5,
meaning the profits of 30 should have moved the (trailing) limit to 15. Please clarify.
Third and lastly, if I may request for some modifications like:
>MOVING STOPS TO BREAKEVEN,
>TRAILING PROFITS,
>>CLOSING AT PROFITS ( closing positions with profits only leaving the positions with negatives),
>>CLOSING ALL AT PROFITS ( closing all positions with pre-determined value ).

The said modifications if granted will be beneficial to those who accumulate a lot of shares at different levels and market prices.

Thank you very much for your time.

Vantages

---

## Re: Breakeven Strategy

**moomoofx** · Sat Jun 28, 2014 8:59 am

Hi Vantages,

Ok so you say the error happens only if you do not set stops. Can you tell me what the error is please?

By looking at your requested enhancements, it seems to be that you do not understand how the strategy works because 2 of them are already supported - so let me try to explain how the strategy works.
- **Min Profit** defines the min profit that must be reached so the Stop can be created or updated.
- **Lead Gap** is how many pips gap from break-even to set the stop.

Therefore,
- if Profit = 10, and Gap is zero. A stop order will be created to break-even (meaning Profit of zero) when the Profit level has reached 10.
- if Profit = 10, and Gap is 5, then a stop order will be created at 5 pips profit when the profit has reached 10.

If trailing is set to true, the stop will be a trailing stop in dynamic mode - meaning it moves every pip (not every 10 or every 5 or anything like that - this is not configurable).

Does this make sense? So, going back to your enhancement requests
**MOVING STOPS TO BREAKEVEN**: This is what the strategy is designed for. Set the gap to zero, and Profit to the profit level when you want the stop to be created to break-even.
**TRAILING PROFITS**: Set trailing to true, and when the stop is created it will be of type trailing. Obviously if you want it to be in profit instead of just break-even, make the Gap > 0.
**CLOSING AT PROFITS**: This is just a Limit order. Why do you not configure your trades to have a certain profit target when the trades are placed?
**CLOSING ALL AT PROFITS**: This enhancement can be added.

I hope this helps. Remember, I'm on holiday so do not expect fast responses from me.

Cheers,
MooMooFX

---

## Re: Breakeven Strategy

**Vantages** · Sun Jun 29, 2014 9:27 pm

Hello MooMooFx,

The error appears to be :
"Failed to change stop xxx . The stop value must be positive real number > xxx"
I believed the above error with real accounts was due to wrong inputs to BEAll Strategy. No bugs I guess. It performs smoothly now.

On the other hand, what's amazing about participating in the financial markets is that we are looking at market prices everyday but with different and unquantifiable perceptions with regard to its directions. I have enough experiences to share - your BEALL strategy will be so important to me.
Please forgive me for being too critical with the strategy, It will be attached to almost all of my real accounts. I've wriiten four (4) functions, two (2) of which are given functions and two (2) as a request for enhancements and as a matter of strategy's function sequence, I'm doing those manually with my real accounts for three (3) years now and I'm so glad you just did it for us.

Furthermore, putting limit order is totally different if you are positioning at multiple levels if one would want to exit at breakeven level and would want to close all just the positive trades leaving the negative trades. Wish I could explain and elaborate my own approach here.

Laslty, If I may write the specifics of my requests:
Functions to:
1> Trailing profits from the gap.
2> Closeatprofits all positive trades-symbol at breakeven level.
3> Closeallatprofits all trades-symbol at pre-determined pips or grosspl.

Thank so much for your time. I appreciate all your responses.

Vantages

---

## Re: Breakeven Strategy

**pinimo** · Wed Aug 06, 2014 11:39 am

This strategy works very well , there is only one problem...sometimes the strategy pauses by itself and you have to restart it manually. I noticed this thing when the strategy is active on more than one currency pair but but I could not figure out what condition causes this problem.

some consideration?

---

## Re: Breakeven Strategy

**Apprentice** · Sat Aug 09, 2014 4:42 am

This is buildin functionality.
It will close underlying strategy if associated position no longer exists.

---

## Re: Breakeven Strategy

**toxxum** · Tue Dec 16, 2014 10:42 am

> **moomoofx wrote:**
> Hi all,
>
> I have re-written this strategy to support all open trades so you do not have to specify the trade in advance and it only works per account and per symbol so if you don't want your trade to be impacted by this strategy, put it on another account. I also tried to implement trailing stop losses as someone requested that.
>
> Cheers,
> MooMooFX

Great script, really, am lovin' it! I have tried it on a demo and am using it on my live account. I see only a small problem: Say I have 4 open positions, all in profit and the SL has kicked in. Now I am adding a 5th lot, obviously at a worse price so the SL has not been set by the script. That is unfortunate, because if I get stopped out of the first 4 positions, I naturally also want to get stopped out of the 5th one. Is there any way (without spending too much time on it) to modify the strategy in such a way that it looks at the average price of all 5 positions and sets the stops accordingly?

Thanks a bunch!

---

## Re: Breakeven Strategy

**moomoofx** · Tue Dec 16, 2014 7:08 pm

"Net Stop" mode such that it sets the stops on all trades to be the net break-even --- added to the to-do list.

Cheers,
MooMooForex

---

## Re: Breakeven Strategy

**toxxum** · Tue Dec 16, 2014 11:12 pm

> **moomoofx wrote:**
> "Net Stop" mode such that it sets the stops on all trades to be the net break-even --- added to the to-do list.
>
> Cheers,
> MooMooForex

Terrific, thanks so much!

---

## Re: Breakeven Strategy

**muz1979** · Tue Mar 31, 2015 9:24 pm

BreakEvenAll.LUA is working fine but i also want to be able to close half my position as soon as break even is set. I heard this was in development. has that completed?

---

## Re: Breakeven Strategy

**Apprentice** · Wed Apr 01, 2015 4:20 am

Your request is added to the development list.

---

## Re: Breakeven Strategy

**daniel.kovacik** · Thu Apr 09, 2015 10:26 pm

Hi,

can some strategy open orders in some direction when I trigger buy/sell order.
This strategy would automatically trigger advanced orders like breakeven, partial sell, trailing stop after breakeven, target points... I ll only choose size (risk) and SL and target points will automatically set to 1:x (loss:profit).

Or some strategy, which will open another orders which are similar to first one but one trigger (buy/sell). Something like mirroring of postions and multiple.
But at same price and time. Also with different limit orders for partial sell for at least 2 - 3 target points.

Thanks
Regards,
DK

---

## Re: Breakeven Strategy

**Apprentice** · Sun Apr 12, 2015 10:12 am

Advanced position sizing and risk management is possible.

---

## Re: Breakeven Strategy

**4x4partners** · Fri May 08, 2015 2:10 am

Hi there,

I wanted to let you know that I am receiving the following error with BREAKEVEN Strategy:

"Failed create/change stop Cannot place more than one order of this type for each trade."

Does this occur if your order already has a stop order set?

More importantly, I'm wondering if the Exit Partial option has been - or could be - added (preferably to the BreakevenALL strategy).

The option to Target an initial TP / BreakEven level (along with Exit Partial option) based on ATR and/or Fractal would be amazing as well !

Kindly let me know if this can be done.

Thanks a lot!

Best
4x4

---

## Re: Breakeven Strategy

**4x4partners** · Wed May 13, 2015 8:27 am

The SetTrailing option in BreakEvenAll strategy doesn't seem to work. It correctly sets the stop to trail, but then every time the stop moves up it sets it back to the BreakEven position.

Could you kindly have a look to fix this.

Basically, it should only set the stop to BreakEven point once, and then let the Trailing Stop go until trade closes out.

Thanks

---

## Re: Breakeven Strategy

**4x4partners** · Thu May 14, 2015 7:58 am

In reference to my above issue regarding BREAKEVENALL:

I modified a few lines in ExtUpdate in order to check to see if the current stop is better than breakeven. Seems to work.

If anyone wants the code, I've pasted it below.

Basically replace these 5 lines:

```lua
if (tradeRow.IsBuy) then
                stopValue = openPrice + (gap * instance.bid:pipSize());
            elseif (not tradeRow.IsBuy) then
                stopValue = openPrice - (gap * instance.bid:pipSize());
            end
```

With the below, which adds the additional check:

```lua
if (tradeRow.IsBuy) then
                stopValue = openPrice + (gap * instance.bid:pipSize());

            -- check if the stop is better than the BreakEven level, if so, do nothing and exit
                    if stopValue < tradeRow.Stop then
                        return;
                    end

            elseif (not tradeRow.IsBuy) then
                stopValue = openPrice - (gap * instance.bid:pipSize());

            -- check if the stop is better than the BreakEven level, if so, do nothing and exit
                    if stopValue > tradeRow.Stop then
                        return;
                    end
            end
```

---

## Re: Breakeven Strategy

**D37945** · Thu May 14, 2015 1:04 pm

Hi 4x4partners,

Thanks so much for posting this! This is exactly what I'm looking for. I do have two questions:

1. What would I put in the parameters if I want my SL to me moved to breakeven after 20 pips profit then trail the stop every 10 pips? (is 10 pip trailing stop to tight)

2. Should I not set a TP with these orders? Will setting a TP mess up the strategy?

Again thanks so much!

---

## Re: Breakeven Strategy

**4x4partners** · Fri May 15, 2015 4:44 am

Hi D37945,

I'm not the author of the original, but as far as I can tell:

1. This strategy doesn't allow for a "Fixed" trailing stop, just a dynamic one... meaning for every pip up/down, the strategy moves stop with it (in direction of the trade). It shouldn't be too hard to add the option for a "fixed" trail, but would need to be coded.

2. Setting a TP or SL with the orders shouldn't interfere at all. Your TP (limit order) should stay the same.

Again, I'm not the author, and have only recently begun testing this strategy, so hope that's helpful.

Best
4x4

---

## Re: Breakeven Strategy

**zoltanh** · Tue Sep 08, 2015 2:16 pm

Hi,
Could you check for me the attached why it can give me 'Failed create stop The Rate must be a positive number.' message? (Not sure this is the only problem)
I wanted to add 5 additinal breakeven level - so running strategies on 9 currency pairs, I dont have to set up 54 strategies with 'BreakevenAll' (6 for each) just 9.
My intention is setting breakeven levels not with the trailing function but with my levels keeping the same 'Gap'
thanks in advance!

---

## Re: Breakeven Strategy

**kmason** · Mon Oct 26, 2015 10:54 am

Would the breakeven strategy work for FIFO accounts if the strategy could be instructed to monitor open positions on a certain pair only?

i.e. Use a different version of the strategy for NZD/USD than for NZD/JPY (breakeven-nzd-usd.lua and breakeven-nzd-jpy.lua) and then give each strategy a custom identifier.

My needs aren’t as complex as some of the posters on the board. I do not open multiple positions for the same pair. I simply want a script capable of moving an existing stop loss to breakeven (or 1 pip profit actually) when the trade reaches 21 pips in profit.

Is it even possible to move an existing stop on a FIFO account? It is not a hedging account.

---

## Re: Breakeven Strategy

**Apprentice** · Tue Oct 27, 2015 4:17 am

Would the breakeven strategy work for FIFO accounts if the strategy ...
Sure. As it is it is not currency sensitive.

---

## Re: Breakeven Strategy

**efh123** · Fri Nov 25, 2016 11:21 am

> **4x4partners wrote:**
> In reference to my above issue regarding BREAKEVENALL:
>
> I modified a few lines in ExtUpdate in order to check to see if the current stop is better than breakeven. Seems to work.
>
> If anyone wants the code, I've pasted it below.
>
> Basically replace these 5 lines:
>
>
>
> Code: [Select all](https://fxcodebase.com/code/)
> `if (tradeRow.IsBuy) then
>                 stopValue = openPrice + (gap * instance.bid:pipSize());
>             elseif (not tradeRow.IsBuy) then
>                 stopValue = openPrice - (gap * instance.bid:pipSize());
>             end`
>
>
> With the below, which adds the additional check:
>
>
>
> Code: [Select all](https://fxcodebase.com/code/)
> `if (tradeRow.IsBuy) then
>                 stopValue = openPrice + (gap * instance.bid:pipSize());
>
>             -- check if the stop is better than the BreakEven level, if so, do nothing and exit
>                     if stopValue < tradeRow.Stop then
>                         return;
>                     end
>
>             elseif (not tradeRow.IsBuy) then
>                 stopValue = openPrice - (gap * instance.bid:pipSize());
>
>             -- check if the stop is better than the BreakEven level, if so, do nothing and exit
>                     if stopValue > tradeRow.Stop then
>                         return;
>                     end
>             end`

hello there,

thank you very much for the code.
i seached long time for this through the net.
but i have one problem.

if i insert this in my script it works fine for long trades.
but not for short.

the strategy doesnt set a stop.
i edit a little bit the code but nothing worked.
can someone please help me?

best regards
lux

---

## Re: Breakeven Strategy

**efh123** · Tue Nov 29, 2016 6:59 pm

ok i found out, that i have to set a worser stop in short order. so the strategy edit it to my wish.
buy orders are set from strategy although there is no stop order set at the beginning.

example: if i want to have a stop set bey strategy for 5P - i have to place a short order with stop 20p
and the strategy will edit it to 5p in a sec. if i leave it empty, the strategy will not work.

also becarefull if you have a better stop in 1 position set. if you have more trades open,
the whole strategy will stop. (breakevenall).

so its nice but not perfect.

---

## Re: Breakeven Strategy

**Apprentice** · Sun Dec 18, 2016 9:32 am

Strategy was revised and updated.

---

## Re: Breakeven Strategy

**Cactus** · Mon Oct 23, 2017 3:30 pm

> **moomoofx wrote:**
> "Net Stop" mode such that it sets the stops on all trades to be the net break-even --- added to the to-do list.
>
> Cheers,
> MooMooForex

Has this ever been developed?
A "BreakevenALL" but for net positions (average of all positions for breakeven)

---

## Re: Breakeven Strategy

**Reymondpolanco** · Thu Mar 22, 2018 10:16 pm

Im getting this error

---

## Re: Breakeven Strategy

**Apprentice** · Tue Mar 27, 2018 10:29 am

Try this version.

 [Breakeven Strategy.lua](files/118398/Breakeven%20Strategy.lua)

---

## Re: Breakeven Strategy

**Reymondpolanco** · Wed May 09, 2018 10:08 am

Can you put the option to put an specific price level and pips too

---

## Re: Breakeven Strategy

**Apprentice** · Fri May 18, 2018 6:05 am

Your request is added to the development list under Id Number 4145

---

## Re: Breakeven Strategy

**Apprentice** · Sun May 27, 2018 6:41 pm

Try it now.

 [Breakeven Strategy.lua](files/119375/Breakeven%20Strategy.lua)

---

## Re: Breakeven Strategy

**Reymondpolanco** · Sun May 27, 2018 10:07 pm

> **Apprentice wrote:**
> Try it now.
>
>
> The attachment **Breakeven Strategy.lua** is no longer available

The profit selector works perfect but when i use the price selector i'm gettin this error.

---

## Re: Breakeven Strategy

**Reymondpolanco** · Mon Jun 18, 2018 2:55 pm

> **Apprentice wrote:**
> Try it now.
>
>
> Breakeven Strategy.lua

The profit selector works perfect but when i use the price selector i'm gettin this error.

---

## Re: Breakeven Strategy

**Apprentice** · Sat Jun 30, 2018 5:52 pm

Try this version.

 [Breakeven Strategy_3.lua](files/119763/Breakeven%20Strategy_3.lua)

---

## Re: Breakeven Strategy

**Reymondpolanco** · Sun Jul 01, 2018 7:44 pm

> **Apprentice wrote:**
> Try this version.
>
>
> Breakeven Strategy_3.lua

The profit selector works great but when i chose price and the price reach the level i put, the stop move to the price i put in the strategy not to the breakeven point.

---

## Re: Breakeven Strategy

**Apprentice** · Mon Aug 06, 2018 9:12 am

Try updated Breakeven Strategy_3.lua

---

## Re: Breakeven Strategy

**Reymondpolanco** · Mon Aug 06, 2018 6:24 pm

> **Apprentice wrote:**
> Try updated Breakeven Strategy_3.lua

Works perfect, thanks.
