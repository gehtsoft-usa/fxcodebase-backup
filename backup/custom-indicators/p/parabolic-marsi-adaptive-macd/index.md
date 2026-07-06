# Parabolic_marsi_adaptive_MACD

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66031  
> Forum: 17 · Topic 66031 · 11 post(s)


---

## Parabolic_marsi_adaptive_MACD

**Apprentice** · Wed May 02, 2018 5:48 am

![EURNZD m5 (05-02-2018 1048).png](images/118964/EURNZD%20m5%20%2805-02-2018%201048%29.png)



Based on the request.
[viewtopic.php?f=38&t=65962](https://fxcodebase.com/code/viewtopic.php?f=38&t=65962)

 [Parabolic_marsi_adaptive_MACD.lua](files/118964/Parabolic_marsi_adaptive_MACD.lua)

Averages indicator is available here.
([viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)).


---

## Re: Parabolic_marsi_adaptive_MACD

**bartwas1** · Tue Sep 03, 2019 3:46 am

Hello Apprentice

Is it possible to add alarms to this indicator? Conditions for the alarms would be:
UPTREND
1. parabolic SAR goes up
2. MACD crosses above zero
DOWNTREND
1. parabolic SAR goes down
2. MACD crosses below zero
These two need to be in alignment for the alarm to sound. I mean alarm needs to go off as soon as both indicating the same direction.
NO alarms, for example if parabolic SAR is down trending, but MACD crosses above zero or in any other conditions where parabolic SAR and MACD aren't aligned the way indicated for the uptrend and downtrend conditions.

Kind regards
Bart


---

## Re: Parabolic_marsi_adaptive_MACD

**Apprentice** · Thu Sep 05, 2019 5:28 am

Your request is added to the development list.
Development reference 37.


---

## Re: Parabolic_marsi_adaptive_MACD

**mulligan** · Fri Sep 06, 2019 10:07 pm

I see an alert has been requested for the SAR change and MACD zero cross. I was wanting an alert for the SAR direction change only. Can the 2 be separated in the alert with on/off for the MACD. Or a simple separate alert for the SAR if easier.

Thanks as always


---

## Re: Parabolic_marsi_adaptive_MACD

**Apprentice** · Sat Sep 07, 2019 5:31 am

Try this SAR only alerts.
[viewtopic.php?f=17&t=60311&p=103644](https://fxcodebase.com/code/viewtopic.php?f=17&t=60311&p=103644)
[viewtopic.php?f=17&t=65667](https://fxcodebase.com/code/viewtopic.php?f=17&t=65667)
[viewtopic.php?f=17&t=64429](https://fxcodebase.com/code/viewtopic.php?f=17&t=64429)


---

## Re: Parabolic_marsi_adaptive_MACD

**Apprentice** · Mon Sep 09, 2019 4:03 am

Based on request 37.

 [Parabolic_marsi_adaptive_MACD.lua](files/128503/Parabolic_marsi_adaptive_MACD.lua)


---

## Re: Parabolic_marsi_adaptive_MACD

**mulligan** · Mon Sep 09, 2019 9:34 am

Thank you for the references to SAR with alerts. I should have been more clear. Rather than SAR based on price, the SAR on this indicator has a different data source. It seems to be the signal line. I am requesting a Parabolic_marsi_adaptive_MACD with alert based on the up/down color change of the SAR in the indicator.

Thanks very much


---

## Re: Parabolic_marsi_adaptive_MACD

**bartwas1** · Tue Sep 10, 2019 6:25 am

Hi Apprentice

I've tested this indicator with alarms on GBPUSD 15m, 30m and 5m. Thanks for your work.
Vertical lines was a good idea, I don't know about arrows they look like fractals and on my chart are obscured by fractal indicator - I prefer vertical lines, because they are clearly visible.

Unfortunately alarm sometimes doesn't trigger when both conditions are met (SAR direction and MACD direction becoming the same - upwards or downwards).
I don't get alarms either when for example MACD is below zero and SAR is rising and then falls and changes direction - and SAR and MACD are aligned again (no alarm in that case).
Mine request was about alarms that need to happen as soon as SAR and MACD are in alignment. I am sorry if I wasn't clear in my request.

Kind regards and thanks for your work on indicators.
Bart


---

## Re: Parabolic_marsi_adaptive_MACD

**Apprentice** · Tue Sep 10, 2019 7:48 am

Your request is added to the development list.
Development reference 53.


---

## Re: Parabolic_marsi_adaptive_MACD

**Apprentice** · Wed Sep 11, 2019 6:12 am

[Parabolic_marsi_adaptive_MACD.lua](files/128576/Parabolic_marsi_adaptive_MACD.lua)

Try this version.


---

## Re: Parabolic_marsi_adaptive_MACD

**bartwas1** · Wed Sep 11, 2019 6:26 am

Hi Apprentice

Thanks. Now it seems to be perfect.

Kind regards
B.
