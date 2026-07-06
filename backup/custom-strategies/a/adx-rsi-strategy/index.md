# ADX RSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=71216  
> Forum: 31 · Topic 71216 · 18 post(s)


---

## ADX RSI Strategy

**Apprentice** · Fri May 21, 2021 6:15 am

![CHN50 m1 (05-21-2021 1311).png](images/142203/CHN50%20m1%20%2805-21-2021%201311%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&t=71199](https://fxcodebase.com/code/viewtopic.php?f=27&t=71199)

Open Long
ADX > ADX Level
RSI Cross Over RSI Buy Level
Open Short
ADX > ADX Level
RSI Cross Under RSI Sell Level

Close Long
RSI Cross Under RSI Buy Close Level
Close Short
RSI Cross Over RSI Sell Close Level

 [ADX RSI Strategy.lua](files/142203/ADX%20RSI%20Strategy.lua)


---

## Re: ADX RSI Strategy

**odfrebth** · Fri May 21, 2021 8:42 am

> **Apprentice wrote:**
>
>
> The attachment **CHN50 m1 (05-21-2021 1311).png** is no longer available
>
>
> Based on the request.
> [https://fxcodebase.com/code/viewtopic.php?f=27&t=71199](https://fxcodebase.com/code/viewtopic.php?f=27&t=71199)
>
> Open Long
> ADX > ADX Level
> RSI Cross Over RSI Buy Level
> Open Short
> ADX > ADX Level
> RSI Cross Under RSI Sell Level
>
> Close Long
> RSI Cross Under RSI Buy Close Level
> Close Short
> RSI Cross Over RSI Sell Close Level
>
>
>
> The attachment **CHN50 m1 (05-21-2021 1311).png** is no longer available

Hi, thank you.
Something is wrong :
Strat must open a buy in A + B and C+D
A: ADX pass over the x level . so pos must be open
B: RSI is above 50, so the pos A is a buy.

on the pic, the strat did not open a pos.


---

## Re: ADX RSI Strategy

**Apprentice** · Fri May 21, 2021 8:55 am

Open Long
ADX / ADX Level Cross Over
RSI > RSI Buy Level
Open Short
ADX / ADX Level Cross Over
RSI < RSI Sell Level

Close Long
RSI Cross Under RSI Buy Close Level
Close Short
RSI Cross Over RSI Sell Close Level

 [ADX RSI Strategy.lua](files/142213/ADX%20RSI%20Strategy.lua)


---

## Re: ADX RSI Strategy

**odfrebth** · Sat May 22, 2021 5:28 pm

> **Apprentice wrote:**
> Open Long
> ADX / ADX Level Cross Over
> RSI > RSI Buy Level
> Open Short
> ADX / ADX Level Cross Over
> RSI < RSI Sell Level
>
> Close Long
> RSI Cross Under RSI Buy Close Level
> Close Short
> RSI Cross Over RSI Sell Close Level
>
>
>
>
> ADX RSI Strategy.lua

Hi, hope you're well.
it is possible to add :
EMA : users must choose
- period 9 or 14 or 39 .....
-Timeframe M15 or H1 ..... (she can be different than others)

The new equation becomes :
Open Long
ADX / ADX Level Cross Over
RSI > RSI Buy Level and EMA is going up
Open Short
ADX / ADX Level Cross Over
RSI < RSI Sell Level and EMA is going down?
Thank you


---

## Re: ADX RSI Strategy

**odfrebth** · Sun May 23, 2021 9:04 am

> **Apprentice wrote:**
> Open Long
> ADX / ADX Level Cross Over
> RSI > RSI Buy Level
> Open Short
> ADX / ADX Level Cross Over
> RSI < RSI Sell Level
>
> Close Long
> RSI Cross Under RSI Buy Close Level
> Close Short
> RSI Cross Over RSI Sell Close Level
>
>
>
>
> ADX RSI Strategy.lua

Last question;
Can you split the strat
the first one strat only long
the second strat only short.
it's easier to program separately.
Thanks.


---

## Re: ADX RSI Strategy

**Apprentice** · Tue May 25, 2021 4:08 am

U can use the "Allowed side for trading or signaling" parameter for that.


---

## Re: ADX RSI Strategy

**Apprentice** · Tue May 25, 2021 7:53 am

[ADX RSI Strategy.lua](files/142275/ADX%20RSI%20Strategy.lua)

Open Long
ADX / ADX Level Cross Over
RSI > RSI Buy Level and EMA slope is Up
Open Short
ADX / ADX Level Cross Over
RSI < RSI Sell Level and EMA slope is Down


---

## Re: ADX RSI Strategy

**odfrebth** · Tue May 25, 2021 10:14 am

> **Apprentice wrote:**
>
>
> ADX RSI Strategy.lua
>
>
> Open Long
> ADX / ADX Level Cross Over
> RSI > RSI Buy Level and EMA slope is Up
> Open Short
> ADX / ADX Level Cross Over
> RSI < RSI Sell Level and EMA slope is Down

Perfect, thanks


---

## Re: ADX RSI Strategy

**odfrebth** · Thu May 27, 2021 3:57 am

> **Apprentice wrote:**
>
>
> ADX RSI Strategy.lua
>
>
> Open Long
> ADX / ADX Level Cross Over
> RSI > RSI Buy Level and EMA slope is Up
> Open Short
> ADX / ADX Level Cross Over
> RSI < RSI Sell Level and EMA slope is Down

Hi,
Can we try :

Open Long
ADX / ADX Level Cross Over
RSI > RSI Buy Level and MA (9) is above MA (39)
Open Short
ADX / ADX Level Cross Over
RSI < RSI Sell Level and MA 9 is below MA39

It's to reduce a little more the wrong long or short.
Thank you.


---

## Re: ADX RSI Strategy

**Apprentice** · Thu May 27, 2021 4:19 am

Your request is added to the development list.
Development reference 524.


---

## Re: ADX RSI Strategy

**Apprentice** · Thu May 27, 2021 6:55 am

Open Long
ADX / ADX Level Cross Over
RSI > RSI Buy Level and MA (9) is above MA (39)
Open Short
ADX / ADX Level Cross Over
RSI < RSI Sell Level and MA 9 is below MA39

 [ADX RSI Strategy.lua](files/142317/ADX%20RSI%20Strategy.lua)


---

## Re: ADX RSI Strategy

**odfrebth** · Mon Jun 07, 2021 10:59 am

> **Apprentice wrote:**
> Open Long
> ADX / ADX Level Cross Over
> RSI > RSI Buy Level
> Open Short
> ADX / ADX Level Cross Over
> RSI < RSI Sell Level
>
> Close Long
> RSI Cross Under RSI Buy Close Level
> Close Short
> RSI Cross Over RSI Sell Close Level
>
>
>
>
> ADX RSI Strategy.lua

Hi,
Can we try a new update for this strat please ? (this strat, not with EMA)

Open Long
ADX / ADX Level Cross Over
RSI > RSI Buy Level (for exemple 55), but if RSI > second level, it's a short (for exemple 75)
Open Short
ADX / ADX Level Cross Over
RSI < RSI Sell Level (for exemple 45), but, if RSI < second level, it's a long (for exemple 25)

Close Long
RSI Cross Under RSI Buy Close Level
Close Short
RSI Cross Over RSI Sell Close Level

Thanks


---

## Re: ADX RSI Strategy

**Apprentice** · Tue Jun 08, 2021 6:28 am

Your request is added to the development list.
Development reference 561.


---

## Re: ADX RSI Strategy

**Apprentice** · Tue Jun 08, 2021 8:42 am

[ADX RSI Strategy.lua](files/142453/ADX%20RSI%20Strategy.lua)

Open Long
ADX / ADX Level Cross Over
RSI > 1. RSI Buy Level
RSI < 2. RSI Buy Level

Close Long
RSI Cross Under RSI Buy Close Level

Viceversa for Short.


---

## Re: ADX RSI Strategy

**shaloiulabcde** · Thu Oct 21, 2021 4:56 pm

Can you add one more buy and sell level to this strategy, so 3 buy levels and 3 sell levels plus the 2 buy/sell close levels?


---

## Re: ADX RSI Strategy

**shaloiulabcde** · Mon Oct 25, 2021 6:51 am

Hi Team,

Can you please update this to have RSI 3 buy levels and 3 sell levels (instead of 2 each)?

Thanks


---

## Re: ADX RSI Strategy

**Apprentice** · Tue Oct 26, 2021 4:09 am

Your request is added to the development list.
Development reference 936.


---

## Re: ADX RSI Strategy

**Apprentice** · Wed Nov 03, 2021 11:33 am

This is original Logic
Open Long
ADX / ADX Level Cross Over
RSI > 1. RSI Buy Level
RSI < 2. RSI Buy Level

Close Long
RSI Cross Under RSI Buy Close Level

Viceversa for Short.

Can you incorporate the third line?
