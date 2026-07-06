# Classic MACD strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2473  
> Forum: 31 · Topic 2473 · 41 post(s)


---

## Classic MACD strategy

**vstrelnikov** · Thu Oct 21, 2010 11:51 am

There is a classic MACD strategy which works on MACD indicator.

The strategy enters long when MACD line crosses over SIGNAL line in negative chart area below specified 'open level'. The strategy enters short in opposite conditions (MACD crosses under SIGNAL in positive area).

You can use this strategy by itself or you can use it as a basic sample to create you own strategies.

Options:

1) The strategy can confirm trend with help of Moving Average indicator, you can easily switch this behavior with 'Confirm trend with MA' parameter.

2) The strategy can show signals (alerts, sounds (including recurrent), emails) as well as can trade. By default trading is disabled. To let the strategy trade please go to the "Trading Parameters" and switch "AllowTrading" parameter to "On".

3) In trading parameters you can also switch on and configure stop and limit orders.

4) Strategy work as with FIFO as well as non-FIFO accounts. In case of FIFO account NetStop and NetLimit orders will be created.

 

![MACD Sample.png](images/5411/MACD%20Sample.png)



Download strategy:


---

## Re: Classic MACD strategy

**alepan72** · Fri Dec 17, 2010 5:54 am

> **vstrelnikov wrote:**
> The strategy enters long when MACD line crosses over SIGNAL line in negative chart area below specified 'open level'. The strategy enters short in opposite conditions (MACD crosses under SIGNAL in positive area).

Hello,
Can you explain me please what exactly means "open level" and close level" parameters. My english is nt so good and if it's possible I prefer an image example...
Thanx and sorry for my english...


---

## Re: Classic MACD strategy

**drvery** · Wed Dec 29, 2010 10:23 am

Thank you so much for the strategy. I find it a great tool to design an approach for me. I have one question. If I am to use the strategy to autotrade, what does 'trade size = 1 lots" mean? 10,000 or 100,000. Thank you.


---

## Re: Classic MACD strategy

**Apprentice** · Wed Dec 29, 2010 10:37 am

Lot is The standard unit size of a transaction.

Lot size varies from broker to broker.
It differs in different types of accounts.

For Micro it is usually $ 1000 and for Mini $ 10,000 and $ 100.000 for Standard.


---

## Re: Classic MACD strategy

**drvery** · Wed Dec 29, 2010 11:02 am

The minimum trade size for me is 1 for gold and 10000 for forex, however, when i do the back testing, it showed that next to the arrows indicating buy/selling... SELL 10000K @ ....

WHy 10000k (the K definitely stands for 000) is this just a typo from the strategy? Please advise!


---

## Re: Classic MACD strategy

**AliRaza08** · Wed Apr 08, 2015 7:48 am

I find it a great tool to design an approach for me. I have one question. If I am to use the strategy to autotrade, what does 'trade size = 1 lots" mean? 10,000 or 100,000. Thank you.


---

## Re: Classic MACD strategy

**Apprentice** · Sun Apr 12, 2015 10:25 am

