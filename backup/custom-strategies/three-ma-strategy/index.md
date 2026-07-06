# Three MA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=3402  
> Forum: 31 · Topic 3402 · 18 post(s)


---

## Three MA Strategy

**Apprentice** · Mon Feb 14, 2011 8:18 am

![Three MA Strategy.png](images/8122/Three%20MA%20Strategy.png)



case 1 : Fast crossover Slow above VerySlow = buy
case 2 : Fast crossdown Slow above VerySlow = close long positions
case 3 : Fast crossdown Slow below VerySlow = sell
case 4 : Fast crossover Slow below VerySlow = close short positions

 [Three MA Strategy.lua](files/8122/Three%20MA%20Strategy.lua)

To work install 20 in 1 Moving Average Indicator a.k.a. Averages
[viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)


---

## Re: Three MA Strategy

**basicstrategy** · Mon Feb 14, 2011 2:41 pm

dear Apprentice,

is it possible to add the shift factor to each moving average setting please ? (i need that setting actually ...)

thank you again ...


---

## Re: Three MA Strategy

**basicstrategy** · Tue Feb 15, 2011 4:29 am

trades won't close unless the 3 ma cross again

the idea is that it takes profits many times in a trend...

I have attached a picture that shows what I mean.

thank you again in advance


---

## Re: Three MA Strategy

**basicstrategy** · Tue Feb 15, 2011 4:45 am

here's another picture to show you what i mean.
(in this case, the trade was profitable but many times it is not)

When the market ranges, if my trades close on the cross of Fast and Middle, then i make a profit.
But if it must wait for the 3 ma to cross again, then it is a loss each time.

thank you very much in advance.

BasicStrategy


---

## Re: Three MA Strategy

**Apprentice** · Tue Feb 15, 2011 5:39 am

Fixed.


---

## Re: Three MA Strategy

**basicstrategy** · Tue Feb 15, 2011 9:17 am

thank you very much


---

## Re: Three MA Strategy

**basicstrategy** · Fri Feb 18, 2011 10:48 am

please can you add the possibility to shift the middle and slow MA ?

thank you very much in advance.

BasicStrategy


---

## Re: Three MA Strategy

**Apprentice** · Mon Feb 28, 2011 10:00 am

Your request has been added to the developmental cue.


---

## Re: Three MA Strategy

**fskliris** · Wed Mar 02, 2011 2:08 pm

Hallo,
 wonderful system.
 If possible can you add this in your formula ,so that a trade opens short when we have fast cross down below very slow, while the slow is above slow, or the opposite a trade opens long when we have fast cross over above very slow while slow is below very slow? If you can do that it would be wonderful . Many thanks.


---

## Re: Three MA Strategy

**golady9** · Sun Jul 10, 2011 10:20 am

> **basicstrategy wrote:**
> dear Apprentice,
>
> is it possible to add the shift factor to each moving average setting please ? (i need that setting actually ...)
>
> thank you again ...

Is the THREE MA strategy with shift value ready?

thanks


---

## Re: Three MA Strategy

**Apprentice** · Wed Nov 30, 2016 7:41 am

Bump up.


---

## Re: Three MA Strategy

**LoneWolf** · Tue Nov 06, 2018 7:30 pm

I played the last day a bit with this strategy and it seems to work in the backtesting and simulation.
When i go on the real market. I see this in the strategy dashboard.

"Allow trading : No"
in the setings of the strategy it is set on "Yes"

a bug ?
at the moment i do not know if the bot open a trade or not.


---

## Re: Three MA Strategy

**Apprentice** · Mon Nov 12, 2018 12:24 pm

Done! There was no trading flag


---

## Re: Three MA Strategy

**AEKARAOLE** · Tue Jan 15, 2019 10:21 am

Hi apprentice,

Can we add another one option of closing transactions? That is, when we have a buy trade to close the position in the next resistance of Fibonacci retracement and when we have a sales trade to close in the next support of Fibonacci retracement?

Thank you


---

## Re: Three MA Strategy

**Apprentice** · Mon Jan 21, 2019 9:02 am

Your request is added to the development list under Id Number 4436


---

## Re: Three MA Strategy

**wmorgan100** · Thu Jan 24, 2019 12:07 pm

> **Apprentice wrote:**
> Fixed.

Where can i download the latest strategy referenced..Thanks


---

## Re: Three MA Strategy

**Apprentice** · Tue Feb 05, 2019 5:52 am

[Three MA with Pivot Point Strategy.lua](files/123713/Three%20MA%20with%20Pivot%20Point%20Strategy.lua)

Try this version.


---

## Re: Three MA Strategy

**AEKARAOLE** · Tue Feb 05, 2019 6:52 am

Thank you apprentice
