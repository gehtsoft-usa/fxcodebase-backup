# Stochastic_Strategy with RSI

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=71837  
> Forum: 31 · Topic 71837 · 6 post(s)


---

## Stochastic_Strategy with RSI

**Apprentice** · Mon Jan 31, 2022 6:45 am

![CHN50 m5 (01-31-2022 1243).png](images/144897/CHN50%20m5%20%2801-31-2022%201243%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&p=144878](https://fxcodebase.com/code/viewtopic.php?f=27&p=144878)

 [Stochastic_Strategy with RSI.lua](files/144897/Stochastic_Strategy%20with%20RSI.lua)

MT4 version
[https://fxcodebase.com/code/viewtopic.php?f=38&t=71932](https://fxcodebase.com/code/viewtopic.php?f=38&t=71932)


---

## Re: Stochastic_Strategy with RSI

**Apprentice** · Mon Jan 31, 2022 6:54 am

Updated.


---

## Re: Stochastic_Strategy with RSI

**OzzyTrader** · Wed Feb 02, 2022 12:08 am

Excellent works great.

For those that are wondering I use this with the filter type "range" selected.
Personally I use price between Fib retrace levels and the entry zone. To do this draw the fib in market scope>measure distance between fib lines>divide it by 2> in the middle of the fib lines is your "filter level" the number you get when dividing the range by two is your "Range width in pips"

works well when playing shorter time frames. Find a fib level you like for pullbacks, set the RSI filter to 1h. I have found it cuts outs 90+% of the false starts you get when trading shorter time frames. specifically 15m and 30m stochastic crosses on short 10-15 pip targets. You will miss some trades by number but gain the piece of mind your shorter time frame trades spend less time in negative pips and will only enter when the 1h rsi is above 50.

I did a quick backtest on USDCAD 15m with only trading buy trades and in uptrend weeks. 10 trades in 4 weeks. less than -15pips neg movement average time trade in play 2hrs target set to 10pips. missed out on six trades but when including these trades the average time in play went to 6.25 hours. and average neg movement went to -36 pips.

Cheers Apprentice for getting this one done so quick.


---

## Re: Stochastic_Strategy with RSI

**OzzyTrader** · Fri Feb 18, 2022 9:40 pm

Would we be able to have this strategy in MT4 also please. Works great


---

## Re: Stochastic_Strategy with RSI

**Apprentice** · Sat Feb 19, 2022 4:51 am

Your request is added to the development list.
Development reference 107.


---

## Re: Stochastic_Strategy with RSI

**Apprentice** · Thu Mar 03, 2022 12:37 pm

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=71932](https://fxcodebase.com/code/viewtopic.php?f=38&t=71932)
