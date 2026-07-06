# MTF Two EMA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=13149  
> Forum: 31 · Topic 13149 · 7 post(s)


---

## MTF Two EMA Strategy

**Apprentice** · Fri Feb 10, 2012 3:27 pm

![MTF Two EMA Strategy.png](images/25669/MTF%20Two%20EMA%20Strategy.png)



BUY
 First EMA on H1 cross over Second EMA on H1
 and First EMA > Second EMA on H4, H8, D1 time frames

SELL
 First EMA on H1 cross under Second EMA on H1
 and First EMA < Second EMA on H4,H8,D1 time frames

CLOSE
When First EMA crosses back Second EMA

 [MTF Two EMA Strategy.lua](files/25669/MTF%20Two%20EMA%20Strategy.lua)


---

## Re: MTF Two EMA Strategy

**Gerrit.van.Zyl** · Mon Feb 13, 2012 2:37 am

Thanks very much.

One question: If I want to use two time frames only, will it work if I simply set the parameters so that two of the time frames are set to for example D1, and the other two to H1?


---

## Re: MTF Two EMA Strategy

**rose123** · Mon Feb 13, 2012 3:51 am

you can set first time frame to your first small time frame , and other there time frames as your bigger time frame.

**example:**

if you want to use m15 and h1,
you can set timeframe 1 as m15 and timeframes 2,3,4 as h1


---

## Re: MTF Two EMA Strategy

**JOKER83** · Sat Apr 18, 2015 5:29 pm

**EXIT option at all timeframe**


---

## Re: MTF Two EMA Strategy

**Apprentice** · Thu Apr 23, 2015 6:20 am

Once again, if you can explain this.


---

## Re: MTF Two EMA Strategy

**JOKER83** · Thu Apr 23, 2015 10:00 am

SORRY MY ENGLISCH ITS NOT NICE

The Strategy close open trades to the
smal Timeframes
I want close open trades bigger Timeframes

Make Parameter for all Timeframes
1 Close open trades on/off
2 Close open trades on/off
3 Close open trades on/off
4 ....

sorry my englisch


---

## Re: MTF Two EMA Strategy

**Apprentice** · Mon Jan 29, 2018 7:22 am

The strategy was revised and updated.
