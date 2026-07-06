# Shadow TSI

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63466  
> Forum: 17 · Topic 63466 · 14 post(s)


---

## Shadow TSI

**Apprentice** · Wed May 11, 2016 4:15 am

![EURUSD m1 (05-11-2016 1040).png](images/106218/EURUSD%20m1%20%2805-11-2016%201040%29.png)



Based on request.
[viewtopic.php?f=27&t=63453](https://fxcodebase.com/code/viewtopic.php?f=27&t=63453)

1. Line
TSI
2. Line
Ma of TSI
3. Line
Ma of MA of TSI

 [Shadow TSI.lua](files/106218/Shadow%20TSI.lua)

 [Shadow TSI with Alert.lua](files/106218/Shadow%20TSI%20with%20Alert.lua)

MT4/MQ4 Version is available here.
[viewtopic.php?f=38&t=63740&p=107517#p107517](https://fxcodebase.com/code/viewtopic.php?f=38&t=63740&p=107517#p107517)


---

## Re: Shadow TSI

**Ipelo78** · Sun May 15, 2016 6:44 pm

Thank you very much apprentice. This is a cool indicator. I use it in my mobile app to trade on the 4h and daily charts but could be used on all time frames. The premise of this is to take trades when the shadow (the blue line on apprentice's chart) crosses over the faster ma and the tsi.


---

## Re: Shadow TSI

**Ipelo78** · Fri May 20, 2016 4:31 pm

Is it possible to code a strategy for the Shadow TSI?


---

## Re: Shadow TSI

**Apprentice** · Mon May 23, 2016 6:38 am

Try this version.
[viewtopic.php?f=31&t=63510](https://fxcodebase.com/code/viewtopic.php?f=31&t=63510)


---

## Re: Shadow TSI

**Ipelo78** · Mon May 23, 2016 4:52 pm

Thank you very much Apprentice!


---

## Re: Shadow TSI

**fxlion** · Thu Jan 12, 2017 1:26 pm

hi apprendice,

can you create mtf shadow tsi strategy

indicator:

1. shadow tsi with default parameter

 buy level:0
 sell level:0
 time frame: m15

2. shadow tsi indicator with default parameters

 buy level: 0
 sell level;0
 time frame; h1

buying conditions are:

**1.tsi > ma1 and ma1> ma 2 and ma2> buy level in h1
2. ma2> buy level in m15 and ma1<ma2 and tsi cross over ma1**

selling conditions are:

**1 tsi < ma1 and ma1<ma2 and ma2< sell level in h1
2. ma2< sell in m115 and ma1>ma2 and tsi cross under ma1**


---

## Re: Shadow TSI

**Apprentice** · Fri Jan 13, 2017 6:51 am

Try this version.
[viewtopic.php?f=31&t=64294](https://fxcodebase.com/code/viewtopic.php?f=31&t=64294)


---

## Re: Shadow TSI

**fxlion** · Fri Jan 13, 2017 7:00 am

thanks apprentice


---

## Re: Shadow TSI

**easytrading** · Tue Jan 17, 2017 2:23 am

Hello Apprentice ;
is it possible to show alert when crossing happen between TSI (green line) and 1-MA (red line), please ? with much appreciation.


---

## Re: Shadow TSI

**Apprentice** · Tue Jan 17, 2017 4:44 am

Shadow TSI with Alert.lua added.


---

## Re: Shadow TSI

**Daveatt** · Mon Dec 10, 2018 1:05 pm

Hi Apprentice

Could you please develop the MTF indicator Shadow TSI ?
Didn't succeed to make the getsynchistory function works for all signals

Thanks
David


---

## Re: Shadow TSI

**Daveatt** · Tue Dec 11, 2018 5:14 am

Actually I managed to make it work fine

Please disregard this request

Thanks


---

## Re: Shadow TSI

**bartwas1** · Wed Oct 05, 2022 6:06 am

Hi Apprentice

I've noticed a request from arfs9090 regarding TSI dynamic and wanted to ask if Shadow TSI from marketscope and TSI dynamic from Trading View have similarities in terms how TSI reaches tops and bottoms? I mean this orange MA. See at: [https://www.tradingview.com/v/NhsUlg0D/](https://www.tradingview.com/v/NhsUlg0D/)
I've gleaned at the code, but I'm not a coder - it seems its value is 100 and MA is double smoothed... delta?? Just guess,... I guess.
Apprentice, do you mind letting me know, please.

PS.
My first impression of Trading View's version with an orange MA in conjunction with dynamic zones is good. I can see interesting trading opportunities when price comes out of the zone.

Kind regards, Bart


---

## Re: Shadow TSI

**Apprentice** · Thu Oct 06, 2022 2:37 pm

Codes are similar,
TradingView has extra Dynamic Zones and Divergence.
TS2 2. line is smoothed 1. Line
