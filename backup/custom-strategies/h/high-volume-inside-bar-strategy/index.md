# HIGH VOLUME INSIDE BAR STRATEGY

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=62883  
> Forum: 31 · Topic 62883 · 8 post(s)


---

## HIGH VOLUME INSIDE BAR STRATEGY

**Apprentice** · Fri Nov 13, 2015 7:00 am

![HIGH VOLUME INSIDE BAR STRATEGY.png](images/103357/HIGH%20VOLUME%20INSIDE%20BAR%20STRATEGY.png)



Based on request.
[viewtopic.php?f=27&t=62877](https://fxcodebase.com/code/viewtopic.php?f=27&t=62877)

BUY:
1.HIGH(PERIOD)<HIGH(PERIOD-1)
AND LOW(PERIOD)>LOW(PERIOD-1)
2. VOLUME(PERIOD)>VOLUME (PERIOD -1)
3. CLOSE(PERIOD-1)>OPEN(PERIOD-1)

SELL:
1. HIGH(PERIOD)<HIGH(PERIOD-1)
AND LOW(PERIOD)>LOW(PERIOD-1)
2. VOLUME(PERIOD)>VOLUME (PERIOD -1)
3. CLOSE(PERIOD-1)<OPEN(PERIOD-1)

 [HIGH VOLUME INSIDE BAR STRATEGY.lua](files/103357/HIGH%20VOLUME%20INSIDE%20BAR%20STRATEGY.lua)


---

## Re: HIGH VOLUME INSIDE BAR STRATEGY

**Apprentice** · Wed Dec 14, 2016 3:34 am

Strategy was revised and updated.


---

## Re: HIGH VOLUME INSIDE BAR STRATEGY

**efh123** · Tue Jan 24, 2017 10:32 am

Hi there,

thank you for the strategy. may i ask about an indicator please?
maybe also for outside bars.

best regards


---

## Re: HIGH VOLUME INSIDE BAR STRATEGY

**Apprentice** · Tue Jan 24, 2017 1:22 pm

As this implementations?
[viewtopic.php?f=17&t=43376&hilit=INSIDE+BAR](https://fxcodebase.com/code/viewtopic.php?f=17&t=43376&hilit=INSIDE+BAR)
[viewtopic.php?f=17&t=1838&hilit=INSIDE+BAR](https://fxcodebase.com/code/viewtopic.php?f=17&t=1838&hilit=INSIDE+BAR)


---

## Re: HIGH VOLUME INSIDE BAR STRATEGY

**Apprentice** · Thu Jan 25, 2018 5:01 am

The strategy was revised and updated.


---

## Re: HIGH VOLUME INSIDE BAR STRATEGY

**Zc263547** · Wed Apr 10, 2019 7:40 pm

what is the mean of volume? total or net?or buy? or sell?


---

## Re: HIGH VOLUME INSIDE BAR STRATEGY

**Zc263547** · Thu Apr 11, 2019 11:30 am

what i mean is,mt4 has the indicator volume,and fxcm chart has the indicator of direction real volume and so on, which is your strategy volume refer to? thanks


---

## Re: HIGH VOLUME INSIDE BAR STRATEGY

**Apprentice** · Fri Apr 26, 2019 6:59 am

Tick volume was used.
Tick volume represents the number of price changes per candle.
