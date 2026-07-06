# CDUR

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63626  
> Forum: 17 · Topic 63626 · 14 post(s)


---

## CDUR

**Apprentice** · Sun Jun 26, 2016 4:58 am

![EURUSD D1 (06-26-2016 1126).png](images/106913/EURUSD%20D1%20%2806-26-2016%201126%29.png)



Based on request.
[viewtopic.php?f=27&t=63624](https://fxcodebase.com/code/viewtopic.php?f=27&t=63624)

 [CDUR.lua](files/106913/CDUR.lua)

DEMA is available here.
[viewtopic.php?f=17&t=1052&p=2358&hilit=DEMA#p2358](https://fxcodebase.com/code/viewtopic.php?f=17&t=1052&p=2358&hilit=DEMA#p2358)
CDUR Strategy is available here.
[viewtopic.php?f=31&t=63777](https://fxcodebase.com/code/viewtopic.php?f=31&t=63777)


---

## Re: CDUR

**gregollier** · Tue Jun 28, 2016 3:14 pm

Yeah...
Thank you very much Apprentice;
You are my hero !
C U


---

## Re: CDUR

**panos59** · Wed Jun 29, 2016 9:25 am

att:gregollier
Looks intersting..can you tell us a little bit more about this indicator ? how to use or what to watch out..or do you have a weblink to some information ?


---

## Re: CDUR

**trdheat** · Wed Jun 29, 2016 11:57 am

Apprentice,

When i try to export the data to excel there is a problem with excel, show ''Problems came up in the following areas during load: Table''

Is it possible to fix it?


---

## Re: CDUR

**gregollier** · Tue Jul 05, 2016 7:42 am

Hello,

I can try to tell you anymore about CDUR.
I hope you will understand me because I don't speak English fluently.

This indicator show a long time cycle (CDURUTS) and a short time cycle (CDURUTC).
It works with 2 modes:
1- the both cycles is turning synchronized in the same direction (up or down): It would be a setup.
2- If CDURUTC is turning up (for example) when CDURUTS is on top, it would be bullish.

Moreover, if you can see the CDURUTC getting up (or down) when prices are raging... it could be bearish (or bullish) when CDURUTC will turning down.

I do apologize about my English.
If you want, I can show this using whith charts insteed of my crap language


---

## Re: CDUR

**panos59** · Wed Jul 06, 2016 6:44 am

att:gregollier
Your explanation was just fine ! Thanks ! are you using the indicator for a long time ? any success ? do you have o download link for the prorealtime version of the indicator ?
Thanks !!!!


---

## Re: CDUR

**gregollier** · Fri Jul 08, 2016 2:57 am

Panos59,

I'm using it for a couple of years ! But I lost money because of mental, not technical's problems I think.
Now, I have stopped to lose for I trade FOREX seriously.

I'm developping a system with Ichimoku, volumeprofil and CDUR. I think is the good one. But actually, I do believe in CDUR's power !!!
For being efficient with both CDUR (CDURUTS & CDURUTC so), you have to use it with several timeframes.
You can anticipate a setup on m15 for example, when there is one on m1. If you detect an opportunity on h1 for example and the both CDUR are synchronizing together on m15, it's a realy good indication. Of corse, always with graphic's prices (under resistance or on support).

I give you the prorealtime code next:

rem CDUR UTC

z1=dema[9](close)
z2 =dema[19](close)
e= z1 - z2
z3=dema[6](e)
f=z3
hausse = MAX(0, f - f[1])
baisse = MAX(0, f[1] - f)
mmHausse = WILDERAVERAGE[5](hausse)
mmBaisse = WILDERAVERAGE[5](baisse)

REM En déduit le RS

RSUTC = mmHausse / mmBaisse

REM Et finalement le RSI de la Zero Lag

CDURUTC = 100 - 100 / (1 + RSUTC)

REM CDUR UTS

z1S=dema[45](close)
z2S =dema[95](close)
eS= z1S - z2S
z3S=dema[6](eS)
fS=z3S
hausseS = MAX(0, fS - fS[1])
baisseS = MAX(0, fS[1] - fS)
mmHausse = WILDERAVERAGE[8](hausseS)
mmBaisse = WILDERAVERAGE[8](baisseS)
RSUTS = mmHausse / mmBaisse

CDURUTS = 100 - 100 / (1 + RSUTS)

return CDURUTC as "CDUT UTC", CDURUTS as "CDUR UTS"


---

## Re: CDUR

**panos59** · Mon Jul 11, 2016 7:21 am

Thanks again !!


---

## Re: CDUR

**gregollier** · Thu Aug 11, 2016 10:47 am

Hello,

A friend of mine improve a little the indicator CDUR for a more efficient visuel effect.
It is possible to set specific color when the CDUR is up or down.


---

## Re: CDUR

**mulligan** · Tue Aug 16, 2016 12:50 pm

An alert based on CDUR2 would be very useful. Red red - sell, green green - buy, red green - exit.

Thanks for your consideration


---

## Re: CDUR

**Apprentice** · Wed Aug 17, 2016 2:50 pm

CDUR Strategy is available here.
[viewtopic.php?f=31&t=63777](https://fxcodebase.com/code/viewtopic.php?f=31&t=63777)

mulligan, can you explain your strategy in detail.


---

## Re: CDUR

**mulligan** · Wed Aug 17, 2016 3:15 pm

What I was looking for was based on the CDUR2 posted by gregollier. The indicator has separate up and down colors for both the CDURUTC and CDURUTS. Both lines change from red to green depending on rising or falling. I was looking for a buy signal when both lines are green (rising), a sell signal when both lines are red (falling), and an exit signal when the lines disagree. The alert or strategy is independent of line crossovers. Hope this clarifies the request. My apologies for not being more detailed initially. Your assistance is always appreciated.


---

## Re: CDUR

**Apprentice** · Thu Aug 18, 2016 3:15 am

Try CDUR2 Strategy
[viewtopic.php?f=31&t=63777&p=107672#p107672](https://fxcodebase.com/code/viewtopic.php?f=31&t=63777&p=107672#p107672)


---

## Re: CDUR

**Apprentice** · Mon Aug 27, 2018 5:01 am

The indicator was revised and updated.
