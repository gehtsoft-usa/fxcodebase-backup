# Candle Completion

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63706  
> Forum: 17 · Topic 63706 · 3 post(s)


---

## Candle Completion

**Apprentice** · Mon Jul 25, 2016 6:44 am

![EURUSD D1 (07-25-2016 1310).png](images/107321/EURUSD%20D1%20%2807-25-2016%201310%29.png)



Based on request.
[viewtopic.php?f=27&t=63702#p107287](https://fxcodebase.com/code/viewtopic.php?f=27&t=63702#p107287)

Indicator will show body/candle ratio as "Percentage" or "Fraction"

 [Candle Completion.lua](files/107321/Candle%20Completion.lua)


---

## Re: Candle Completion

**Hailkayy** · Mon Jul 25, 2016 10:57 am

Thanks !

1) Just let us modify the ratio as "x/y"

X is the body fraction
Y is the candle whole lenght (including wicks).

User may type :
6/8 or
3/4 or
8/10 etc.

Meaning user wants the algorithm to mark the percentage of candles in the chart that have 6/8 (a body of 6 over a total lenght aof 8), 3/4 or 8/10 or any fraction typed.

Example : user types 4/5 and result displayed is 80%
Meaning : 80% of the candles have a body of 4 over a total lenght of 5 (the close of the candle is very near to its extreme. The candles of this chart are nearly all full, barely any wicks).

2) Please include :
"Period" (in order not to the whole historical data into account but just the last "Period" to make it more relevant to market actual conditions).

3) Instead of 33.41/100 please replace the "100" by "%" (34.41%) and remove "body/candle" as this name doesnt match the figures.
In short the indicator will just display the result like "80%".

Thanks.


---

## Re: Candle Completion

**Apprentice** · Sat Jun 30, 2018 4:01 am

The indicator was revised and updated.
