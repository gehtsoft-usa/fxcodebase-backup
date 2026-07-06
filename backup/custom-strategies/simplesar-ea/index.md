# SimpleSAR_EA

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=69115  
> Forum: 31 · Topic 69115 · 26 post(s)


---

## SimpleSAR_EA

**Apprentice** · Tue Nov 12, 2019 5:35 am

![EURUSD m1 (11-12-2019 0942).png](images/129692/EURUSD%20m1%20%2811-12-2019%200942%29.png)



Based on MT4 version.
[viewtopic.php?f=38&p=129440](https://fxcodebase.com/code/viewtopic.php?f=38&p=129440)

 [SimpleSAR_EA.lua](files/129692/SimpleSAR_EA.lua)


---

## Re: SimpleSAR_EA

**fabio70** · Mon May 11, 2020 10:28 am

Dear Apprentice,

Could you please add to this SimpleSAR strategy a START/STOP time for trading with manditory closing time.
Thanks


---

## Re: SimpleSAR_EA

**fabio70** · Tue May 12, 2020 7:55 am

Sorry, I forgot to ask if you could also add a limit function.
Thank you


---

## Re: SimpleSAR_EA

**Apprentice** · Tue May 12, 2020 11:22 am

Your request is added to the development list.
Development reference 1276.


---

## Re: SimpleSAR_EA

**papynou34** · Wed May 13, 2020 4:04 am

Hello Apprentice,
Thanks for your work.
I noticed that the Période information is missing on panel of running stratégy.
It seems, you have to add :
 strategy.parameters:setFlag("timeframe", core.FLAG_PERIODS);

Thanks


---

## Re: SimpleSAR_EA

**papynou34** · Wed May 13, 2020 7:49 am

Hello Apprentice,
It seems there is a bug in the stratégy with mandatory closing time. I did a backtest and
 -If mandatory closing time to False : in this case the strategy just runs one day.
 -if mandatory closing is set to True, i Have the following error message :

C:/Program Files (x86)/Candleworks/FXTS2.test/Strategies/Custom/SimpleSAR_EA.lua:-1: stack overflow


---

## Re: SimpleSAR_EA

**fabio70** · Wed May 13, 2020 7:52 am

Hi Apprentice,
thank you for your work, but I must say that the strategy does not work anymore, even with all the new functions disabled.
The previous version in the backtest give me back a huge number of orders, now it only opens very few orders.
Is there any parameter that should be set differently?
And I have no more the previous version since the new one substituted it.
Thank you


---

## Re: SimpleSAR_EA

**Apprentice** · Wed May 13, 2020 8:52 am

Your request is added to the development list.
Development reference 1287.


---

## Re: SimpleSAR_EA

**Apprentice** · Thu May 14, 2020 4:24 am

[SimpleSAR_EA.lua](files/133930/SimpleSAR_EA.lua)

Try this version.


---

## Re: SimpleSAR_EA

**fabio70** · Thu May 14, 2020 7:39 am

OK, now the strategy works when the new functions are disabled, but when mandatory closing is set to on (I tried two different times) the strategy does not open orders nor in backtest nor in optimization.


---

## Re: SimpleSAR_EA

**Apprentice** · Sat May 16, 2020 4:05 pm

Your request is added to the development list.
Development reference 1306.


---

## Re: SimpleSAR_EA

**bruno2017** · Tue May 19, 2020 9:58 am

Hello
is it possible to calculate the "Sar sep" in atr number and not in pips.
can you add a filter with a moving average
thank you


---

## Re: SimpleSAR_EA

**Apprentice** · Thu May 21, 2020 6:25 am

"Sar step"?
Open Long if price > MA
and Vice versa for Short


---

## Re: SimpleSAR_EA

**bruno2017** · Thu May 21, 2020 6:42 am

> **Apprentice wrote:**
> "Sar step"?
> Open Long if price > MA
> and Vice versa for Short

YES


---

## Re: SimpleSAR_EA

**bruno2017** · Thu May 21, 2020 7:15 am

yes


---

## Re: SimpleSAR_EA

**fabio70** · Fri May 22, 2020 3:50 am

Dear Apprentice,
I recognized that, for the last version of this strategy, mandatory closing only works at 23:59:59, when other times are set the strategy does not work anymore.
Could you please fix this problem?


---

## Re: SimpleSAR_EA

**bruno2017** · Wed Jun 17, 2020 4:44 am

Hello
on the image "SAR sep" is calculated in "pips" could you calculate it in numbers of ATR (ex: 0.5 ATR, 1ATR ect ..)
thank you


---

## Re: SimpleSAR_EA

**Apprentice** · Wed Jun 17, 2020 3:34 pm

Can you please post a request here,
[viewforum.php?f=27](https://fxcodebase.com/code/viewforum.php?f=27)
so we write and test such an indicator?


---

## Re: SimpleSAR_EA

**Avignon** · Wed Aug 12, 2020 4:49 pm

Hello,

Can you create a strategy (buy, sell, alert, TP, SL)?

Thanks.


---

## Re: SimpleSAR_EA

**Apprentice** · Thu Aug 13, 2020 6:17 am

What about SimpleSAR_EA.lua?
Can you define the rules?


---

## Re: SimpleSAR_EA

**Avignon** · Thu Aug 13, 2020 12:53 pm

[viewtopic.php?f=31&t=11912&hilit=sar](http://www.fxcodebase.com/code/viewtopic.php?f=31&t=11912&hilit=sar) for example.


---

## Re: SimpleSAR_EA

**Avignon** · Wed Oct 21, 2020 3:30 pm

Hello,

Do you add signal (email, sound, show alert)?

Thanks.


---

## Re: SimpleSAR_EA

**Apprentice** · Thu Oct 22, 2020 2:00 am

for MT4 version?


---

## Re: SimpleSAR_EA

**Avignon** · Thu Oct 22, 2020 10:08 am

TS2 please.


---

## Re: SimpleSAR_EA

**Apprentice** · Fri Oct 23, 2020 6:04 am

SimpleSAR_EA.lua is the TS2 strategy.


---

## Re: SimpleSAR_EA

**Avignon** · Thu Nov 05, 2020 8:38 am

Suggestions to improve performance?
