# MTF RSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63832  
> Forum: 31 · Topic 63832 · 8 post(s)


---

## MTF RSI Strategy

**Apprentice** · Fri Sep 02, 2016 4:43 am

![EURUSD H1 (09-02-2016 1053).png](images/107935/EURUSD%20H1%20%2809-02-2016%201053%29.png)



BUY
1. RSI lines cross over 20
2. RSI lines is over 20
3. RSI lines is over 20

SELL
1. RSI lines cross under 80
2. RSI lines is under 80
3. RSI lines is under 80

EXIT BUY
RSI line 2 cross under RSI line 3

EXIT SELL
RSI line 2 cross over RSI line 3

 [MTF RSI Strategy.lua](files/107935/MTF%20RSI%20Strategy.lua)


---

## Re: MTF RSI Strategy

**jaricarr** · Sat Sep 03, 2016 3:19 pm

Hello Apprentice,

Thank you very much for setting up this strategy.

2 things :

1-Only opens trades if the "close on opposite" is set to yes. This triggers unwanted trades in the opposite direction.
2-It is ignoring some trades when the lines cross the levels.

can you add this logic:

Use 3rd timeframe (yes/no)

Entry option-
1-Trade at OB/OS levels (all lines should cross level)
2-BUY when all RSI lines cross-over (each other), SELL when all RSI lines cross-under (each other)


---

## Re: MTF RSI Strategy

**Apprentice** · Sat Dec 17, 2016 11:11 am

Strategy was revised and updated.


---

## Re: MTF RSI Strategy

**jaricarr** · Sat Feb 25, 2017 1:26 am

Hi Apprentice,

Thanks for the update.

Can you please add a trading time frame ?

The trading TF would be independent of the RSI time frames.

See screenshot please.


---

## Re: MTF RSI Strategy

**Apprentice** · Fri Mar 17, 2017 5:24 am

Try it now.


---

## Re: MTF RSI Strategy

**kokobill** · Fri Sep 08, 2017 8:55 am

dear apprentice.
could you add the ''allow multiple'' like the strategy ''HIGILY ADAPTUBLE RSI STRATEGY'' ??
THANKS IN ADVANCE


---

## Re: MTF RSI Strategy

**Apprentice** · Fri Sep 29, 2017 7:51 am

Can you provide web reference?


---

## Re: MTF RSI Strategy

**Apprentice** · Wed Jan 31, 2018 6:52 am

The strategy was revised and updated.
