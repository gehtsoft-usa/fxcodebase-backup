# Price MA Cross Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=59386  
> Forum: 31 · Topic 59386 · 15 post(s)


---

## Price MA Cross Strategy

**Apprentice** · Tue Sep 03, 2013 5:43 am

![Price MA Cross Strategy.png](images/89123/Price%20MA%20Cross%20Strategy.png)



Open Long
Price cross over MA
Close Short
Price cross under MA

 [Price MA Cross Strategy.lua](files/89123/Price%20MA%20Cross%20Strategy.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: Price MA Cross Strategy

**edevine** · Thu Apr 10, 2014 4:30 pm

Yes. something like this, but ma should be the 8 period ema. can you make the adjustment? Is that how this happens? I'm a rookie.


---

## Re: Price MA Cross Strategy

**edevine** · Thu Apr 10, 2014 4:41 pm

hello again. I just noticed that the #2 in the circle markings don't seem to be filling orders when I would like to see. I would like to see the strategy go long when the price candle closes above the 8 period ema, and go short when the price candle closes below the 8 period ema.

Thx again for your consideration.

Ed


---

## Re: Price MA Cross Strategy

**Apprentice** · Sat Apr 12, 2014 3:49 am

This is expected, if I understood u.

Strategy is configured for the End of Turn execution.

Trade is executed at the transition between the two candles.
Indicated on the next candle.


---

## Re: Price MA Cross Strategy

**edevine** · Mon Apr 14, 2014 4:56 pm

Thank you for your help but I am still confused. I am sure it is due to my not being totally familiar with the lingo.

I don't understand why the top left corner of the graph time frame say "ema 5, close, 14; 2.xxx?

What I am looking for is a market order to go long on the close of the 1st candle that closes above the 8 period ema, closes this position when the 1st candle closes below the ema, and go short with a market order on the close of that candle.

I really appreciate your help.

Thx,

Ed


---

## Re: Price MA Cross Strategy

**Apprentice** · Tue Apr 15, 2014 11:59 am

Strategy will do just that. Delayed.
If you use m1, the delay can be 59.99 seconds.
If you use H1, the delay can be 59.99 minutes.

So it will be executed at the end of the current period.

Top left corner
MVA EUR / USD M5 close, 14

MVA - MVA or SMA moving average.
M5 -5 minute time frame
14 - MVA period is 14


---

## Re: Price MA Cross Strategy

**Dkoop60** · Fri Aug 08, 2014 11:30 am

Is there a way to turn off the strategy once an order has been filled? I would like for the limits and stops to be the only way to exit the trade once an entry has been filled. It seems that as soon as the price recrosses the MA it closes the position.

Also, is there a way to reverse the entry direction so that if the price crosses over from below that it would enter as a sell?

Thanks, Let me know if I am unclear about something or mistaken.


---

## Re: Price MA Cross Strategy

**Apprentice** · Sat Aug 09, 2014 4:17 am

Such modifications are possible.


---

## Re: Price MA Cross Strategy

**Dkoop60** · Sun Aug 10, 2014 10:45 am

Would it be considered a new strategy? Do I need to start a new thread?

Thanks.


---

## Re: Price MA Cross Strategy

**Dkoop60** · Fri Oct 17, 2014 10:12 am

Hi
I think I just got what I was looking for at the "Offset EMA" thread.

Thank you Program Architects!

DKoop


---

## Re: Price MA Cross Strategy

**JOKER83** · Thu Dec 25, 2014 3:56 pm

HALLO
CAN YOU MAKE A TRADE CLOSE STRATEGY

WHEN PRICE CROSS MY EMA CLOSE MY TRADES??

THANKS FOR GOOD WORK


---

## Re: Price MA Cross Strategy

**Apprentice** · Sat Dec 27, 2014 2:05 pm

Your request is added to the development list.


---

## Re: Price MA Cross Strategy

**Apprentice** · Sat Dec 27, 2014 2:05 pm

Your request is added to the development list.


---

## Re: Price MA Cross Strategy

**JOKER83** · Tue Dec 30, 2014 5:57 pm

HI
CAN YOU MAKE A PARAMETER
CLOSE TRADES -YES - NO
THANKS


---

## Re: Price MA Cross Strategy

**Apprentice** · Sun Dec 11, 2016 1:49 pm

Strategy was revised and updated.
