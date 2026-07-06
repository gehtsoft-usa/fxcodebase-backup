# Alligator Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63638  
> Forum: 31 · Topic 63638 · 9 post(s)


---

## Alligator Strategy

**Apprentice** · Fri Jul 01, 2016 7:46 am

![EURUSD H1 (07-01-2016 1410).png](images/106977/EURUSD%20H1%20%2807-01-2016%201410%29.png)



Based on request.
[viewtopic.php?f=27&t=63637](https://fxcodebase.com/code/viewtopic.php?f=27&t=63637)

Long/Short
 When "lips " and " teeth" of Alligator Indicator cross Over/Under " Jaw "
and candlesticks upward /down is equal or greater then Delta pips.

Exit (Option)
When "lips " and " teeth" cross Under/Over " Jaw "

 [Alligator Strategy.lua](files/106977/Alligator%20Strategy.lua)

The Strategy was revised and updated on January 18, 2019.


---

## Re: Alligator Strategy

**Utawafr** · Tue Aug 02, 2016 6:06 am

Thank you for this version.

Sorry but this strategy not correspond with my ask because the tender opening or sell order is not carried out when there is crossover between the curves when "lips " and " teeth" of Alligator Indicator cross Over/Under " Jaw ". And there is no fence in the order when the curves cross again ...

As you can see from the screenshot , there is a cross of red curve with the blue curve on the rise, but no purchase order was not implemented , while the strategy is enabled.

Can you rectify this please ?

Long/Short
Open an order when "teeth" of Alligator Indicator cross Over/Under " Jaw " and candlesticks upward /down (wait put order +10 pips if cross over, and wait put order -10 pips if cross under).

Stop order
When " lips" cross Under/Over " Jaw "

Thank you very much


---

## Re: Alligator Strategy

**Apprentice** · Tue Aug 02, 2016 7:32 am

Your request is added to the development list, Under Id Number 3583
 If someone is interested to do this or any task other from list please contact me.


---

## Re: Alligator Strategy

**Utawafr** · Fri Aug 26, 2016 4:05 am

Hello,

Let me go up the post, I know nothing about coding , and I 'm sure I would like this strategy is a winner. Thank you very much for your work in advance


---

## Re: Alligator Strategy

**Utawafr** · Tue Oct 18, 2016 12:03 pm

Hello,

Let me go up the post, I know nothing about coding , and I 'm sure that this strategy is a winner. I have test during some weeks manualy, but I can't stay on the market all time, and I can't put or stop order when there are conditions for put or stop order...

The strategy that you have code for me, doesn't correspond with my first ask because the tender opening or sell order is not carried out when there is crossover between the curves when "lips " and "teeth" of Alligator Indicator cross Over/Under " Jaw ". And there is no fence in the order when the curves cross again ...

As you can see from the screenshot in my post of August 02, there is a cross of red curve with the blue curve on the rise, but no purchase order was not implemented , while the strategy is enabled.

Can you rectify this please, with this parameters ?

For Long/Short order :
My strategy consist at open an order when "teeth" (red lign) of Alligator Indicator cross Over/Under "Jaw " (blue lign) and candlesticks upward /down, but for put a new order, wait +10 pips if cross over "Jaw", and wait -10 pips if cross under "Jaw", for to be sure that we have a really new trend).

Stop order
At the moment when "Teeth" cross Under/Over "Jaw ".

For resumed :

Open order when red lign of Alligator Indicator corss Over/Under blue lign of Alligator Indicator AND +10 pips if cross over blue lign, and wait -10 pips if cross under blue lign. Stop order when new cross between red lign and blue lign, and wait 10 pips for know new trend before put new order.

I use this strategy for T15, T30 and T1H, and for GBP/USD, AUD/USD, EUR/GBP and EUR/USD.
In your previously strategy i was limited by the trade amount in lots at 100, can you not put limit please in this new strategy ?

Thank you very much for your working, I can't find the same quality of work in other website . (and sorry for my english)


---

## Re: Alligator Strategy

**Apprentice** · Sun Dec 18, 2016 7:16 am

Strategy was revised and updated.


---

## Re: Alligator Strategy

**AlexanderS** · Tue Oct 19, 2021 5:28 pm

HI

Can you make HIGHLY ADAPTABLE strategy PLEAS

PRICE CROSS ALLIGATOR JAW UP
PRICE CROSS ALLIGATOR JAW DOWN

PRICE CROSS ALLIGATOR TEETH UP
PRICE CROSS ALLIGATOR TEETH DOWN

PRICE CROSS ALLIGATOR LIPS UP
PRICE CROSS ALLIGATOR LIPS DOWN

CLOSE YES NO
.........


---

## Re: Alligator Strategy

**Apprentice** · Wed Oct 20, 2021 6:05 am

Your request is added to the development list.
Development reference 924.


---

## Re: Alligator Strategy

**Apprentice** · Tue Oct 26, 2021 7:49 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=31&t=71592](https://fxcodebase.com/code/viewtopic.php?f=31&t=71592)
