# HA Extreme TMA Line Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=62731  
> Forum: 31 · Topic 62731 · 22 post(s)


---

## HA Extreme TMA Line Strategy

**Apprentice** · Mon Sep 28, 2015 3:07 am

![HA Extreme TMA Line Strategy.png](images/102563/HA%20Extreme%20TMA%20Line%20Strategy.png)



Based on HA Extreme TMA Line with Alert.
[viewtopic.php?f=17&t=62724](https://fxcodebase.com/code/viewtopic.php?f=17&t=62724)
Alert will be given if HA trend changes occur outside TMA Line band.
Open Long if change occurs below bottom line.
Open Short if change occurs above top line.
Strategy results will reflect repaint nature off Extreme TMA Line.

 [HA Extreme TMA Line Strategy.lua](files/102563/HA%20Extreme%20TMA%20Line%20Strategy.lua)

Extreme_TMA_Line can be found here.
[viewtopic.php?f=17&t=59406](https://fxcodebase.com/code/viewtopic.php?f=17&t=59406)

MT4/MQ4 version
[viewtopic.php?f=38&t=70004](https://fxcodebase.com/code/viewtopic.php?f=38&t=70004)


---

## Re: HA Extreme TMA Line Strategy

**Rudolf** · Mon Sep 28, 2015 8:27 am

THANK YOU APPRENTICE !!!!!


---

## Re: HA Extreme TMA Line Strategy

**JOKER83** · Wed Mar 30, 2016 8:41 am

HI
CAN YOU MAKE MTF STRATEGY
TWO TIME FRAMES
ALL TIME FRAMES MAKE TRADES OPEN

PARAMETERS

ONE
TIME FRAME ,,,,,
CLOSE TRADE -YES/NO

TWO
TIME FRAME ,,,,,,
CLOSE TRADE -YES/NO


---

## Re: HA Extreme TMA Line Strategy

**JOKER83** · Tue Apr 05, 2016 5:14 pm

HALLO Apprentice
CAN YOU MAKE A STRATEGY WITH STOCHASTIC

HA Extreme TMA Line Strategy BUY
STOCHASTIC MAKE TRADES BUY
HA Extreme TMA Line Strategy SELL SIGNAL CLOSE TRADES

HA Extreme TMA Line Strategy SELL
STOCHASTIC MAKE TRADES SELL
HA Extreme TMA Line Strategy BUY SIGNAL CLOSE TRADES

THANKS


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Wed Apr 06, 2016 11:53 am

I really have a hard time to understand your requests.

> STOCHASTIC MAKE TRADES BUY

STOCHASTIC K/D cross?
or
STOCHASTIC K/ 50 Line cross?

> HA Extreme TMA Line Strategy SELL SIGNAL CLOSE TRADES

HA Extreme TMA Line /Close Cross?
or
HA Extreme TMA Line Color Change?


---

## Re: HA Extreme TMA Line Strategy

**JOKER83** · Wed Apr 06, 2016 5:38 pm

STOCHASTIC MAKE TRADES KAUFEN

STOCHASTIC K/D cross
and
STOCHASTIC K/D cross overbought / Oversould

HA Extreme TMA Line Strategy SELL SIGNAL CLOSE TRADES

HA Extreme TMA Line Color Change


---

## Re: HA Extreme TMA Line Strategy

**rdthomas** · Sun May 22, 2016 9:33 am

Can the strategy be updated to buy when the extreme tma line is green and sell when the extreme tma line is red?


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Thu Jun 02, 2016 2:59 am

Can you specify complete strategy logic.


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Fri Dec 16, 2016 7:17 am

Strategy was revised and updated.


---

## Re: HA Extreme TMA Line Strategy

**efh123** · Fri Dec 16, 2016 1:50 pm

hello there,

have tradestation 2.0 & dev.
but the strategy isnt shown.

with the indicator i get at every candle a bug an the indicator disappear.

can you please fix it?

seams to be a good one.

best regards

lus


---

## Re: HA Extreme TMA Line Strategy

**efh123** · Fri Dec 16, 2016 1:56 pm

edit: without alert it works


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Fri Dec 16, 2016 7:33 pm

Have test it and Backtester and in simulator mode,
everything is OK.
Can you provide more information.


---

## Re: HA Extreme TMA Line Strategy

**foxbat** · Mon Mar 20, 2017 2:40 pm

This strategy opens trades on forex, but does not open trades on CFDs like UK100.
It was suggested to me that this is because CFDs are traded in contracts, but the strategy is only set to trade in lots.
Please let me know if this strategy could incorporate trading on CFDs too.
Thank you


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Tue Mar 21, 2017 4:00 am

What method of testing, the settings you used?

 

![USOil H1 (03-21-2017 0757).png](images/111596/USOil%20H1%20%2803-21-2017%200757%29.png)



 

![UK100 H1 (03-21-2017 0805).png](images/111596/UK100%20H1%20%2803-21-2017%200805%29.png)



Tested in Backtester, we have similar results for simulator also.


---

## Re: HA Extreme TMA Line Strategy

**foxbat** · Tue Mar 21, 2017 9:15 am

I have attached the settings that I used for this strategy.
I must point out that that I was having trouble opening these trades on a live account


---

## Re: HA Extreme TMA Line Strategy

**billkokobill** · Mon Apr 19, 2021 5:54 am

dear apprentice
can you please add the parameter as folows?
1.when the price crosses down the UPPER LINE , a sell position open.
 when the price crosses up the lower line, a buy position open.
2. close opossite
3. multiple positions

thanks in advance


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Tue Apr 20, 2021 3:50 pm

Your request is added to the development list.
Development reference 386.


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Fri Apr 23, 2021 3:46 am

[HA_Extreme_TMA_Line_Simple_Strategy.lua](files/141676/HA_Extreme_TMA_Line_Simple_Strategy.lua)

Try this version.


---

## Re: HA Extreme TMA Line Strategy

**billkokobill** · Mon Apr 26, 2021 12:50 am

dear appremtice.
as you can see in the photo in the attachment file, i have marked in the red circle that the strategy dont open new positions.
thanks


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Mon Apr 26, 2021 2:43 am

Your request is added to the development list.
Development reference 414.


---

## Re: HA Extreme TMA Line Strategy

**Apprentice** · Mon May 03, 2021 10:59 am

With this version.

 [HA_Extreme_TMA_Line_Simple_Strategy.lua](files/141856/HA_Extreme_TMA_Line_Simple_Strategy.lua)

Turn on the "Write log" parameter. The strategy will print every decision into the log which you can open in Excel. It'll contain the explanation why to choose not to open the position in this place,


---

## Re: HA Extreme TMA Line Strategy

**billkokobill** · Fri Jul 09, 2021 2:38 am

DEAR APPRENICE.
ANY NEWS ABOUT THE MODIFICATION OF THE STRATEGY?
THANKS
