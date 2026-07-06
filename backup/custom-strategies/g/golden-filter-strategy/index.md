# Golden Filter Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=27333  
> Forum: 31 · Topic 27333 · 2 post(s)


---

## Golden Filter Strategy

**Apprentice** · Mon Dec 03, 2012 1:45 pm

![Golden Filter Strategy.png](images/47770/Golden%20Filter%20Strategy.png)



Strategy is based on GoldenFilter Indicator
[posting.php?mode=edit&f=17&p=47668](https://fxcodebase.com/code/posting.php?mode=edit&f=17&p=47668)

Long
ShortMA / LongMA CrossOver
MACD > SIGNAL
DIP > DIM
Force Index > 0
DeMarker > 0.5
Momentum > 100
RSI > 50

Short
ShortMA / LongMA CrossUnder
MACD < SIGNAL
DIP < DIM
Force Index < 0
DeMarker < 0.5
Momentum < 100
RSI < 50

Exit (Optinal)
If one of selected filters have contradictory indication trade is closed.

 [Golden Filter Strategy.lua](files/47770/Golden%20Filter%20Strategy.lua)

Install DeMarker Oscillator & Force Index Indicators & Momentum Indicators

 DeMarker Oscillator (DEM)
[viewtopic.php?f=17&t=22&p=5795&hilit=DeMarker#p5795](https://fxcodebase.com/code/viewtopic.php?f=17&t=22&p=5795&hilit=DeMarker#p5795)

Force Index (AEFI)
[viewtopic.php?f=17&t=1966&p=36260&hilit=Force+Index#p36260](https://fxcodebase.com/code/viewtopic.php?f=17&t=1966&p=36260&hilit=Force+Index#p36260)

 Momentum Indicators
[viewtopic.php?f=17&t=896&p=19291&hilit=momentum#p19291](https://fxcodebase.com/code/viewtopic.php?f=17&t=896&p=19291&hilit=momentum#p19291)

The Strategy was revised and updated on December 10, 2018.


---

## Re: Golden Filter Strategy

**Apprentice** · Thu Dec 08, 2016 3:41 pm

Strategy has been revised and updated.
