# Risk Reward Positions Overview

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66100  
> Forum: 17 · Topic 66100 · 23 post(s)


---

## Risk Reward Positions Overview

**Apprentice** · Fri May 04, 2018 6:10 am

![EURUSD m1 (05-04-2018 1110).png](images/119072/EURUSD%20m1%20%2805-04-2018%201110%29.png)



Based on the request.
[viewtopic.php?f=27&t=66017](https://fxcodebase.com/code/viewtopic.php?f=27&t=66017)

 [Risk Reward Positions Overview.lua](files/119072/Risk%20Reward%20Positions%20Overview.lua)

MT4/MQ4 version
[viewtopic.php?f=38&t=69050](https://fxcodebase.com/code/viewtopic.php?f=38&t=69050)


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Fri May 04, 2018 10:27 am

Thanks for the indicator, but the indicator has some errors

1- The indicator say i have 4 entry orders but i dont have any entry order in that pair.
2- The Risk/Reward calculation is wrong

For example:
For the second trade the number 36670094 the RR say 1/0.23984375 and that is not correct the correct result is 1:3.7 or rounded 1:4 because the calculus is:

Take Profit (pips) / Stop Loss (pips) = 125.4/-33.3 = 3.76 or rounded 4

So the Risk/Reward in that trade is 1:3.76 or rounded 1:4

Put the risk/reward rounded 1:4 is much better and take less space because too much decimals is not important 1:4 is ok only 2 numbers. And put the format like this 1:4 not 1/4

In the entry orders when i putt one the indicator show it but the calculus is wrong too.


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Sat May 19, 2018 8:32 pm

> **Apprentice wrote:**
>
>
> EURUSD m1 (05-04-2018 1110).png
>
>
> Based on the request.
> [viewtopic.php?f=27&t=66017](https://fxcodebase.com/code/viewtopic.php?f=27&t=66017)
>
>
> Risk Reward Positions Overview.lua

Check the error below


---

## Re: Risk Reward Positions Overview

**Apprentice** · Mon May 28, 2018 7:11 am

[Risk Reward Positions Overview.lua](files/119378/Risk%20Reward%20Positions%20Overview.lua)

Can you test this version?
The colleague made the modification.
I'm on vacation.


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Mon May 28, 2018 9:58 am

> **Apprentice wrote:**
>
>
> The attachment **Risk Reward Positions Overview.lua** is no longer available
>
>
> Can you test this version?
> The colleague made the modification.
> I'm on vacation.

It does't work the Risk Reward calculus is wrong and the remaining pips to trigger the order was wrong too, remember the formula for the RR is: Take Profit (pips) / Stop Loss (pips) = RR, check my last post about that explaining the error.


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Thu Aug 30, 2018 5:22 pm

Any news about this ?


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Fri Mar 15, 2019 9:38 am

Please can you fix the error I mention?

Thank


---

## Re: Risk Reward Positions Overview

**Apprentice** · Wed Mar 20, 2019 1:21 pm

Try this version.

 [Risk Reward Positions Overview_1.lua](files/124815/Risk%20Reward%20Positions%20Overview_1.lua)


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Wed Oct 09, 2019 7:30 pm

It need to fix.

The pips left to hit the entry order never change is has a fixed quatity of pips and that is wrong.

THe indicator show wrong pips, check the image it show the positive trades in negative and negative trades in positive.

If a trade don't have stop or limit please make the indicator to put -:- like when a trade dont have both, because if i have a trade only with limit or stop the rule of risk reward is not complete.

Can you add a new column to show the gross P/L of each trade.

Can you add a net total showing the sum of all trades pips and gross P/L


---

## Re: Risk Reward Positions Overview

**Apprentice** · Mon Oct 14, 2019 5:29 am

[Risk_Reward_Positions_Overview.lua](files/129189/Risk_Reward_Positions_Overview.lua)

Try this version.


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Mon Oct 14, 2019 5:43 pm

Thanks it work perfect.

Can you modify the format and add some things in the tittle (the same for the entry orders)

Check the attached image.


---

## Re: Risk Reward Positions Overview

**Apprentice** · Tue Oct 15, 2019 1:06 pm

Things like?


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Tue Oct 15, 2019 1:18 pm

> **Apprentice wrote:**
> Things like?

Check the square's red in the attached photo


---

## Re: Risk Reward Positions Overview

**Richstocks99** · Thu Oct 17, 2019 9:03 am

Hello. Could you make this into an MT4 File please? Thank You


---

## Re: Risk Reward Positions Overview

**Apprentice** · Thu Oct 17, 2019 3:14 pm

Your request is added to the development list.
Development reference 204.


---

## Re: Risk Reward Positions Overview

**Apprentice** · Thu Oct 24, 2019 6:13 am

[Risk_Reward_Positions_Overview.lua](files/129403/Risk_Reward_Positions_Overview.lua)

Try this version.


---

## Re: Risk Reward Positions Overview

**Apprentice** · Thu Oct 24, 2019 6:16 am

MT4/MQ4 version
[viewtopic.php?f=38&t=69050](https://fxcodebase.com/code/viewtopic.php?f=38&t=69050)


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Thu Oct 24, 2019 10:32 am

> **Apprentice wrote:**
>
>
> The attachment **Risk_Reward_Positions_Overview.lua** is no longer available
>
>
> Try this version.

CHeck the attached image and the red square why it have this #INF


---

## Re: Risk Reward Positions Overview

**Apprentice** · Mon Oct 28, 2019 5:25 am

I can't repeat it. I need to know the open price + stop + limit values to repeat it.


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Mon Oct 07, 2024 11:53 am

The indicator have an error. If you see in the image I have 2 open trades and both stop loss and take profit are the same for the 2 trades and the indicator show a R:R of 1.5 for one trade and 1:3 for another one, but if the 2 trades have the same S/L and T/P it supose to be the same R:R. Please check it.


---

## Re: Risk Reward Positions Overview

**Apprentice** · Wed Oct 09, 2024 12:33 pm

We have added your request to the development list.
Development reference 777


---

## Re: Risk Reward Positions Overview

**Reymondpolanco** · Wed Oct 23, 2024 9:18 am

> **Apprentice wrote:**
> We have added your request to the development list.
> Development reference 777

Any update of this ?


---

## Re: Risk Reward Positions Overview

**Victor.Tereschenko** · Fri Nov 29, 2024 5:06 am

> **Reymondpolanco wrote:**
> The indicator have an error. If you see in the image I have 2 open trades and both stop loss and take profit are the same for the 2 trades and the indicator show a R:R of 1.5 for one trade and 1:3 for another one, but if the 2 trades have the same S/L and T/P it supose to be the same R:R. Please check it.

The stop and limit are on the same levels but the entry levels of the trade are not. That's why the rate is different
