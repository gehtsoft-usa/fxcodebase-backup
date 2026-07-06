# Highly adaptable Belkhayate's Center Of Gravity Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=26099  
> Forum: 31 · Topic 26099 · 22 post(s)


---

## Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Fri Nov 16, 2012 7:12 am

![Highly adaptable Belkhayate's Center Of Gravity Strategy.png](images/44807/Highly%20adaptable%20Belkhayates%20Center%20Of%20Gravity%20Strategy.png)



This strategy is primarily designed to give Alert.
Although this strategy have trading functionality, due to the internal works of BCG,
preference to redraw after each period,it is impossible to evaluate its historical performance.
In any case, strategy will trade / alert you if Price cross one of selected BCG lines.

 [Highly adaptable Belkhayate's Center Of Gravity Strategy.lua](files/44807/Highly%20adaptable%20Belkhayates%20Center%20Of%20Gravity%20Strategy.lua)

 [Bigger time frame Highly adaptable Belkhayates Center Of Gravity Strategy.lua](files/44807/Bigger%20time%20frame%20Highly%20adaptable%20Belkhayates%20Center%20Of%20Gravity%20Strategy.lua)

You can find Belkhayate's Center Of Gravity and install here.
[viewtopic.php?f=17&t=706](https://fxcodebase.com/code/viewtopic.php?f=17&t=706)
MT4/MQ4 version.
[viewtopic.php?f=38&t=68930](https://fxcodebase.com/code/viewtopic.php?f=38&t=68930)


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**NidalTrader** · Thu Jan 31, 2013 7:08 pm

Hello there,

 I was wondering if it's possible that the strategy trades (or alerts) when the H4 bar crosses a line during it's construction (it's make) and not when close price is over (L2,3,4) or under(L5,6,7)

 In ExtUpdate function, there are conditions (core.crossesOver/core.crossesUnder) based on "Source.close". Is it possible to change this to make it dynamic and not based on Source.close Source.open ... so the strategy can trade (alert) during the bar building.

 Also I am currently trying to mix trading strategy based of both BELCOG and BELTIME, but quite complicated. Seems like fuzzy logic some times .

Thanks a lot for all what you are doing, it's really amazing this fxcodebase


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Fri Feb 01, 2013 6:38 am

It is possible, not so simple, the strategy should be written from scratch.
Check is done ​​after their tick.


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**takisd** · Wed Dec 04, 2013 1:55 am

Excellent work! Keep it up.

I wondering if it is possible to add an option to trade only in the direction of the trend. For example sell signals/trades only if L lines are pointing down and buy signals/trades only if L lines are pointing up.


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**kankatrader** · Fri May 30, 2014 10:56 am

Hi,

it is possible that this Strategy works in combination with Indicator Level_ZZ_Semafor.lua.
find here [http://fxcodebase.com/code/viewtopic.php?f=17&t=954&hilit=3_Level_ZZ_Semafor+strategy#p1753](https://fxcodebase.com/code/viewtopic.php?f=17&t=954&hilit=3_Level_ZZ_Semafor+strategy#p1753)
Strategy should trade / if Price cross one of selected BCG lines and third level of ZZ Semafor displayed.

Best Reagrds


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Sat May 31, 2014 7:55 am

Your request is added to the developmental list.


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**MC. Trend Trader** · Sat Dec 03, 2016 9:19 pm

Hi,

Can you add Bigger time frame Version to this Strategy?

Thanks in advance


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Sun Dec 04, 2016 5:47 am

Bigger time frame Highly adaptable Belkhayates Center Of Gravity Strategy.lua added.


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**MC. Trend Trader** · Sun Dec 04, 2016 7:21 pm

Hi,

Many thanks for the strategy
Can you please change this strategy in Bigger Time frame strategy. It has the new template.
Which I found here on the site.
It has additional functions

Best Regards


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Mon Dec 05, 2016 4:48 am

Your request is added to the development list, Under Id Number 3686
 If someone is interested to do this task, please contact me.


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**MC. Trend Trader** · Tue Oct 23, 2018 2:00 pm

Hello
Can you include ZZ_SEMAFOR indicator as confirmation?

For example, candle cross under L1 and ZZ_SEMAFOR
Depth 34
Deviation 21
Backstep 12
Signal is given and Sell

or Candle crossover L7 and ZZ_SEMAFOR
Depth 34
Deviation 21
Backstep 12
Signal is given and Buy

Best regards


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Fri Oct 26, 2018 4:59 am

Your request is added to the development list under Id Number 4279


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Sat Oct 27, 2018 5:10 am

Try this version.

 [Highly adaptable Belkhayate's Center Of Gravity Strategy.MCTrendTrader.lua](files/121786/Highly%20adaptable%20Belkhayates%20Center%20Of%20Gravity%20Strategy.MCTrendTrader.lua)


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**MC. Trend Trader** · Thu Nov 01, 2018 9:05 pm

Hello,
Thanks for the strategy

the following change is desired.

For example:

Currently Semafor Depth: 34 Deviation: 21 and Backstep: 21 is displayed above the lines L2, L3 and L4.
Confirmation only for these lines.

or

Currently Semafor is displayed below lines L5, L6 and L7.
Confirmation only for these lines.

Best regards


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Sat Nov 03, 2018 5:03 am

Your request is added to the development list under Id Number 4295


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Sun Nov 04, 2018 9:55 am

We are not sure what you mean. The confirmation could be turned on/off of each line individually.
Can you provide more info?


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**MC. Trend Trader** · Sun Nov 04, 2018 12:51 pm

I mean the following

used indicator 3_Level_ZZ_Semafor.lua.

If the label of the 3rd zigzag (orange color) is displayed above the market price and lines L2, L3 and L4.
Confirmation only for these lines.

If the label of the 3rd zigzag (orange color) is displayed below the market price and lines L5, L6 and L7.
Confirmation only for these lines.

For smaller timeframes and very fast price movements, the 3-ZiG-Zag label appears above the market price, but is below the L5, L6 and L7.

best regards


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Tue Nov 06, 2018 7:05 am

Something like this?

 [Highly adaptable Belkhayate's Center Of Gravity Strategy.MCTrendTrader.lua](files/121978/Highly%20adaptable%20Belkhayates%20Center%20Of%20Gravity%20Strategy.MCTrendTrader.lua)


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**MC. Trend Trader** · Tue Nov 06, 2018 3:24 pm

Thank you very much for the strategy.
it's exactly how I wanted it


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**MC. Trend Trader** · Thu Nov 08, 2018 2:22 pm

Hello,
The last strategy is correct, but the selector should be like the first strategy as shown on the picture.

Best regards


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Sun Nov 11, 2018 5:48 am

Your request is added to the development list under Id Number 4310


---

## Re: Highly adaptable Belkhayate's Center Of Gravity Strategy

**Apprentice** · Tue Nov 13, 2018 7:13 am

[Highly adaptable Belkhayates Center Of Gravity Strategy.MCTrendTrader.lua](files/122086/Highly%20adaptable%20Belkhayates%20Center%20Of%20Gravity%20Strategy.MCTrendTrader.lua)

Try this version.
