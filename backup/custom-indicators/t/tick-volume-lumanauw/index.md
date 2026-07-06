# Tick_Volume (lumanauw)

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=68993  
> Forum: 17 · Topic 68993 · 5 post(s)


---

## Tick_Volume (lumanauw)

**Apprentice** · Wed Oct 09, 2019 12:47 pm

![EURUSD m1 (10-09-2019 1753).png](images/129063/EURUSD%20m1%20%2810-09-2019%201753%29.png)



Based on request.
[viewtopic.php?f=17&t=61127&p=128914#p128914](https://fxcodebase.com/code/viewtopic.php?f=17&t=61127&p=128914#p128914)

if (ask+bid) /2 > prev((ask+bid) /2) up++, down=prevdown
If (ask+bid) /2< prev((ask+bid) /2) down++, up=prevup

 [Tick_Volume_lumanauw.lua](files/129063/Tick_Volume_lumanauw.lua)


---

## Re: Tick_Volume (lumanauw)

**paulcarissimo** · Thu Oct 10, 2019 1:27 pm

Hi, may I request an MT4 version of this indicator? Thanks.


---

## Re: Tick_Volume (lumanauw)

**Apprentice** · Fri Oct 11, 2019 10:16 am

Your request is added to the development list.
Development reference 183.


---

## Re: Tick_Volume (lumanauw)

**Apprentice** · Mon Oct 14, 2019 5:31 am

MT4 doesn't have tick bid/ask the history.
Will see what we can do.


---

## Re: Tick_Volume (lumanauw)

**Apprentice** · Wed Oct 16, 2019 8:49 am

Something like this?
[viewtopic.php?f=38&t=69019](https://fxcodebase.com/code/viewtopic.php?f=38&t=69019)
