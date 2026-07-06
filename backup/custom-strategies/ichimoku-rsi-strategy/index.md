# Ichimoku RSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7802  
> Forum: 31 · Topic 7802 · 10 post(s)


---

## Ichimoku RSI Strategy

**Apprentice** · Fri Nov 04, 2011 5:05 am

![Ichimoku RSI Strategy.png](images/17358/Ichimoku%20RSI%20Strategy.png)



**First,**
**the use of this strategy is for now limited to holders of the beta version of trading platform.**

the following stragegy will clearly define ranging market and trending market and it will make entry only trending market

it is based on following indicators:
1. ischimo with
tenkan-sen period 9,
kijun-sen period 26,
senkouspan B period 52{ default parameters}.
2. rsi 14 with buy level (0), sell level (0)
3. adx 14 with entry level 20{ optional }
4.dmi 14 with entry level 20{otional}

buy when:

1. chinkov span > kijun-sen
2. tenkan-sen > kijun-sen
3.rsi 14 cross over buy level
4.adx 14 > entry level and increasing
5.dmi 14 > entry level and dmi +> dmi -

sell when:

1. chinkov span < kijun-sen
2. tekan-sen < kijun-sen
3. rsi 14 cross under sell level
4. adx 14 >entry level and increasing
5.dmi 14 > entry level and dmi -> dmi +

exit buy when:

1. rsi cross under sell level(0)
2.tenkan-sen cross under kijun-sen

exit sell when:

1. rsi cross over buy level{0}
2tekan-sen cross over kijun-sen

 [Ichimoku RSI Strategy.lua](files/17358/Ichimoku%20RSI%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Ichimoku RSI Strategy

**superleo** · Sun Nov 06, 2011 9:21 am

thanks lot for this nice strategy. can you add following options in this strategy

for buying conditions :
 1.SA > SB
2. price>SA

it means price is above the bullish cloud. this should be considered with other buying conditions

for selling conditions:
1. SA<SB
2. price<SA

it means price is below the bearish cloud. this should be considered with others selling conditions

thank you


---

## Re: Ichimoku RSI Strategy

**Apprentice** · Tue Nov 08, 2011 1:26 pm

Your request is added to the development queue.


---

## Re: Ichimoku RSI Strategy

**Apprentice** · Fri Jan 27, 2012 1:12 pm

Can you write a complete specification.

I'm not sure which parts of the old strategy, you want to use,
and which you want to change.


---

## Re: Ichimoku RSI Strategy

**superleo** · Fri Jan 27, 2012 7:00 pm

sir,

buy when:

1. chinkov span > kijun-sen
2. tenkan-sen > kijun-sen
**3.rsi 14 cross over buy level**
4.adx 14 > entry level and increasing
5.dmi 14 > entry level and dmi +> dmi -

this is already present in this strategy

i request you to add

6.SA > SB
7. price >SA

sell when:

1. chinkov span < kijun-sen
2. tekan-sen < kijun-sen
**3. rsi 14 cross under sell level**
4. adx 14 >entry level and increasing
5.dmi 14 > entry level and dmi -> dmi +

this is already in this strategy

i request you to add

1. SA<SB
2. price <SA

**it means

when every thing is in bullish condition and rsi cross over buy level --buy
when every thing is in bearish condition and rsi cross under sell level --- sell**
thank you.


---

## Re: Ichimoku RSI Strategy

**Apprentice** · Sun Jan 29, 2012 1:47 pm

Your request is added to the developmental cue.


---

## Re: Ichimoku RSI Strategy

**jaricarr** · Sun Jul 10, 2016 11:20 pm

it is based on following indicators:
1. ischimo with
tenkan-sen period 9,
kijun-sen period 26,
senkouspan B period 52{ default parameters}.
2. rsi 14 with buy level (0), sell level (0)
3. adx 14 with entry level 20{ optional }
4.dmi 14 with entry level 20{otional}

Hi Apprentice,

The strategy does not have the option to not use the ADX and DMI filters.
Is it possible to add the "on/off" option please.

Thanks,
JC


---

## Re: Ichimoku RSI Strategy

**jaricarr** · Tue Jul 19, 2016 12:25 am

Hi Apprentice,

Please update so that it is possible to turn "on/off" the ADX AND DMI.

Thanks,
JC


---

## Re: Ichimoku RSI Strategy

**Apprentice** · Mon Aug 08, 2016 7:51 am

Major update.
ADX / DMI "on/off" switch added.


---

## Re: Ichimoku RSI Strategy

**Apprentice** · Sat Dec 17, 2016 9:38 am

Strategy was revised and updated.
