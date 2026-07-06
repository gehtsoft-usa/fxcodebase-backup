# CCI_Flat_Extreme_Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65090  
> Forum: 17 · Topic 65090 · 20 post(s)


---

## CCI_Flat_Extreme_Alert

**Apprentice** · Fri Sep 15, 2017 3:49 pm

![AUDNZD m1 (09-15-2017 2058).png](images/114917/AUDNZD%20m1%20%2809-15-2017%202058%29.png)



Based on the request.
[viewtopic.php?f=27&t=65087](https://fxcodebase.com/code/viewtopic.php?f=27&t=65087)
For overbought scenarios, alert only generated if CCI decreases by 5 or less
For oversold scenarios, alert only generated if CCI increases by 5 or less

 [CCI_Flat_Extreme_Alert.lua](files/114917/CCI_Flat_Extreme_Alert.lua)


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Mon Sep 18, 2017 5:02 am

awesome, many thx Apprentice


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Mon Sep 18, 2017 5:55 am

heads up - It misses certain signals

Looks like if conditions are correct for a signal BUT BOTH start and end values are still above/below the overbought/oversold levels respectively at close then no alert is given. My fault i think as i was not clear in my specification

N.B. CCI line does not have to cross over the OB/OS line for signal to be valid. Even if line stays outside OB/OS lines its still a valid signal (actually more valid)

So it would be good to distinguish between the two types: outer and crossover alerts.

Once the code acknowledges the outer signals, could you add "outside/cross/both" filter option so we can choose to display alerts that are completely in the OB/OS zones, alerts that are crossing OB/OS zone, or to display both types

many thx in advance


---

## Re: CCI_Flat_Extreme_Alert

**Apprentice** · Tue Sep 19, 2017 4:31 am

Your request is added to the development list, Under Id Number 3898
 If someone is interested to do this task, please contact me.


---

## Re: CCI_Flat_Extreme_Alert

**Apprentice** · Wed Sep 27, 2017 4:59 am

can you explain it
alert will be given in we have "Maximum change"
inner will be given if cci < OB and cci > OS
we will have other if cci > OB or cci < OS


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Wed Oct 04, 2017 11:22 am

My apologies Apprentice for the delayed reply.

I will try and clarify:

User specifies CCI OB value (X1) Will be a pos value
User specifies CCI OS value (X2) Will be a neg value
User specifies CCI Maximum Change value (Y)
At any time on the chart, the indicator compares CCI of Current bar (C) with Previous bar (P)

For a OB scenario:
IF P>X1 AND (P-C)<Y THEN DOWN Alert

For a OS scenario:
IF P<X2 AND (C-P)<Y THEN UP Alert
N.B. we use (C-P) because we are dealing with neg values of CCI

To avoid confusion, once CCI has crossed into OB/OS territory, we no longer care about it re-crossing the OB/OS line. Instead we focus on whether delta Y fits the criteria

I hope this clarifies. If not I can post some graphics to illustrate further

many thx


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Wed Oct 04, 2017 11:44 am

The theory behind this indicator is that flat values of CCI indicate that momentum has vanished and this can (at the proper TF and CCI period) alert to a next candle reversal


---

## Re: CCI_Flat_Extreme_Alert

**Apprentice** · Thu Oct 05, 2017 4:23 am

[CCI_Flat_Extreme_Alert.lua](files/115270/CCI_Flat_Extreme_Alert.lua)

Try this version.


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Thu Oct 05, 2017 4:39 am

many thx. I am starting testing


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Thu Oct 05, 2017 5:19 am

Excellent programming. It catches both pos and neg gradient flat tops/bottoms

Many thx indeed apprentice


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Fri Oct 06, 2017 11:24 am

Hi Apprentice, how easy is it to include a Live Alert option?


---

## Re: CCI_Flat_Extreme_Alert

**Apprentice** · Fri Oct 06, 2017 12:24 pm

Execution parameter is already available.
Can you clarify?


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Tue Oct 10, 2017 7:28 am

Nice example of a 5min reversal


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Tue Oct 10, 2017 9:16 am

> **Apprentice wrote:**
> Execution parameter is already available.
> Can you clarify?

My apologies. I am not sure what happened. I must be using an older version. If I look at the code of the one i am using (attached), the Live code lines are there but commented out (not active).

You are right, the current version does have the LIVE option. I notice you have also fixed the direction so only maximums going toward centre zero-line are shown.

However some legitimate alerts are missed by the updated version. See image for example. Can this be looked into, thx


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Tue Oct 10, 2017 9:55 am

I had another look at the current lua again: seems to only recognise alerts where the CCI line is actually crossing the OBOS line


---

## Re: CCI_Flat_Extreme_Alert

**Apprentice** · Wed Oct 11, 2017 3:52 am

For the second version,
alert will be given every time,
we are in OB or OS Zone and the CCI change is smaller than Maximum.

A)
if CCI[period] > OB
and math.abs(CCI[period]-CCI[period-1])<= Maximum

B)
 if CCI[period] < OS
and math.abs(CCI[period]-CCI[period-1])<= Maximum


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Wed Oct 11, 2017 5:02 am

If i look at the code I see 4 instances similar to below:

 if CCI[period] > OB
 **and CCI[period-1] <= OB**
 and math.abs(CCI[period]-CCI[period-1])<= Maximum
 then


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Wed Oct 11, 2017 5:11 am

following on from last post (pressed Submit button early):

We are not concerned with the current CCI value in relation to OB/OS

We only need to know that previous CCI value was above OB (or below OS)
and
That current CCI value fulfils Maximum condition


---

## Re: CCI_Flat_Extreme_Alert

**7510109079** · Fri Oct 13, 2017 5:48 am

ok , dont worry about this. It works alright


---

## Re: CCI_Flat_Extreme_Alert

**Apprentice** · Fri Aug 17, 2018 6:35 am

The Indicator was revised and updated.
