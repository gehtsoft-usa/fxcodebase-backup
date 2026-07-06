# T3 Indicator - Better Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62129  
> Forum: 17 · Topic 62129 · 5 post(s)


---

## T3 Indicator - Better Moving Average

**STS Trading** · Tue Apr 21, 2015 5:10 am

Testing a new strategy I found in a German trading journal necessarily a T3 indicator was needed. The T3 indicator was developed by Tim Tillson in 1998 and published in the S&C Magazine under the topic "Smoothin Techniques For More Accurate Signals". The article is also known as the "Better Moving Average".

The input parameters are the number of periods n and a velocity value v. To calculate the T3 line first a generalized double EMA is to be calculated as shown below:

Code: [Select all](https://fxcodebase.com/code/)
`GD(n,v) = EMA(n) * (1 + v) - EMA(EMA(n)) * v`
Finally you get the T3 value by this formula:

Code: [Select all](https://fxcodebase.com/code/)
`T3(n) = GD(GD(GD(n)))`

The implementation quiet differs slightly from the formula above:

Code: [Select all](https://fxcodebase.com/code/)
`EMA[1] = EMA(Source, n) and EMA[i] = EMA(EMA, i - 1)
T3 = -v^3 * EMA[6] + (3 * v^2 + 3 * v^3) * EMA[5] + (-6 * v^2 - 3 * v - 3 * v^3) * EMA[4] + (1 + 3 * v + v^3 + 3 * v^2) * EMA[3]`

The T3 indicator can be downloaded here:

 [T3.lua](files/99930/T3.lua)

Chris


---

## Re: T3 Indicator - Better Moving Average

**Apprentice** · Tue Apr 21, 2015 5:19 am

Thank you for your efforts.
Identical indicator can be found here.
[viewtopic.php?f=17&t=1302&p=2487&hilit=Tim+Tillson#p2487](https://fxcodebase.com/code/viewtopic.php?f=17&t=1302&p=2487&hilit=Tim+Tillson#p2487)


---

## Re: T3 Indicator - Better Moving Average

**STS Trading** · Tue Apr 21, 2015 5:29 am

Oops. If the search query has to be at least 3 characters, it doesn't makes it easier to find the T3 indicator in the future.

Anyway. Thanks for the hint. I attached an improved version of my own implementation. The calculation of the first period was faulty:

Code: [Select all](https://fxcodebase.com/code/)
`TFirst = First + 6 * math.floor(1.5 * N);`
Chris


---

## Re: T3 Indicator - Better Moving Average

**Apprentice** · Fri May 06, 2016 3:29 am

MT4 version is available here.
[viewtopic.php?f=38&t=63063&p=106118#p106118](https://fxcodebase.com/code/viewtopic.php?f=38&t=63063&p=106118#p106118)


---

## Re: T3 Indicator - Better Moving Average

**Apprentice** · Sun Sep 02, 2018 5:38 am

The indicator was revised and updated.
