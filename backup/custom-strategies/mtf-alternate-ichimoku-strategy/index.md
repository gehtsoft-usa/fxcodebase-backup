# MTF Alternate Ichimoku Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=25883  
> Forum: 31 · Topic 25883 · 11 post(s)


---

## MTF Alternate Ichimoku Strategy

**Apprentice** · Tue Nov 13, 2012 7:32 am

![MTF Alternate Ichimoku Strategy.png](images/44415/MTF%20Alternate%20Ichimoku%20Strategy.png)



BUY:

1. SA> SB IN M15, H1,H4,D1
2. PRICE > SA IN H1,H4,D1
3. PRICE CROSS OVER SA IN M15

SELL :
1. SA< SB IN M15,H1,H4,D1
2.PRICE< SA IN H1,H4,D1
3. PRICE CROSS UNDER SA IN M15

EXIT (Optinal)
Exit Long
Price < SA (for selected TF)

Exit Short
Price > SA (for selected TF)

Alternate Ichimoku can be found here
[viewtopic.php?f=17&t=627&p=1115&hilit=C_ICH_AL1#p1115](https://fxcodebase.com/code/viewtopic.php?f=17&t=627&p=1115&hilit=C_ICH_AL1#p1115)

 [MTF Alternate Ichimoku Strategy.lua](files/44415/MTF%20Alternate%20Ichimoku%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: MTF Alternate Ichimoku Strategy

**cash4u** · Tue Nov 13, 2012 9:34 pm

hi,

this does not make even a single trade.
i have used m15 and d1 for control time frame.
is there any fault.


---

## Re: MTF Alternate Ichimoku Strategy

**newton** · Wed Nov 14, 2012 3:48 am

can you create alterante ichimoku strategy on single time frame only.

buy: sa>sb and price cross over sa

sell: sa< sb and price cross under sa


---

## Re: MTF Alternate Ichimoku Strategy

**Apprentice** · Wed Nov 14, 2012 5:52 am

![Alternate Ichimoku Strategy.png](images/44529/Alternate%20Ichimoku%20Strategy.png)



Single time frame version.

buy
sa>sb
price cross over sa

sell
 sa< sb
price cross under sa

Exit Optinal

Exit Long
Close < SA
Exit Short
Close > SA

 [Alternate Ichimoku Strategy.lua](files/44529/Alternate%20Ichimoku%20Strategy.lua)


---

## Re: MTF Alternate Ichimoku Strategy

**newton** · Wed Nov 14, 2012 6:52 am

Thanks.


---

## Re: MTF Alternate Ichimoku Strategy

**sartas** · Tue Apr 09, 2013 5:55 pm

any probleme in the lua I corrige them file attach


---

## Re: MTF Alternate Ichimoku Strategy

**transformer** · Wed Apr 10, 2013 8:02 am

[back test.pdf](files/58560/back%20test.pdf)

Mtf alternate ischimoku strategy not working. i have attached back test result.


---

## Re: MTF Alternate Ichimoku Strategy

**newton** · Wed Apr 10, 2013 7:17 pm

HI,

CAN YOU CREATE MTF ALTERNATE ICHIMOKU STRATEGY WITH OUT ON/OFF OPTION FOR EACH TIME FRAME.


---

## Re: MTF Alternate Ichimoku Strategy

**Apprentice** · Fri Apr 12, 2013 4:35 am

Your request is added to the development list.


---

## Re: MTF Alternate Ichimoku Strategy

**lancelune** · Fri Jan 22, 2016 10:59 am

Hello,
1) the indicator C_ICH_AL1 doesn't exit. there is only C_ICH_AL and a version made by apprentice.
I have rename in the code to use C_ICH_AL.
2)comment without interest : it s realy strange to have 5 stream and the first is 0.
In the concept of lua like for array the first is 1.


---

## Re: MTF Alternate Ichimoku Strategy

**Apprentice** · Wed Dec 14, 2016 5:01 am

Strategy was revised and updated.
