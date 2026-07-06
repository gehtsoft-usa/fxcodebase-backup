# CFG_MO Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=15522  
> Forum: 31 · Topic 15522 · 6 post(s)


---

## CFG_MO Strategy

**Apprentice** · Tue Apr 03, 2012 1:45 am

![CFG_MO Strategy.png](images/29248/CFG_MO%20Strategy.png)



The user can choose
which cross, will be used for Entry / Exit signals.
There are three combinations.
MO / SM2, MO / SM3 or SM2 / SM3

1. Algorithm
Open Long
sm 2> sm 3 and sm3 > buy level and mo cross over sm2
Open Short
 sm 2 < sm3 and sm3 < sell level and mo cross under sm2

 [CFG_MO Strategy.lua](files/29248/CFG_MO%20Strategy.lua)

Please install cfg_mo.bin in order to use this strategy.
[viewtopic.php?f=17&t=3007&p=21982#p21982](https://fxcodebase.com/code/viewtopic.php?f=17&t=3007&p=21982#p21982)

The Strategy was revised and updated on December 09, 2018.


---

## Re: CFG_MO Strategy

**Pullmann** · Tue Aug 28, 2012 3:07 pm

Your CFG MO Strategy does very well.Great work!

Would it be possible to modify or add these features:

-Open an position if MO has a certain value that can be chosen from a dropdown-menu

for example: if MO=115 open sell-position and close position if MO=15


---

## Re: CFG_MO Strategy

**Apprentice** · Wed Aug 29, 2012 1:05 am

Your request is added to the development list.


---

## Re: CFG_MO Strategy

**Apprentice** · Mon Dec 05, 2016 10:11 am

Bump up.


---

## Re: CFG_MO Strategy

**fxlion** · Tue Dec 06, 2016 9:17 am

can you add one more option to this stategy

buy level: 50
sell level:50

buy; sm 2> sm 3 and sm3 > buy level and mo cross over sm2
sell: sm 2 < sm3 and sm3 < sell level and mo cross under sm2


---

## Re: CFG_MO Strategy

**Apprentice** · Wed Dec 07, 2016 3:29 am

Added.
