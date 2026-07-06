# EMA CCI RSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=11917  
> Forum: 31 · Topic 11917 · 16 post(s)


---

## EMA CCI RSI Strategy

**Apprentice** · Wed Jan 18, 2012 6:27 am

![ECR Strategy.png](images/23788/ECR%20Strategy.png)



Long
Close crossover EMA
RSI < RSI Buy Level
CCI < CCI Buy Level

Long
Close crossunder EMA
RSI > RSI Buy Level
CCI > CCI Buy Level

 [ECR Strategy.lua](files/23788/ECR%20Strategy.lua)

MTF Exit Rules
Close crossunder EMA
Exit Long
Close crossover EMA
Exit Short

 [MTF ECR Strategy.lua](files/23788/MTF%20ECR%20Strategy.lua)


---

## Re: EMA CCI RSI Strategy

**LearningForex** · Sat Feb 11, 2012 9:30 pm

Hi Apprentice,

Thanks for your work!

Can you explain how you want the EMA to work in this Strategy?

Would a crossing of 2 EMA's be better instead of one?


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Sun Feb 12, 2012 4:36 am

When the price is greater than the EMA we have Long EMA indication,
When the price is less than the EMA we have Short EMA indication,

I'm just a programmer.
Strategy is done according to user specification.
In my trading, I do not use indicators or strategys.


---

## Re: EMA CCI RSI Strategy

**sergar** · Mon Feb 13, 2012 1:29 pm

Good day,

i was wondering if it is possible to adapt this strategy so that it can check RSI in another timeframe..
Thanks for the great work,

Sergio


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Tue Feb 14, 2012 7:18 am

Your request is added to the development list.


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Wed Feb 29, 2012 4:31 pm

MTF Version added.


---

## Re: EMA CCI RSI Strategy

**kuddus24** · Mon Apr 29, 2013 1:09 pm

Hi Admin,
Grt work.I was just wondering if you could take off the 'EMA' indicator from this strategy and make a new one based solely on CCI and RSI.So i'm looking to buy when CCI>100 and RSI>50 and sell when CCI<100 and RSI<50.its the most simple strategy but works pretty grt with 20/10 tp/sl.it works on any time frame with appropriate tp/sl.so users can tweak the numbers as per their judgments.please advise.thanks....


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Fri May 03, 2013 3:02 am

Your request is added to the development list.


---

## Re: EMA CCI RSI Strategy

**kuddus24** · Tue May 14, 2013 2:44 am

Hi Admin,
Can i just ask how long it takes on average to process a request?I made a slight mistake when i requested for my strategy.Here is the revised one
CCI>100 & RSI>50=BUY
CCI<-100 & RSI<50=SELL
Trades will be initiated by the strategy but closed by specified TP/SL.
Thanks


---

## Re: EMA CCI RSI Strategy

**fxcyberman** · Mon May 27, 2013 4:27 am

I have tested this strategy already and found it is working and with winning rate over 50%.
Is it possible to add a martingale theory into this strategy ? that's if lose first trade. then double the lot size for next trade automatically and so on. Also can setup a maximum loss limit in trades numbers. Thanks in advance.


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Sun Jun 02, 2013 12:36 pm

Your request is added to the development list.


---

## Re: EMA CCI RSI Strategy

**rrrix1** · Mon Aug 05, 2013 5:59 pm

Just wanted to say - this is the most amazing strategy, very good win and very profitable. Thank you! would like to see other users ideas to make it even better - maybe an EMA confirmation option also.


---

## Re: EMA CCI RSI Strategy

**JOKER83** · Fri Dec 26, 2014 4:28 pm

HI
can you make a Indicator with entry dots signal
THX


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Sat Dec 27, 2014 2:04 pm

Your request is added to the development list.


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Tue Jun 28, 2016 9:20 am

Try this version.
[viewtopic.php?f=17&t=63633](https://fxcodebase.com/code/viewtopic.php?f=17&t=63633)


---

## Re: EMA CCI RSI Strategy

**Apprentice** · Wed Jan 31, 2018 10:29 am

The strategy was revised and updated.
