# Scalping Asian HL EA

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=74787  
> Forum: 38 · Topic 74787 · 6 post(s)


---

## Scalping Asian HL EA

**Karimrjh** · Tue Apr 16, 2024 6:17 am

HI, is it possible to build an Expert Advisor based on this strategy:

DETERMINING THE ASIAN SESSION HIGH AND LOW OF THE DAY

Using 2100 GMT as the start of a new daily candle, at 0600 GMT, you will be able to identify the High / Low of the Day for the Asian session by 0600 GMT.

ENTRIES AND EXITS

I have added a moving average to spot high probability setups, thus avoiding entering any positions against the trend. The moving average we will be using is 55-EMA on the hourly chart. All you need is to identify the trend using the EMA on the hourly chart, then switch to 5-minute time frame to enter either buy at the Asian High or sell order at Asian Low (this system will usually yield at least 10 pips for you):

Buy Order

55-EMA on the hourly chart is on uptrend mode
Set the buy order at the Asian High Ask Price
Set the stop-loss of 30 pips away from the Asian High
Set the first targeted profit at 15 pips
Set the second targeted profit at the next mid-pivot price level or the next pivot point
Move stop-loss to break even after the first target profit is hit
Exit the second lot at the close of the 5-min bar if it closed lower than the nearest pivot point
Sell Order

55-EMA on the hourly chart is on downtrend mode
Set it at the Bid Price at the Asian Low
Set your stop-loss of 30 pips away from the Low
Set the first target profit at 15 pips and the second target profit at the next mid-pivot price level or the next pivot point
Move stop-loss to break even after the first target profit is hit
Exit the second lot at the close of the 5-min bar if it closed higher than the nearest pivot point
Pairs to Trade

GBPUSD
works on other pairs but do try it out with different SL and TP.


---

## Re: Scalping Asian HL EA

**Apprentice** · Mon Apr 22, 2024 11:26 am

We have added your request to the development list.
Development reference 328


---

## Re: Scalping Asian HL EA

**Apprentice** · Mon Apr 29, 2024 11:40 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=74829](https://fxcodebase.com/code/viewtopic.php?f=38&t=74829)


---

## Re: Scalping Asian HL EA

**Karimrjh** · Mon Oct 21, 2024 2:57 pm

Thank you so much, sorry for the late response, but i got 9 errors and cant compile it.


---

## Re: Scalping Asian HL EA

**Apprentice** · Thu Oct 31, 2024 8:53 am

We have added your request to the development list.
Development reference 825


---

## Re: Scalping Asian HL EA

**Apprentice** · Mon Nov 04, 2024 4:47 am

Try this version.
[https://fxcodebase.com/code/viewtopic.p ... 68#p157168](https://fxcodebase.com/code/viewtopic.php?f=38&t=75336&p=157168#p157168)
