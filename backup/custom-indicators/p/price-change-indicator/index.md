# Price Change Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=71319  
> Forum: 17 · Topic 71319 · 4 post(s)


---

## Price Change Indicator

**virtualtrader** · Sun Jul 04, 2021 10:30 pm

could somebody help me to write code in lua for this idea:
this is a candlestick analyse in 1 minute TF, it takes 5 analysis points per candlestick
on opening time/price of new candle :
1. if sentiment/ mood trader indicator is less than 50% then input point 1 = bullish/bearish
2. just after point 1 obtained, first color appear input point 2 = bullish/ bearish
3. just after point 2 obtained, if current candlestick body is bigger than previous candlestick then
 point 3 = current candlestick color ( bullish/ bearish)
 or if current candlestick body is smaller than previous candlestick then
 point 3 = previous candlestick color (bullish/ bearish)
4. just after point 3 obtained, calculate the price change up and down,
 if it has reached a certain amount ( user input ) then
 if the price change up reached the amount first input point 4 = bearish
 or if the price chnge down reached the amount first input point 4 = bullish
5. when point 4 is formed, if the candlestick has one tail then point 5 = point 4
 or if the candlestick has two tail then point 5 ≠ point 4

 of the five points that have been obtained, then take the dominant point for the result
 forming the result by arrow


---

## Re: Price Change Indicator

**Apprentice** · Mon Jul 05, 2021 2:54 am

> 1. if sentiment/ mood trader indicator is less than 50% then input point 1 = bullish/bearish
> 2. just after point 1 obtained, first color appear input point 2 = bullish/ bearish

Can you clarify these two?


---

## Re: Price Change Indicator

**virtualtrader** · Mon Jul 05, 2021 9:03 pm

1 the first point which is taken from the lowest percentage or less than 50% of the sentiment
 indicator at the time of the opening of a new candle
 if at opening price bullish percentage is less than 50% its mean point 1 is bullish
 if at opening price bearish percentage is less than 50% its mean point 1 is bearish
2 the first price movement after the opening price, whether the price is moving up its mean first
 color is green/ bullish or price is moving down its mean the first color is red/ bearish


---

## Re: Price Change Indicator

**Apprentice** · Tue Jul 06, 2021 2:06 am

Your request is added to the development list.
Development reference 615.
