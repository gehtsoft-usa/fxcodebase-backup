# Two Line SuperTrend Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63891  
> Forum: 31 · Topic 63891 · 24 post(s)


---

## Two Line SuperTrend Strategy

**Apprentice** · Fri Sep 23, 2016 4:38 am

![EURUSD m1 (09-23-2016 1041).png](images/108238/EURUSD%20m1%20%2809-23-2016%201041%29.png)



Open Long
Both time frames are in up trend
Open Short
Both time frames are in down trend

Optinal Exit
If two time frames disagree.

If "Use Trend Filter" is off, second time frame filter will not be used.
If "Only on subtrend change" is on, trade will be executed,
 only if we have a change in the indication on smaller time frame.

 [Two Line SuperTrend Strategy.lua](files/108238/Two%20Line%20SuperTrend%20Strategy.lua)

SuperTrend.lua is available here.
[viewtopic.php?f=17&t=3102&hilit=SUPERTREND](https://fxcodebase.com/code/viewtopic.php?f=17&t=3102&hilit=SUPERTREND)

The Strategy was revised and updated on January 21, 2019.


---

## Re: Two Line SuperTrend Strategy

**colajam1979** · Fri Sep 23, 2016 5:55 am

Good morning,
You sure are quick with your work. Thanks for this, i have it running in demo atm hoping it will work as expected


---

## Re: Two Line SuperTrend Strategy

**colajam1979** · Fri Sep 23, 2016 10:15 am

Hello Apprentice.
I have run this in my demo account today and it works well enough for me but Can you modify it one more time so that a first position is opened sooner?

If the 5 minute is the trend line and is long when the 1 minute is short the short will not be opened - perfect.

if the 1 minute short continues changing the 5 minute trend to short can a short position be entered?

all other rules remain the same

see image below.

thanks again


---

## Re: Two Line SuperTrend Strategy

**Norm123** · Tue Oct 04, 2016 2:28 pm

Hi Apprentice,

Many thanks for your content on here. Some really great stuff. I have been testing the 'two line supertrend' with different parameters etc. Almost a really good strategy for what I want.

Is it possible to add a function so that providing the two lines are in same direction, if I am using Line 1 as the shorter time period 'activating' line and it closes on opposite, the strategy keeps opening a new trade at the next trigger point in the same direction?

At the moment, I am using Line 1 as the shorter 'activation' line and Line 2 as the longer term trend. The stategy is only activating a trade at the first trigger point but then not closing on opposite and not activating subsequent trades even when both lines are in same direction.

Thanks!


---

## Re: Two Line SuperTrend Strategy

**Norm123** · Sat Oct 08, 2016 4:09 am

Hi Apprentice,

Having playing and fiddled with the parameters etc I have got it working.

Is it possible to add a Bollinger band filter to this strategy? In a long, when the price crosses through the upper Bollinger band, the trade closes and in a short, when the price crosses the lower band the trade closes?

Dan


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Wed Oct 12, 2016 5:26 am

Bug Fixed.
Please Re-Download.


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Wed Oct 12, 2016 5:56 am

> At the moment, I am using Line 1 as the shorter 'activation' line and Line 2 as the longer term trend. The stategy is only activating a trade at the first trigger point but then not closing on opposite and not activating subsequent trades even when both lines are in same direction.

Set "Only on subtrend change" to no


---

## Re: Two Line SuperTrend Strategy

**JOKER83** · Sat Oct 29, 2016 6:06 pm

can you make close parameter to the bigger supertrend


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Sun Dec 18, 2016 9:10 am

Strategy was revised and updated.


---

## Re: Two Line SuperTrend Strategy

**josediaz** · Fri Jan 13, 2017 5:54 am

hi

i have installed your strategy, but there are not buy or sell

allow startegy to trade = true

thank you

regards


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Sun Jan 15, 2017 5:13 am

![EURUSD m1 (07-11-2016 0130).png](images/110524/EURUSD%20m1%20%2807-11-2016%200130%29.png)



Tested in the simulator.
Can you tell me more about your testing method.
FIFO / non FIFO, Live / Demo Simulator / Backtester, used settings...


---

## Re: Two Line SuperTrend Strategy Beug

**albertparis** · Thu Sep 21, 2017 10:46 am

beug

Hello

The maximum number of lots is 100


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Fri Sep 29, 2017 7:34 am

Try it now.


---

## Re: Two Line SuperTrend Strategy

**albertparis** · Sat Sep 30, 2017 9:36 am

> **Apprentice wrote:**
> Try it now.

thank you for your work


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Sat Dec 30, 2017 8:22 am

The strategy was revised and updated.


---

## Re: Two Line SuperTrend Strategy

**lucasyokko** · Fri Feb 07, 2020 9:36 am

Hi
Do you have Mt4 version for this strategy?


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Mon Feb 10, 2020 6:28 am

Your request is added to the development list.
Development reference 703.


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Wed Feb 12, 2020 1:43 pm

Try this version.
[viewtopic.php?f=38&t=69405](https://fxcodebase.com/code/viewtopic.php?f=38&t=69405)


---

## Re: Two Line SuperTrend Strategy

**tuhadfe** · Thu Feb 27, 2025 12:05 pm

Hi this strategy has a bug it doesnt appear to sell just buy


---

## Re: Two Line SuperTrend Strategy

**tuhadfe** · Tue Mar 04, 2025 5:13 am

Hi

This doesnt work for me, can the bug be fixed.

Can enter a trade if both trend filter and subtrend are in buy or sell but exit the trade if the subtrend changes in opposite direction.

eg
Only enter a trade when both are in same direction and exit trade when either change.


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Tue Mar 04, 2025 5:23 am

We have added your request to the development list.
Development reference 146


---

## Re: Two Line SuperTrend Strategy

**tuhadfe** · Wed Mar 05, 2025 7:51 pm

Hi is this a development request or just a bug fix?

It doesnt Sell if you select sell, also it doesnt appear to use the subtrend.

I would appreciate any help.

Thanks


---

## Re: Two Line SuperTrend Strategy

**Apprentice** · Fri Mar 14, 2025 4:24 am

![EURUSD m5 (03-14-2025 1022).png](images/158611/EURUSD%20m5%20%2803-14-2025%201022%29.png)



I have no problems.
Keep in mind, each line will work on its own respective timeframe.


---

## Re: Two Line SuperTrend Strategy

**tuhadfe** · Sat Mar 15, 2025 12:22 pm

Thanks I think its my confusion, I had installed a different version of the underlying supertrend, already installed prior and it was using this version. I didnt spot this...sorry my bad
