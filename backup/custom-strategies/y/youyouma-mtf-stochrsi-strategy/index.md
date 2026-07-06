# YOUYOUMA MTF StochRSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=74303  
> Forum: 31 · Topic 74303 · 7 post(s)


---

## YOUYOUMA MTF StochRSI Strategy

**Apprentice** · Mon Oct 30, 2023 10:19 am

![EURUSD m15 (10-30-2023 1616).png](images/153126/EURUSD%20m15%20%2810-30-2023%201616%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&t=74173](https://fxcodebase.com/code/viewtopic.php?f=27&t=74173)

 [YOUYOUMA MTF StochRSI Strategy.lua](files/153126/YOUYOUMA%20MTF%20StochRSI%20Strategy.lua)


---

## Re: YOUYOUMA MTF StochRSI Strategy

**YOUYOUMA** · Mon Oct 30, 2023 1:37 pm

Thank you for the work. I've just tested it but the strategy doesn't respect, for the position taking the oversold and overbuy levels.....

Kisssss


---

## Re: YOUYOUMA MTF StochRSI Strategy

**Apprentice** · Sat Nov 04, 2023 10:53 am

We have added your request to the development list.
Development reference 989


---

## Re: YOUYOUMA MTF StochRSI Strategy

**Apprentice** · Sun Nov 05, 2023 10:00 am

Line 579
Indicator[tostring(1*100 + 10)].K[period1] < OS
Line 596
 Indicator[tostring(1*100 + 10)].K[ period1] > OB


---

## Re: YOUYOUMA MTF StochRSI Strategy

**YOUYOUMA** · Sun Nov 05, 2023 1:23 pm

Hello Chef! There's another problem, the exit specific in live doesn't work: index out in range line 463. Thank you again. Kisses from France


---

## Re: YOUYOUMA MTF StochRSI Strategy

**YOUYOUMA** · Sun Nov 05, 2023 1:47 pm

I looked at this post to adapt to the YouYouma Strategy but I don't understand I'm not good enough....

[https://fxcodebase.com/code/viewtopic.p ... ve#p100907](https://fxcodebase.com/code/viewtopic.php?f=28&t=62305&p=100907&hilit=mtf+live#p100907)


---

## Re: YOUYOUMA MTF StochRSI Strategy

**Apprentice** · Fri Nov 17, 2023 4:55 am

[CORRECTION_YOUYOUMA_MTF_StochRSI_Strategy.lua](files/153287/CORRECTION_YOUYOUMA_MTF_StochRSI_Strategy.lua)

Try this version.
