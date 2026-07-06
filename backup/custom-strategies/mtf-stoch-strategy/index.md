# MTF Stoch Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7748  
> Forum: 31 · Topic 7748 · 4 post(s)


---

## MTF Stoch Strategy

**Apprentice** · Tue Nov 01, 2011 1:14 pm

![MTF  StochRsi Strategy.png](images/17246/MTF%20StochRsi%20Strategy.png)



**First, the use of this strategy is for now limited to holders of the beta version of trading platform.**

Strategy Use:

1.	STOCH RSI [14,14,3,3] OF TIME FRAME 1:{m15}
WITH BUY ENTRY LEVEL {20}
AND SELL ENTRY LEVEL{80}

2.	STOCH RSI [14.14.3.3} OF TIME FRAME 2: {H1}
WITH BUY ENTRY LEVEL {50}
AND SELL ENTRY LEVEL{50}

3.	STOCH RSI {14,14, 3,3} OF TIME FRAME 3:{H4}
WITH BUY ENTRY LEVEL {50}
AND SELL ENTRY LEVEL {50}

4. STOCH RSI {14,14, 3,3} OF TIME FRAME 4:{D1}
WITH BUY ENTRY LEVEL {50}
AND SELL ENTRY LEVEL {50}

BUY ENTRY CONDITION:

1.	STOCH RSI OF H1 > BUY ENTRY LEVEL OF H1[50] {AND},
2.	STOCH RSI OF H4 > BUY ENTRY LEVEL OF H4[50] {AND},
3. STOCH RSI OF D1> BUY ENTRY LEVEL OF D1[50] {AND},
4.	STOCHRSI OF M15 CROSS OVER BUY ENTRY LEVEL OF M15[20].

SELL ENTRY CONDITION:

1.	STOCH RSI OF H1< SELL ENTRY LEVEL OF H1[50]{AND},
2.	STOCHRSI OF H4< SELL ENTRY LEVEL OF H4[50] {AND},
3. STOCHRSI OF D1< SELL ENTRY LEVEL OF D1[50] {AND},
4.	STOCHRSI OF M15 CROSS UNDER SELL ENTRY LEVEL

EXIT BUY CONDITIONS:
1.	STOCHRSI OF H1 CROSS UNDER BUY ENTRY LEVEL OF H1{50}{OR}
2.	STOCHRSI OF H4 CROSS UNDER BUY ENTRY LEVEL OF H4{50}{OR]
3. STOCHRSI OF D1 CROSS UNDER BUY ENTRY LEVEL OF D1{50}{OR]
4.	STOCHRSI OF M15 CROSS UNDER SELL ENTRY LEVEL OF M15{80}.

EXIT SELL CONDITIONS

1.	STOCHRSI OF H1 CROSS OVER SELL ENTRY LEVEL OF H1{50}{OR}
2.	STOCHRSI OF H4 CROSS OVER SELL ENTRY LEVEL OF H4{50} {OR}
3. STOCHRSI OF D1 CROSS OVER SELL ENTRY LEVEL OF D1 {50} {OR}
4.	STOCHRSI OF M15 CROSS OVER BUY ENTRY LEVEL OF M15 {20}

 [MTF StochRsi Strategy.lua](files/17246/MTF%20StochRsi%20Strategy.lua)

Install Stochastic RSI from here. This is NOT optional.
[http://www.fxcodebase.com/code/viewtopic.php?f=17&t=451](http://www.fxcodebase.com/code/viewtopic.php?f=17&t=451)


---

## Re: MTF Stoch Strategy

**jtatalov** · Wed Nov 02, 2011 6:14 pm

It says there is an error when loading the strat into MS 2.0


---

## Re: MTF Stoch Strategy

**Apprentice** · Wed Nov 02, 2011 6:41 pm

There is no error, as I wrote this strategy is written for the beta version of the next version of TS platform.


---

## Re: MTF Stoch Strategy

**Apprentice** · Wed Jan 31, 2018 6:32 am

The strategy was revised and updated.
