# Surefire

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=67358  
> Forum: 31 · Topic 67358 · 20 post(s)


---

## Surefire

**Apprentice** · Sat Feb 16, 2019 4:12 am

Based on request.
[viewtopic.php?f=27&t=67349](https://fxcodebase.com/code/viewtopic.php?f=27&t=67349)

 [surefire.lua](files/123943/surefire.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=70204](https://fxcodebase.com/code/viewtopic.php?f=38&t=70204)


---

## Re: Surefire

**chai88888** · Sat Feb 16, 2019 1:55 pm

thanks apprentice but i tested it at first its ok the lot size 1,3,6 then it goes 13 it shoud be 12 and it dosent have sell limits

thanks


---

## Re: Surefire

**Apprentice** · Mon Feb 18, 2019 5:24 am

The idea is to cover the losses by increasing the lot size. 12 will not cover that (the algorithm takes spread and commissions into account).


---

## Re: Surefire

**chai88888** · Fri Mar 22, 2019 4:23 am

hello

can you make it if the buy limit is hit it will create a buy trade again vice versa

thanks


---

## Re: Surefire

**chai88888** · Tue Jul 09, 2019 8:01 pm

up


---

## Re: Surefire

**Apprentice** · Sun Jul 14, 2019 4:45 am

Your request is added to the development list under Id Number 4782


---

## Re: Surefire

**Apprentice** · Mon Jul 15, 2019 7:51 am

Try this version.

 [surefire.lua](files/127362/surefire.lua)


---

## Re: Surefire

**chai88888** · Tue Apr 21, 2020 8:10 am

hi there after testing it

notice that when it hit the target it create a new trade but it does not remove the previous order and does not create new order for the running trade.

thanks


---

## Re: Surefire

**Apprentice** · Fri Apr 24, 2020 1:02 pm

Your request is added to the development list.
Development reference 1131.


---

## Re: Surefire

**Apprentice** · Mon Apr 27, 2020 5:18 am

[surefire.lua](files/133237/surefire.lua)

Try this version.


---

## Re: Surefire

**tmue2014** · Fri May 15, 2020 10:28 pm

Your time permitting, would appreciate if you could make an MT4 version of this available as well....

Thank you very much in advance


---

## Re: Surefire

**Apprentice** · Sat May 16, 2020 4:00 pm

Your request is added to the development list.
Development reference 1305.


---

## Re: Surefire

**tmue2014** · Fri Jul 17, 2020 10:43 pm

Hi Apprentice,

any chance you could help with coding this in mql?

Much appreciated....


---

## Re: Surefire

**Apprentice** · Tue Jul 21, 2020 8:48 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=70204](https://fxcodebase.com/code/viewtopic.php?f=38&t=70204)


---

## Re: Surefire

**chai88888** · Thu Oct 20, 2022 8:05 am

can you just fix the amount in lot by 1, 4, 8, 16, 32 .....

why is the strategy cannot play in multiple pairs?

when i tried to run in a second pair it does not have a pending opposite order

thanks


---

## Re: Surefire

**chai88888** · Thu Oct 20, 2022 8:06 am

please edit the first version

thansk


---

## Re: Surefire

**Apprentice** · Sun Oct 23, 2022 3:08 am

It is about the TS2 version of the strategy?


---

## Re: Surefire

**chai88888** · Mon Oct 24, 2022 12:40 am

yes for ts2 strategy please edit the very first version. because when i run it multiple pairs the second and third pairs does not have any opposite order. and the lot sizing is already good please reamain it as is

thanks


---

## Re: Surefire

**Apprentice** · Wed Oct 26, 2022 12:04 pm

We have added your request to the development list.
Development reference 675.


---

## Re: Surefire

**Apprentice** · Thu Aug 10, 2023 11:46 am

[Surefire Strategy.lua](files/151996/Surefire%20Strategy.lua)

Try this version.
