# continous trading

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=69719  
> Forum: 31 · Topic 69719 · 46 post(s)


---

## continous trading

**Apprentice** · Thu Apr 23, 2020 4:40 am

[continous trading.lua](files/133101/continous%20trading.lua)

Based on request.
[viewtopic.php?f=27&t=69706](https://fxcodebase.com/code/viewtopic.php?f=27&t=69706)

MT4/MQ4 version.
[viewtopic.php?f=38&t=69893](https://fxcodebase.com/code/viewtopic.php?f=38&t=69893)


---

## Re: continous trading

**chai88888** · Thu Apr 23, 2020 7:47 am

there something wrong with the lot sizing increasing.

it increases in a way of 1,2,2,4,4,8

thanks


---

## Re: continous trading

**Apprentice** · Fri Apr 24, 2020 1:01 pm

Your request is added to the development list.
Development reference 1130.


---

## Re: continous trading

**Apprentice** · Mon Apr 27, 2020 5:15 am

Try it now.


---

## Re: continous trading

**khairambo** · Sat May 16, 2020 6:15 am

> **Apprentice wrote:**
>
>
> continous trading.lua
>
>
> Based on request.
> [viewtopic.php?f=27&t=69706](https://fxcodebase.com/code/viewtopic.php?f=27&t=69706)

Looks like a good EA, can create MT4 version of this EA


---

## Re: continous trading

**Apprentice** · Sat May 16, 2020 3:59 pm

Your request is added to the development list.
Development reference 1304.


---

## Re: continous trading

**Apprentice** · Thu May 21, 2020 9:12 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=69893](https://fxcodebase.com/code/viewtopic.php?f=38&t=69893)


---

## Re: continous trading

**chai88888** · Wed May 27, 2020 12:28 am

hi there can you add an option to choose to start buy or sell..

custom pip rather than fixed 30 pips

thanks


---

## Re: continous trading

**Apprentice** · Wed May 27, 2020 5:25 am

Your request is added to the development list.
Development reference 1375.


---

## Re: continous trading

**Apprentice** · Thu May 28, 2020 6:37 am

[continous trading.lua](files/134405/continous%20trading.lua)

Try this version.


---

## Re: continous trading

**RENKOTRADER** · Thu May 28, 2020 8:37 am

Sirs,
Would it be possible to have this strategy with a option for either the Martingale increase volume structure or a fixed designated lot size only. Thankyou


---

## Re: continous trading

**Apprentice** · Tue Jun 02, 2020 6:23 am

Your request is added to the development list.
Development reference 1406.


---

## Re: continous trading

**Apprentice** · Mon Jun 08, 2020 5:40 am

[continous trading.lua](files/134665/continous%20trading.lua)

Try this version.


---

## Re: continous trading

**RENKOTRADER** · Fri Jun 26, 2020 8:53 am

Dear Sirs,
I have been testing this strategy and wish to offer a real trading feedback. The strategy seems to function at the right settings correctly, however, your lot multiplicator is totally haywire. I personally do not agree with multiplying lots, using excesssive capital to recuperate an initial minimum loss, which I consider to be bad money management. Therefore I placed the lot multificator to 1.0 (1Lot times 1.0 multiplicator should equal 1 lot traded with no multification). The Following events were noted whilst trading EURSTX50 this morning:
08:09-market order bought 2 lots successful
08:09 entry order sell 2 lots on stop successful
10:08 entry order buy 4 lots on stop successful
10:08 entry order buy 4 lots on stop successful
10:08 entry order buy 4 lots on stop successful
11:24 market order bought 4 lots successful
11:24 market order bought 4 lots successful
11:24 entry order sell 4 lots on stop successful
11:24 entry order sell 4 lots on stop successful
11:24 entry order sell 4 lots on stop successful
I do not understand how all these orders can be placed with a 1.0 miltiplicator, therefore could you please try to fix this problem or alternatively offer me the same startegy without any multiplication.
I thank you in advance for your efforts


---

## Re: continous trading

**Apprentice** · Sun Jun 28, 2020 4:37 am

Your request is added to the development list.
Development reference 1570.


---

## Re: continous trading

**Apprentice** · Mon Jun 29, 2020 8:44 am

[continous trading simple.lua](files/135410/continous%20trading%20simple.lua)

Try this version.


---

## Re: continous trading

**RENKOTRADER** · Tue Jun 30, 2020 4:58 pm

Mario,
Thank you for the simple version of the continuos trading strategy. We are slowly getting there, however, there are still major problems. Once you start the strategy it will generate a market order and an entry order on a stop. If you maintain the strategy overnight it will only remove previous entry orders but will not generate new orders. The rules of continous trading state that the strategy should generate a new continual order in the market direction after the limit has been broken and a counter trend order if the stop has been broken. Your stategy doesn't generate these orders. In deleting the multiplicator it would appear that the continuation has also been removed. All I require is a simple continual trading strategy without any multification factor and based on the KISS trading concept. "KEEP IT SIMPLE AND STUPID" and my trading technique will tahe care of the profits.
Many thanks for your efforts and further assistance.


---

## Re: continous trading

**Apprentice** · Wed Jul 01, 2020 3:34 am

Your request is added to the development list.
Development reference 1601.


---

## Re: continous trading

**Apprentice** · Wed Jul 01, 2020 5:55 am

[continous trading simple v2.lua](files/135505/continous%20trading%20simple%20v2.lua)

Try this version.


---

## Re: continuos trading

**RENKOTRADER** · Sat Jul 11, 2020 4:12 am

I have traded this strategy over the last two weeks continuosly and confirm that the orders are all generated correctly, however I have found a small flaw which I request that you rectify:
Once a limit order is touched the strategy sequence is to close out the existing order, remove the previous reversal entry order, generate a new reversal entry order and then generate a new market order in the same direction. This is exactly what should happen. Once a stop order is touched the strategy requires that the reversal entry order be executed in order to reverse the trading direction, however and due to the strategy sequence, once the existing order has been stopped out the reversal entry order is also removed therefore cannot be ececuted because it no longer exists. The strategy therefore generates a new reversal entry order and market order but in the same trading direction as prevoiusly traded rather than a reversal in the opposite direction. This can be easily rectified by placing the stop order and the reversal entry order at the same price rather than having a one pip difference. This would allow the entry order to be executed, which would reverse the trading direction, and then a new entry order could be generated.
Thanking you in advance for your swift reaction


---

## Re: continous trading

**Apprentice** · Sat Jul 11, 2020 4:09 pm

Your request is added to the development list.
Development reference 1672.


---

## Re: continous trading

**Apprentice** · Mon Jul 13, 2020 8:58 am

[continous trading simple v3.lua](files/135918/continous%20trading%20simple%20v3.lua)

Try this version.


---

## Re: continous trading

**RENKOTRADER** · Tue Jul 14, 2020 12:30 pm

It appears that you have deleted the command to remove entry order after the stop position is touched. Unfortunately this is only half the problem. I will try to give a simple example: The strategy is started with a sell direction selected. If the limit is touched a new sell order is generated. This works perfectly. If the stop is touched we must presume that the market direction is changing therefore we must generate a BUY order, but instead, your strategy automatically regenerates a new SELL order. This could be due to the fact that the strategy is still runnuing with the sell direction selected. It would seem that a specific trend reversal command should be associated with the stop and the direction selection. If this task can be incorporated you will have a very workable strategy which unfortunately is still not the case at this moment. I look forward to version 4.


---

## Re: continous trading

**RENKOTRADER** · Tue Jul 14, 2020 1:05 pm

Upon further reflection and considering that this strategy is simply to stop and continue in the same direction at limit levels and to stop and reverse to the opposite direction at stop levels, therefore why do you need to generate an entry order at all. If your command is to stop and reverse at the stop level even if the trend reverses a second time your new stop level will allow you to reverse back to the original trading direction. It would appear that the entry order is an unnecessary complication.


---

## Re: continous trading

**RENKOTRADER** · Fri Jul 17, 2020 6:00 am

Sirs,
I have tried to give you simple examples to explain the problem with the stop and reverse command, however, I understand that you are programmers and not traders so if your require further information please contact me directly and I will gladly assist you. Thank you


---

## Re: continous trading

**Apprentice** · Sun Jul 19, 2020 6:13 pm

Your request is added to the development list.
Development reference 1740.


---

## Re: continous trading

**Apprentice** · Mon Jul 20, 2020 10:19 am

[continous trading simple v4.lua](files/136127/continous%20trading%20simple%20v4.lua)

Try this version.


---

## Re: continous trading

**RENKOTRADER** · Wed Jul 22, 2020 1:40 pm

After real trade testing of four versions all I can say is CONGRATULATIONS team you have finally made it. We now have a limit order which generates a continuation market order and a stop order which generates a market reversal order. This is all I needed. Well done.
There is a minor change required in respect to the pending entry orders. Unless otherwise mistaken, with this strategy now they seem to be superflous due to the fact that they have no trading function. I manually delete the pending entry orders after the market order execution and this hasn't effected the functionability of the strategy. Therefore, if you would be so kind as to delete the command to generate both pending entry orders and their subsequent removals I think we will have a viable day trading price action strategy.
Thanking you for your efforts


---

## Re: continous trading

**RENKOTRADER** · Mon Aug 03, 2020 11:25 am

The version 4 of this strategy generates an entry order just below the stop position. This entry order was initially programmed to reverse the position after the stop, however, the stop command has now been changed to execute a reversal order autormatically, therefore the entry order has no trading function and is no longer required. At present this entry order also executes a reversal order which multiplies the number of lots traded. This multiplication of lots could be extremely negative therefore I request that this entry order function be deleted from the strategy as soon as possible.

Thankyou in advance


---

## Re: continous trading

**Apprentice** · Fri Aug 07, 2020 4:53 am

Your request is added to the development list.
Development reference 1857.


---

## Re: continous trading

**RENKOTRADER** · Wed Aug 12, 2020 5:35 am

Obviously we still have a problem. There is no difference between version 4 and version 5!!!!

Today I traded the stategy starting with a buy order. This order was regenerated automatically on multiple occasions each time the limit order was activated. This is exactly what should happen. The market trend then changed to the downside. The stop order was acitivated and a new sell order was generated automatically. This is perfect. However, after this order was activared the sell entry order was also activated. this means that we now have two sell orders working independantly. This is wrong because you have now doubed your risk by trading orders rather than one. I asked clearly that the entry order be eliminated from the stategy because it has no longer any real trading function. I can only presume that your developement team have not fully understood my request, therefore, could you please intervene personally to rectify this problem as quickly as possible in order to avoid further avoidable losses.
Thank you for your continued efforts


---

## Re: continous trading

**Apprentice** · Wed Aug 12, 2020 7:38 am

[continous trading simple v6.lua](files/136813/continous%20trading%20simple%20v6.lua)

Try it now.


---

## Re: continous trading

**RENKOTRADER** · Sat Aug 15, 2020 6:57 am

I've been testing the version 6 and the continual limit order generation works like a dream, however, the reversal stop order, although shown in the events log as a succesfully generated bought or sold market order, does not actually execute. which means your reversal order position is not activated. I do not know whether this is a strategy problem or an order execution problem. Could you please look into this for me to find the best solution.

Many thanks


---

## Re: continous trading

**Apprentice** · Mon Aug 17, 2020 3:48 am

Your request is added to the development list.
Development reference 1895.


---

## Re: continous trading

**forextraderaz** · Fri Aug 21, 2020 3:21 pm

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 1895.

When you are finished with the recent changes you are making to the EA can you also update the version for MT4? Thank You


---

## Re: continous trading

**RENKOTRADER** · Mon Aug 24, 2020 6:52 am

After fully testing the version 6 of the strategy, I confirm that this strategy functions correctly. It would appear that the initial teething problems were due to order execution problems rather than strategy problems. Thanking you for your valued assistance.


---

## Re: continous trading

**Apprentice** · Tue Aug 25, 2020 5:48 am

You're welcome.


---

## Re: continous trading

**taipan** · Thu Oct 22, 2020 7:25 pm

> **Apprentice wrote:**
>
>
> continous trading simple v6.lua
>
>
> Try it now.

Hi Mario,

Can you make a version for mq4 & mq5.

Thanks,
taipan


---

## Re: continous trading

**Apprentice** · Fri Oct 23, 2020 6:03 am

Your request is added to the development list.
Development reference 2214.


---

## Re: continous trading

**Apprentice** · Tue Dec 29, 2020 5:42 pm

Try this version.
[viewtopic.php?f=38&t=69893](https://fxcodebase.com/code/viewtopic.php?f=38&t=69893)


---

## Re: continous trading

**shaloiulabcde** · Wed Mar 24, 2021 10:45 am

Can you please add the option for trailing stops by pips
also breakeven stop setup


---

## Re: continous trading

**Apprentice** · Wed Mar 24, 2021 2:59 pm

Your request is added to the development list.
Development reference 310.


---

## Re: continous trading

**Apprentice** · Sat Mar 27, 2021 4:15 pm

[continous trading simple v7.lua](files/141348/continous%20trading%20simple%20v7.lua)

Try this version.


---

## Re: continous trading

**MadMan** · Fri Mar 11, 2022 5:03 am

Hi,

can we have stop/limit based on ATR instead of pips. The same for trailing stop.


---

## Re: continous trading

**Apprentice** · Mon Mar 14, 2022 8:25 am

Your request is added to the development list.
Development reference 163.


---

## Re: continous trading v7

**RENKOTRADER** · Fri May 06, 2022 1:40 pm

Mario
I trade the continous trading strategy version 7, with mean renko associated within grid ATR settings, After numerous testings I conclude that a smaller grid size is more profitable. This requires however a reliable stategy execution. I have experienced this week on numerous occassions that the events lists show a successful execution however the execution was not in effect executed. Is there a way around this flaw to ensure a reliable execution without m presence
