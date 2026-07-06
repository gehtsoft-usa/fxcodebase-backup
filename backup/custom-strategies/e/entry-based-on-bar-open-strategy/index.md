# entry based on bar open strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=6303  
> Forum: 31 · Topic 6303 · 17 post(s)


---

## entry based on bar open strategy

**Alexander.Gettinger** · Mon Sep 05, 2011 11:27 am

If the price is higher than the open price of more than [PipsCount] opened a BUY order.
If the price is lower than the open price of more than [PipsCount] opened a SELL order.

Download:

 [Entry_Based_Strategy.lua](files/14544/Entry_Based_Strategy.lua)


---

## Re: entry based on bar open strategy

**jgwill** · Fri Sep 09, 2011 8:14 am

Hi,

Interesting strategy. I like the idea.

Would that be possible, when a signal is triggered for a said bar that it does not do generate more signal (alert) until next bar.
What I got here is more than one alert poping up if the price varies above/bellow the Pips number specified when in the same bar period.

Thank,

Regards,

JG


---

## Re: entry based on bar open strategy

**LordTwig** · Mon Sep 12, 2011 8:03 am

Hi,

I partly agree with 'jgwill' need an option to allow only one trade or ''x' or unlimited amount of trades.

Also can you add option to use yesterdays OPEN instead or open of 'x' periods ago? (Will of course need to be aware of non trading days for this options)

Also if you can create indicator for it as well that would be good?
Can the indicator include changing the candle color when a signal is generated?

Cheers
LordTwig


---

## Re: entry based on bar open strategy

**jgwill** · Tue Sep 13, 2011 10:50 am

Good idea for the amount of trade.


---

## problems on managed accounts

**BULANEL** · Fri Sep 30, 2011 1:15 am

hi alexander, your strategy is very helpful, but it does not work on managed accounts. With exactly the same parameters it runs perfectly on individual accounts, but on my account which trades several managed accounts and then distributes the trades, it produces no trades. Do you think it can be fixed?


---

## Re: entry based on bar open strategy

**vaguthun** · Sun Oct 30, 2011 3:45 am

Hi
This is something I have been looking for.
Can you Modify this so that it open orders based on a reference candle (may be at a specific time)
example based on the start candle at 14:00 hrs..

And also with the option if the buy order is filled then cancel the sell order.

Regards
Jojo


---

## Re: entry based on bar open strategy

**ronald3rg** · Tue Dec 06, 2011 10:01 am

This is the strategy i have been looking for very similar to n-bars strategy. This strategy could be improved by Adding

-mandatory closing 24hr period.
-confirmation by candles and/or moving averages. specially if it can be confirmed on a lower TF
-option to select multiple or single trade. -(big issue with this one tends to give multiple signal for same candle. should only go in once to be effective.)

i believe this should make this an effective strategy to trade just once a day. with the right parameters you could possibly go in the right direction everyday and close out at the end of day.

right place at the right time every time

3RG


---

## Re: entry based on bar open strategy

**Apprentice** · Wed Dec 07, 2011 3:39 am

Your request is added to the developmental cue.


---

## Re: entry based on bar open strategy

**taypot** · Thu Dec 08, 2011 5:25 pm

I like this strategy but for some reason it doesn't always place the stops. The limits are set as they should be. I am trying to set the stop at 3 pips after optimising and finding that this was a profitable level. Maybe this is too small?

There are also multiple orders running which perhaps I would like the option to stop. At present they are all in profit so it doesn't seem a problem but maybe it would be better to be cautious if I use it on my live account. I think it opens new entries each time it revisits the initial starting level and I have 3 open at present.

Thanks for all your hard work.


---

## Re: entry based on bar open strategy

**taypot** · Fri Dec 09, 2011 2:40 pm

Thanks, no need to reply to my last post as I have sorted both problems.

Stop needs to be 4 or more to appear and order needs to be placed "at end of period" to avoid multiples opening.

I am getting good results with this in a ranging market so an indicator that identifies that there is not a trend (ADX<30) may be a useful addition if manually placing trades and using this as a signal.

Or maybe a time constraint so that it only runs at non trending market times.


---

## Re: entry based on bar open strategy

**Teaandcoffee** · Thu Apr 30, 2015 2:56 am

Hi,

It is an old topic but I was really wondering if somebody has already coded the strategy as requested below by jgwill.

"when a signal is triggered for a said bar that it does not do generate more signal (alert) until next bar."

I am trying to code it but with my lua code knowledge no successful.

Apprentice, I will be really appreciated if you can find time and add this feature to the strategy.


---

## Re: entry based on bar open strategy

**Apprentice** · Mon Dec 12, 2016 3:50 pm

Strategy was revised and updated.


---

## Re: entry based on bar open strategy

**Teaandcoffee** · Tue Dec 13, 2016 6:14 pm

Thank you for the update.

Would you also add the features;

-Max Number Of Open Position In Any Direction
-Max Number Of Position In One Direction

It is opening lots of same orders at a time without these features.


---

## Re: entry based on bar open strategy

**Apprentice** · Wed Apr 26, 2017 8:04 am

Your request is added to the development list, Under Id Number 3790
 If someone is interested to do this task, please contact me.


---

## Re: entry based on bar open strategy

**Apprentice** · Thu Apr 27, 2017 3:17 am

-Max Number Of Open Position In Any Direction
-Max Number Of Position In One Direction

Added.


---

## Re: entry based on bar open strategy

**aladin** · Sat Jun 16, 2018 10:45 am

Hi,
Is possible add a "create order" to this strategy and not entry directly?
I will use it with reverse option in 4 / 8 hours chart.

Example:

A red Candle Close at price 100
if price go down 15 pips (now price is 85)
create a buy order exactly at 15 pips up (buy order at price 100 or the same price of red candle close)

The same for green candle !

Thank you !


---

## Re: entry based on bar open strategy

**aladin** · Sun Jun 17, 2018 9:27 am

Hi,
I read my last message and is not clear.
I add a picture for made easy what I mean.

When 4 Hours candle close create a 2 different "If-Then" orders, one 15 pips up and one 15 pips down the market price.
When price will touch one price (as picture at 115 or 85) automatically:
1) cancel the other "If-then" still waiting for price,
2) create an order (buy or sell) at the price of the candle close (as picture at 100)

As take profit if possible, can be manual or better close position at end of next 4 hours candle (close all positions when candle close)
As stop loss if possible, can be manual or better all the preview candle.

Example as picture:
Candle 4 hours close at price 100
Create 2 different "If-Then", one at 115 and one at 85
If price touch 115 delete the "If-Then" at 85 and create a sell order at 100
or
If price touch 85 delete the "If-Then" at 110 and create a buy order at 100

Now I think it's clear !
Please, let me know if is possible because TS don't have a OCO for the "If-Then" orders

Thanks in advance for any yours answer.

Best Regards
