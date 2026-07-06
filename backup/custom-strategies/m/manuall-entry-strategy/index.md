# Manuall Entry Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=12455  
> Forum: 31 · Topic 12455 · 17 post(s)


---

## Manuall Entry Strategy

**Apprentice** · Mon Jan 30, 2012 4:28 am

![Manuall Enty Strategy.png](images/24588/Manuall%20Enty%20Strategy.png)



This simple strategy opens trade, if Price Cross Over / Under User-defined Level.
It is possible to define a zone added up / down from entry line.
It is possible to define the minimum bar size, from open to close, in the direction of trade.

 [Manuall Entry Strategy.lua](files/24588/Manuall%20Entry%20Strategy.lua)

 [Tick Manual Entry Strategy.lua](files/24588/Tick%20Manual%20Entry%20Strategy.lua)

The Strategy was revised and updated on January 22, 2019.


---

## Re: Manuall Entry Strategy

**coldplay70** · Sun Nov 25, 2012 2:29 pm

Hello Apprentice,

I downloaded from the website "fxcodebase" your "manual entry strategy". This I think is very good and I have achieved in my back test mode with my entries and exits good results! Next, I want to test this strategy on my demo account! I would therefore like to ask you if you could change the following parameters in your strategy:

1. Please change the Trading Parameters "Allow Multiple" of true or false to 1, 2, 3, ... trades per day in the same direction when the first trade is stopped out! Thus, the trades and the risk per day are limited when the volatility is high, and the trend is constantly changing direction.

2. Please change the Trading Parameters "Trailing Stop"! Here I think it is good if a trailing stop of 5, 10, 15, 20 ..... pips could determine.

I hope you can change these parameters accordingly and send them to me as an update again!


---

## Re: Manuall Entry Strategy

**Apprentice** · Mon Nov 26, 2012 6:13 am

Your request is added to the development list.


---

## Re: Manuall Entry Strategy

**Stance** · Wed Sep 09, 2015 1:28 am

Hi,

Instead of manually putting in an "Entry Level" I want to modify the code to use a horizontal line drawn on the chart as the Entry level.

What is the code to get a "horiztonal line" on the chart as an Entry Level?


---

## Re: Manuall Entry Strategy

**Apprentice** · Thu Sep 10, 2015 6:34 am

Unfortunately it will not be possible.
The only way to do this is to use helper indicator that will draw this line for you.
Or Enter line start / stop level / date from strategy parameter section and compute line internally.


---

## Re: Manuall Entry Strategy

**xpertizetrading** · Mon Oct 26, 2015 5:15 am

Is it possible to add a feature "Close on Opposite: Yes/No"

Thanks,
Xpertizetrading


---

## Re: Manuall Entry Strategy

**Apprentice** · Tue Oct 27, 2015 4:09 am

"Close On Opposite" option already exists, Can you elaborate.


---

## Re: Manuall Entry Strategy

**xpertizetrading** · Tue Nov 03, 2015 9:09 am

Got it Apprentice,

Thanks. I downloaded it again. I had the older version installed previously.


---

## Re: Manuall Entry Strategy

**Apprentice** · Wed Nov 04, 2015 8:55 am

Tick Manual Entry Strategy.lua Added.


---

## Re: Manuall Entry Strategy

**hiepbg** · Fri Aug 05, 2016 9:59 am

> **Apprentice wrote:**
> Tick Manual Entry Strategy.lua Added.

Thanks for your code. It's great !

When i choose timeframe t1, it show "attemp to index field 'close' (a nil value). And i can't use it.

Please, can you fix it.
Thank you very much


---

## Re: Manuall Entry Strategy

**Apprentice** · Mon Aug 08, 2016 6:11 am

Try it now.


---

## Re: Manuall Entry Strategy

**hiepbg** · Mon Aug 08, 2016 3:37 pm

> **Apprentice wrote:**
> Try it now.

Thank you very much,


---

## Re: Manuall Entry Strategy

**hiepbg** · Sun Oct 23, 2016 5:37 am

Hello Apprentice,

I have tested Manual Entry Strategy. It works fine, but "Max Number Of Open Position In Any Direction" does not work properly.

With "Max Number Of Position In One Direction" is 1, there is only one trade was executed when the price surpass the entry level. But the number of all opened positions always bigger than "Max Number Of Open Position In Any Direction".

I mean, this strategy must be stop trading when the number of all opened positions surpass the "Max Number Of Open Position In Any Direction".

Can you fix it ? It will be a great option to prevent loss when trading.

Thank you,


---

## Re: Manuall Entry Strategy

**Apprentice** · Mon Oct 24, 2016 3:26 am

Try to set CloseOnOpposite to NO.
If CloseOnOpposite is set to YES.
Any new position will close any previous position of opposite direction.


---

## Re: Manuall Entry Strategy

**hiepbg** · Mon Oct 24, 2016 9:58 am

It's not what i want. Sorry for my english.
This is what i really want It's will make your strategy perfectly.

> http://fxcodebase.com/code/viewtopic.php?f=32&t=64008


---

## Re: Manuall Entry Strategy

**hiepbg** · Sun Nov 06, 2016 2:13 pm

Hello,
Recently, I have some trade with these settings:
Min Entry Level Crossover in Pips: 40
Close on Opposite: Yes.

When i open a new trade at price X, if the price go down 40 pips, strategy will close that trade.
But this strategy can only open a new trade at price X again. If it open a new trade at lower price X-40, it will take a advantage to gain more profit and decrease total loss (it can gain more 40 pips, equal with the loss of first trade).
Can you develope this feature ?

Thank you very much,


---

## Re: Manuall Entry Strategy

**Apprentice** · Wed Jan 03, 2018 11:36 am

The strategy was revised and updated.