Lots size is determined by your account type.
For me one lot is equivalent of 1000 US Dollar.
[http://www.fxcm.com/markets/resources/v ... -is-a-lot/](http://www.fxcm.com/markets/resources/video-library/new-to-forex/what-is-a-lot/)


---

## Re: Classic MACD strategy

**nweiss** · Mon Apr 13, 2015 6:04 am

Could you add pls that I could change the time frame of the Moving average and also add an Ema as conformation !

Thanks


---

## Re: Classic MACD strategy

**cnikitopoulos94** · Sun Sep 13, 2015 3:31 am

Hey Apprentice,

Is there a way to change the settings where no matter where the macd and signal line crosses over it still does transactions? I would greatly appreciate it if it were an option more then just a solid command.. The reason its important is because sometimes even when macd does do a cross it might range and not give the macd enough time to cross to the other section.

Thanks for taking the time to look at my post.


---

## Re: Classic MACD strategy

**Apprentice** · Mon Sep 21, 2015 5:32 am

Try updated version.
Set MACD Open/Close Level to zero.


---

## Re: Classic MACD strategy

**Apprentice** · Tue Dec 13, 2016 4:18 pm

Strategy was revised and updated.


---

## Re: Classic MACD strategy

**kokobill** · Wed Dec 14, 2016 3:44 am

dear sir apprentice
congratulations for your great work
please , could you add the '' multiple'' choice?
for example
when we are at negative position, every time MACD crosses over SIGNAL, enters long
when we are at positive position , every time MACD crosses down SIGNAL , enters sort

thanks in advance


---

## Re: Classic MACD strategy

**Apprentice** · Wed Dec 14, 2016 6:00 am

Your request is added to the development list, Under Id Number 3695
 If someone is interested to do this task, please contact me.


---

## Re: Classic MACD strategy

**kokobill** · Wed Dec 14, 2016 6:17 am

> **Apprentice wrote:**
> Your request is added to the development list, Under Id Number 3695
> If someone is interested to do this task, please contact me.

dear apprentice
how long will take to have the new strategy with the modification?
it is a just an answer for me to hlep to organise some other thinks.
thanks a lot


---

## Re: Classic MACD strategy

**Alexander.Gettinger** · Tue Nov 07, 2017 3:46 pm

> **kokobill wrote:**
> dear sir apprentice
> congratulations for your great work
> please , could you add the '' multiple'' choice?
> for example
> when we are at negative position, every time MACD crosses over SIGNAL, enters long
> when we are at positive position , every time MACD crosses down SIGNAL , enters sort
>
> thanks in advance

Please try this version of the strategy.

 [MACD Sample2.lua](files/115918/MACD%20Sample2.lua)


---

## Re: Classic MACD strategy

**kokobill** · Thu Nov 09, 2017 3:30 am

Dear sir
good morning from Greece.
thanks you very much ..I am very greatfull..
a small modification please
I would to have the choice to trade one or both side.
can you add thiw? trade one side (buy or sell) or both side
thanks in advance


---

## Re: Classic MACD strategy

**Apprentice** · Tue Nov 21, 2017 7:08 am

Your request is added to the development list under Id Number 3957


---

## Re: Classic MACD strategy

**Apprentice** · Wed Nov 22, 2017 5:09 am

Try this version.

 [MACD Sample.lua](files/116162/MACD%20Sample.lua)


---

## Re: Classic MACD strategy

**kokobill** · Thu Nov 23, 2017 6:26 am

Dear sir
thanks a lot for spending time to help me.
the trade both side , buy side or sell side is ok...
but the multiple is missing ( like the strategy macd sample2)
thanks a lot


---

## Re: Classic MACD strategy

**kokobill** · Thu Nov 23, 2017 6:42 am

> **Apprentice wrote:**
> Try this version.
>
>
> MACD Sample.lua

dear sir
I NEED THE BOTH FUNCIONS in one strategy
1. trade both side or only buy or only sell ( this function exist at the strategy macd sample)
2. trade multiple ( this function exist at the strategy MACD SAMPLE2)

THANKS IN ADVANCE


---

## Re: Classic MACD strategy

**Apprentice** · Sun Dec 03, 2017 5:09 am

Your request is added to the development list under Id Number 3972


---

## Re: Classic MACD strategy

**kokobill** · Mon Dec 04, 2017 6:56 am

Thanks in advance dear apprentice.
I really appreciate it.


---

## Re: Classic MACD strategy

**Apprentice** · Wed Dec 06, 2017 10:43 am

[MACD Sample2.lua](files/116393/MACD%20Sample2.lua)

Something like this?


---

## Re: Classic MACD strategy

**kokobill** · Fri Dec 08, 2017 3:03 am

dear apprentice ..
This is exactly I wanted......
YOU ARE GREAT .!!!!!!!!
YOU ARE GREAT !!!!!!!!
THANKS A LOT.


---

## Re: Classic MACD strategy

**kokobill** · Tue Mar 13, 2018 3:46 am

> **Apprentice wrote:**
>
>
> MACD Sample2.lua
>
>
> Something like this?

dear apprentice
can you add the choice ''live'' ??
thnkas in advance


---

## Re: Classic MACD strategy

**Apprentice** · Mon Mar 26, 2018 10:23 am

Your request is added to the development list under Id Number 4094


---

## Re: Classic MACD strategy

**Apprentice** · Wed Mar 28, 2018 3:24 pm

Try it now.


---

## Re: Classic MACD strategy

**kokobill** · Thu Apr 12, 2018 2:50 pm

dear apprentice.
thanks a lot..
it is ok..


---

## Re: Classic MACD strategy

**kokobill** · Mon Jun 04, 2018 1:37 am

dear apprentice good morning
something strange is happening with the strategy
 it not working
I play 13 pairs. with the same parameters.
but the strategy opens only 2 or 3 pairs.

the parameters for all pairs are
end of turn/live live
12/26/5
confirm trend with ema no
time frame m5 or 4H
allow strategy to trade yes
allow multiple yes
trade side yes
also, when I open a trade by manyaly , then the strategy opens another one at same time.

please can you see what is the problem?
thanks in advance


---

## Re: Classic MACD strategy

**kokobill** · Tue Jun 12, 2018 2:43 am

goodmorning sirs
please can you help me?
I use this strategy and I already lost lot of money because of malfunctions.

thanks in advance


---

## Re: Classic MACD strategy

**chai88888** · Mon Aug 27, 2018 12:39 am

dear apprentice can you add close on opposite signal

thanks


---

## Re: Classic MACD strategy

**Apprentice** · Wed Aug 29, 2018 4:20 am

Your request is added to the development list under Id Number 4243


---

## Re: Classic MACD strategy

**Apprentice** · Thu Aug 30, 2018 1:32 pm

Added for MACD Sample.lua


---

## Re: Classic MACD strategy

**kokobill** · Thu Sep 27, 2018 1:56 am

THE STRATEGY IS NOT WORKING WELL
LOOK AT MY UPPER MESSAGES
THANKS A LOT


---

## Re: Classic MACD strategy

**Apprentice** · Thu Sep 27, 2018 2:41 am

Can you post version used?
Note, the strategy is NOT instrument specific.
Try different parameters for different pairs.


---

## Re: Classic MACD strategy

**kokobill** · Thu Sep 27, 2018 8:56 am

THIS STRATEGY
I USE THE SAME PARAMETERS FOR ALL PAIRS..( I WORK 13 PAIRS AT 13 SAME STRATEGY WITH SAME PARAMETERS)
THANKS A LOT

Re: Classic MACD strategy
Postby Apprentice » Wed Dec 06, 2017 10:43 am

 MACD Sample2.lua
(15.71 KiB) Downloaded 676 times


---

## Re: Classic MACD strategy

**kokobill** · Mon Oct 01, 2018 7:29 am

good morning sir
what do you mean with this? the strategy is NOT instrument specific.


---

## Re: Classic MACD strategy

**Apprentice** · Wed Oct 10, 2018 1:01 pm

If logic works for one instrument, it should work for all.


---

## Re: Classic MACD strategy

**kokobill** · Thu Oct 11, 2018 6:13 am

> **Apprentice wrote:**
> If logic works for one instrument, it should work for all.

there is something wrong
i repeat that i have this strategy for 10 pairs with same parameters.
time frame 4H or 1H or 15 MIN
although the conditions have been fulfilled, the strategy do not give a signal to open buy or sell
This , happens either ''LIVE'' or ''THE AND CYCLE''


---

## Re: Classic MACD strategy

**Victor.Tereschenko** · Sun Oct 14, 2018 4:13 am

> **kokobill wrote:**
> dear apprentice good morning
> something strange is happening with the strategy
> it not working
> I play 13 pairs. with the same parameters.
> but the strategy opens only 2 or 3 pairs.
>
> the parameters for all pairs are
> end of turn/live live
> 12/26/5
> confirm trend with ema no
> time frame m5 or 4H
> allow strategy to trade yes
> allow multiple yes
> trade side yes
> also, when I open a trade by manyaly , then the strategy opens another one at same time.
>
>
>
> please can you see what is the problem?
> thanks in advance

Can you provide a screenshot where the strategy should have trade opened but didn't? I'll investigate that example and fix the issue.


---

## Re: Classic MACD strategy

**kokobill** · Thu Oct 18, 2018 5:38 am

it is difficult.
i do not use this strategy any more..it is dangerous to loose money..
