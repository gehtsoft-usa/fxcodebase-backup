# GAP Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=73600  
> Forum: 31 · Topic 73600 · 5 post(s)


---

## GAP Strategy

**Apprentice** · Fri Apr 14, 2023 5:56 am

![US30 D1 (04-14-2023 1254).png](images/150417/US30%20D1%20%2804-14-2023%201254%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&p=150395](https://fxcodebase.com/code/viewtopic.php?f=27&p=150395)

Gaps are sharp breaks in price with no trading occurring in between.
In forex they mostly happen on weekends since the Forex market is open 24 hours a day,
seven days a week, and only shuts on weekends.

Open Long
If the price Gup up is greater than the set minimum in pips.

Vice versa for Short

 [GAP Strategy.lua](files/150417/GAP%20Strategy.lua)


---

## Re: GAP Strategy

**marcoleghorn1972** · Fri Apr 14, 2023 8:23 am

Good afternoon, thanks for your help. I tried to optimize the strategy but no trade opens. I am attaching the screenshot of the settings.
Thank you.


---

## Re: GAP Strategy

**Apprentice** · Wed Apr 19, 2023 5:47 am

Usually, you will find gaps on D1 and greater.


---

## Re: GAP Strategy

**marcoleghorn1972** · Wed Apr 19, 2023 9:41 am

Hi, I ran a test from 01/01/2022 to today on ger30 with time frame D1. The strategy opens only one position in the entire period.


---

## Re: GAP Strategy

**Apprentice** · Sat Apr 22, 2023 12:21 pm

1. Re-download.
2. Try to set "Minimal GAP in pips" to zero.

 

![Snimka zaslona 2023-04-22 191748.png](images/150531/Snimka%20zaslona%202023-04-22%20191748.png)



3. Set "Show Price Gap" to Show
I suspect some of the sources have gaps removed.
