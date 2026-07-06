# Market Sessions

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60738  
> Forum: 17 · Topic 60738 · 11 post(s)


---

## Market Sessions

**Apprentice** · Fri May 30, 2014 2:57 am

![Market Sessions.png](images/94199/Market%20Sessions.png)



The indicator highlights the New York, London, Tokyo and Sidney Trading Sessions.

 [Market Sessions.lua](files/94199/Market%20Sessions.lua)

If u have suggestions for additional Sessions.
Please post Sessions Name, Session Start Time, Session length

Old implementations

Trading Session Hours Highlight
[viewtopic.php?f=17&t=940](https://fxcodebase.com/code/viewtopic.php?f=17&t=940)
Trading Session Hours
[viewtopic.php?f=17&t=1974&hilit=Sessions](https://fxcodebase.com/code/viewtopic.php?f=17&t=1974&hilit=Sessions)

MT4/MQ4 version
[viewtopic.php?f=38&t=64652](https://fxcodebase.com/code/viewtopic.php?f=38&t=64652)

The indicator was revised and updated


---

## Re: Market Sessions

**Apprentice** · Sun Jan 25, 2015 12:27 pm

Bump Up.


---

## Re: Market Sessions

**Nicks123** · Sun Aug 30, 2015 8:08 am

Could this indicator Be Boxes of the sessions high and low? They could be shaded or colored? And a GMT offset switch? Thanks


---

## Re: Market Sessions

**jrichardson83** · Mon Aug 31, 2015 7:05 pm

> **Nicks123 wrote:**
> Could this indicator Be Boxes of the sessions high and low? They could be shaded or colored? And a GMT offset switch? Thanks

Nick, I believe the shaded box variation is implemented in the older version of the sessions indi.


---

## Re: Market Sessions

**Kilgharrah** · Thu Mar 16, 2017 5:46 pm

Hi, I have a strategy that runs one hour after the opening of London, but doing backtesting I realized that there is a period of time when this strategy is not working properly because it does not use the DST (Daylight saving time ), In fact I am pretty sure none of these indicators (Market Sessions.lua, Trading Session Hours Highlight and Trading Session Hours ) properly handle the DST of New York vs. the DST of Europe.
They could check it and tell me if I'm wrong.
Thank you so much


---

## Re: Market Sessions

**PaulEamonn** · Thu Apr 06, 2017 8:51 am

Is there an MT4 version of this indicator? Due to FXCM's shenanigans I have moved my account to Oanda and chosen to use their MT4 charting package.

I have done a search, but can't find anything. If anyone can point me in the right direction I would appreciate it.

Thanks.


---

## Re: Market Sessions

**Apprentice** · Thu Apr 06, 2017 1:26 pm

Unfortunately no.

Your request is added to the development list, Under Id Number 3774
 If someone is interested to do this task, please contact me.


---

## Re: Market Sessions

**PaulEamonn** · Fri Apr 07, 2017 1:55 pm

Thanks Apprentice. I'll watch out for it.


---

## Re: Market Sessions

**barbs666** · Mon Nov 25, 2019 1:28 am

On the 5 min chart, sessions do not adjust to highlight session times.

Also, the times are referenced to what? E.g. in Sydney (-7) etc what is the reference point of your time scale to use -7 or any other time? The accepted method of time calculation should go from GMT (London time) and work from there, otherwise time should be based on Market open on Monday Sydney time.

regards


---

## Re: Market Sessions

**Apprentice** · Wed Nov 27, 2019 6:01 am

Your request is added to the development list.
Development reference 359.


---

## Re: Market Sessions

**Apprentice** · Wed Nov 27, 2019 6:25 am

It based on EST (New York) time.
