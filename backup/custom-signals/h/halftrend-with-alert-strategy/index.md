# HalfTrend with Alert Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=70747  
> Forum: 29 · Topic 70747 · 24 post(s)


---

## HalfTrend with Alert Strategy

**Apprentice** · Thu Dec 24, 2020 7:07 am

![EURUSD m1 (12-24-2020 1307).png](images/139763/EURUSD%20m1%20%2812-24-2020%201307%29.png)



 [HalfTrend with Alert.lua](files/139763/HalfTrend%20with%20Alert.lua)

 [HalfTrend with Alert Strategy.lua](files/139763/HalfTrend%20with%20Alert%20Strategy.lua)

QQE.lua
[https://fxcodebase.com/code/viewtopic.php?f=17&t=1347](https://fxcodebase.com/code/viewtopic.php?f=17&t=1347)


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Mon Jun 21, 2021 6:41 am

Hi,
I try the HalfTrendwith Alert Strategy but I just get an error message:

C:/Program Files (x86)/Candleworks/FXTS2/Strategies/Custom/HalfTrend with Alert Strategy.lua:40: attempt to index field 'signal' (a nil value)

The HalfTrend with Alert indicator works perfectly, it is just the strategy that will not work.

Can anyone help...?

Thanks...


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Tue Jun 22, 2021 2:40 am

Works for me.
Are you using the original file name for HALFTREND WITH ALERT?


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Tue Jun 22, 2021 2:56 am

Hi

Yes I have not changed the file name.

Halftrend with alert works fine but the strategy that will automatically take buy and sell positions just give me that error message...
Any ideas....?

Thanks


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Fri Jun 25, 2021 5:16 am

Your request is added to the development list.
Development reference 601.


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Wed Jun 30, 2021 2:51 am

Can you make a strategy combining the HalfTrend strategy with a QQE confirmation ?

HalfTrend strategy will show all Buy and Sell alerts on the chart as normal, but will only enter a Buy or Sell position if direction is confirmed by the QQE.

Thank you in advance, I look forward to testing this one out.


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Wed Jun 30, 2021 9:30 am

Can you please provide a link to the QQE indicator, define QQE filter rules?


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Thu Jul 01, 2021 11:48 am

HALFTREND WITH QQE confirmation strategy.

It would work as follows....

Long
The trade is triggered by the HalfTrend but only if the QQE > TS Fast

Short
The trade is triggered by the HalfTrend but only if the QQE < TS Fast

Can you give the option to choose a different Time Frame for the QQE confirmation from the HalfTrend, and the option to use 2 QQE filters with diffrent time frames.

With the (Optional Exit / close position), close on opposite, reverse HalfTrend WITHOUT QQE confirmation, reverse HalfTrend with QQE confirmation, stop orders and limit orders.

The strategy options are nearly the same as "3 MA CROSS STRATEGY WITH QQE FILER" But change 3 MA calculation for HALFTREND calculation.
3 MA CROSS STRATEGY WITH QQE FILER found here: [https://fxcodebase.com/code/viewtopic.p ... 13#p103413](https://fxcodebase.com/code/viewtopic.php?f=31&t=62895&p=103413#p103413)

QQE STRATEGY found here: [https://fxcodebase.com/code/viewtopic.p ... &hilit=qqe](https://fxcodebase.com/code/viewtopic.php?f=31&t=9147&hilit=qqe)

Thank you.


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Fri Jul 02, 2021 6:04 am

Your request is added to the development list.
Development reference 607.


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Tue Jul 06, 2021 3:00 am

You need to reinstall HalfTrend with Alert


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Tue Jul 06, 2021 6:55 am

[HalfTrend_with_QQE_Strategy.lua](files/142701/HalfTrend_with_QQE_Strategy.lua)

Try this version.


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Wed Jul 07, 2021 5:00 am

Hi
Thanks for the strategy,

I re-installed the HALFTREND WITH ALERT from the top of this post (page 1) and installed the HALFTREND WITH QQE strategy.

I ran the strategy but when the entry is triggered I get this error message :

C:/Program Files (x86)/Candleworks/FXTS2/Strategies/Custom/HalfTrend_with_QQE_Strategy.lua:50: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/HalfTrend with Alert.lua (-1, -1) : E19 - nil


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Wed Jul 07, 2021 5:32 am

![CHN50 m1 (07-07-2021 1228).png](images/142725/CHN50%20m1%20%2807-07-2021%201228%29.png)



Um, as you can see, these three work without any problems.

 [HalfTrend_with_QQE_Strategy.lua](files/142725/HalfTrend_with_QQE_Strategy.lua)

 [QQE.lua](files/142725/QQE.lua)

 [HalfTrend with Alert.lua](files/142725/HalfTrend%20with%20Alert.lua)


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Wed Jul 07, 2021 9:28 am

Hi

It's so strange, I have tried un-installing and re-installing the programs but still get the same error message when a entry trade is triggered.
I am trading on a live account, could this be causing the error message ?

Can you make this strategy the same as the "3 MA CROSS STRATEGY WITH QQE FILER" But replace the 3 MA calculation part with the HALFTREND. ( option to choose 2 x QQE filters at different time frames )
Please keep the other options the same, like the option to change HALFTREND "Period" and option to choose different time frames for HALFTREND and each of the 2 QQE.
Trading Parameter options the same with all exit options the same and to include close on opposite with and without QQE.

I hope this is possible as I have been successfully manually trading this system for some time and think it could make a very interesting strategy.

Thanks for your help.


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Wed Jul 07, 2021 10:40 am

Your request is added to the development list.
Development reference 621.


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Thu Jul 08, 2021 11:11 am

I can't find "3 MA CROSS STRATEGY WITH QQE FILER"


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Fri Jul 09, 2021 7:43 am

Your request is added to the development list.
Development reference 628.


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Tue Jul 13, 2021 4:21 am

Hi

Thanks for your work on this, I have tested it on my live account but get this error message when a entry position is taken.

C:/Program Files (x86)/Candleworks/FXTS2/Strategies/Custom/Halftrend_Strategy__with_QQE_Filter_V2.lua:452: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/HalfTrend with Alert.lua (-1, -1) : E19 - nil

I do not understand why I keep getting an error, any ideas..?


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Tue Jul 13, 2021 9:33 am

Your request is added to the development list.
Development reference 641.


---

## Re: HalfTrend with Alert Strategy

**hassas_sa** · Tue Jul 20, 2021 6:06 pm

Dear Mr. Apprentice

could you give me a copy of ( Halftrend_Strategy__with_QQE_Filter_V2.lua ) in Mt4 copy
thank you sir


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Tue Jul 20, 2021 11:42 pm

[Halftrend_Strategy__with_QQE_Filter_V2.lua](files/142890/Halftrend_Strategy__with_QQE_Filter_V2.lua)

Try this version.


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Wed Jul 21, 2021 12:12 am

Your request is added to the development list.
Development reference 665.


---

## Re: HalfTrend with Alert Strategy

**Matt4x** · Fri Jul 23, 2021 4:41 am

Hi,

thanks for your work on this, I've been testing this new version out for the last few days, it does now enter positions automatically but there seems to be a 1 minute delay from when the entry is triggered on the chart to when the entry is actually taken, and couple of other little glitches but I will continue testing with different settings to see if I can resolve them.

Thank you again for all your work..


---

## Re: HalfTrend with Alert Strategy

**Apprentice** · Wed Feb 05, 2025 2:40 pm

TS2 version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=75574](https://fxcodebase.com/code/viewtopic.php?f=38&t=75574)
