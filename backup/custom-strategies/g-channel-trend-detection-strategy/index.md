# G-Channel_Trend_Detection_Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=75732  
> Forum: 31 · Topic 75732 · 16 post(s)


---

## G-Channel_Trend_Detection_Strategy

**Apprentice** · Wed Mar 19, 2025 3:00 pm

![EURUSD H1 (03-19-2025 2059).png](images/158683/EURUSD%20H1%20%2803-19-2025%202059%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.p ... 28#p158628](https://fxcodebase.com/code/viewtopic.php?f=17&p=158628#p158628)

 [G-Channel_Trend_Detection_Strategy.lua](files/158683/G-Channel_Trend_Detection_Strategy.lua)


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Sat Mar 22, 2025 9:31 am

Hi can you add the ability to only entry a trade when
1) Price is equal to the top line then close trade when price ceases to be price falls below user defined percentage / number pips

Same for the bottom line also can option put in number of trades in one direction till it reverses

Thanks


---

## Re: G-Channel_Trend_Detection_Strategy

**Apprentice** · Sun Mar 23, 2025 12:12 pm

We have added your request to the development list.
Development reference 225


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Mon Mar 24, 2025 6:28 am

Also can the G-channel have a quarter line like the donchian alert indicator ie

Parameters (1, "Upper Outer Line");
	Parameters (2, "Upper Inner Line");
	Parameters (3, "Central Line");
	Parameters (4, "Lower Inner Line");
	Parameters (5, "Lower Outer Line");

The the open trade can be selected based upon which line is crossed and the exit trade is defined by which line it crosses

Also a user defined max number of trades in each direction


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Thu Mar 27, 2025 6:37 am

As well as whether the price crosses these 5 lines, can it also enter and exit the trade depending upon whether the line is increasing or decreasing.

Ie only buy enter the top line if its increasing in value

vice versa for bottom line


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Mon Mar 31, 2025 9:42 am

Also would it be possible to include the option of adding supertrend including a choice of timeframe as well.


---

## Re: G-Channel_Trend_Detection_Strategy

**Ariel19** · Mon Apr 28, 2025 11:13 pm

> **tuhadfe wrote:**
> Also can the G-channel have a quarter line like the donchian alert indicator ie
>
> Parameters (1, "Upper Outer Line");
> Parameters (2, "Upper Inner Line");
> Parameters (3, "Central Line");
> Parameters (4, "Lower Inner Line");
> Parameters (5, "Lower Outer Line");
>
> The the open trade can be selected based upon which line is crossed and the exit trade is defined by which line it crosses
> [Crazy Cattle 3D](https://pokerogue.io/crazy-cattle-3d)
> Also a user defined max number of trades in each direction

Would it be possible to add a quarter-line feature to the G-channel, similar to the Donchian Alert Indicator, and also allow users to define the maximum number of trades per direction based on which line (outer, inner, or central) is crossed for entries and exits?


---

## Re: G-Channel_Trend_Detection_Strategy

**Apprentice** · Tue Apr 29, 2025 7:13 am

We have added your request to the development list.
Development reference 288


---

## Re: G-Channel_Trend_Detection_Strategy

**Apprentice** · Thu Jun 05, 2025 7:25 am

![EURUSD m5 (06-05-2025 1427).png](images/159475/EURUSD%20m5%20%2806-05-2025%201427%29.png)



 [G-Channel_Trend_Detection_Strategy.lua](files/159475/G-Channel_Trend_Detection_Strategy.lua)

Try this version.


---

## Re: G-Channel_Trend_Detection_Strategy

**Apprentice** · Thu Jun 05, 2025 2:39 pm

Task 288

> Would it be possible to add a quarter-line feature to the G-channel, similar to the Donchian Alert Indicator, and also allow users to define the maximum number of trades per direction based on which line (outer, inner, or central) is crossed for entries and exits?

 [G-Channel_Trend_Detection.lua](files/159502/G-Channel_Trend_Detection.lua)


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Thu Oct 09, 2025 4:40 pm

Hi

Thanks for this however this doesnt appear to work on Timeframes less than H1....when backtested it works fine but in live, the G-channel data comes through as zero each time.

Test fine
Live not fine

It appears only timeframes over H1 work, I would like to use this on timeframes m1, m5, m15 etc

Thanks


---

## Re: G-Channel_Trend_Detection_Strategy

**Apprentice** · Sun Oct 12, 2025 2:23 am

We have added your request to the development list.
Development reference 653


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Mon Oct 13, 2025 12:45 pm

Hi

Yes I have checked this repeatedly backtesting this works for 15min and below but in live it simply doesnt work.

Is there any reason for this just not to work on lower timeframes?


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Tue Oct 14, 2025 5:16 pm

**


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Thu Oct 16, 2025 4:34 pm

Hi

would it be possible to implement a Shift function on this to shift all the lines etc in pips or percentages.

Just like shift has been implemented on other indicators.

Thanks in advance


---

## Re: G-Channel_Trend_Detection_Strategy

**tuhadfe** · Tue Oct 21, 2025 5:44 pm

Hi

My apologies the G-channel strategy still doesnt work on lower timeframes in live m1, m5 etc.

I thought I spotted a problem with my config but I was wrong.

Please can this be fixed in the lower timeframes

Thanks in advance
