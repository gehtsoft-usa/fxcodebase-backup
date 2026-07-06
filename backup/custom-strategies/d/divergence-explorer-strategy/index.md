# Divergence Explorer strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2841  
> Forum: 31 · Topic 2841 · 5 post(s)


---

## Divergence Explorer strategy

**Konstantin.Usanov** · Thu Dec 02, 2010 6:14 am

Hi!

I’d like to introduce **Divergence Explorer** strategy.

This strategy is based on last version of well-known dMACD(ext) strategy
(please, see topic: “(NEW) Introduce dMACD strategy (Divergence on MACD Signals)” [http://www.fxcodebase.com/code/viewtopic.php?f=31&t=1985](http://www.fxcodebase.com/code/viewtopic.php?f=31&t=1985)) and
allow to choice different indicators (not only MACD) for divergence calculation and trading.

I hope the Divergence Explorer strategy will be useful and comfortable.

 

![Divergence Explorer properties.JPG](images/6496/Divergence%20Explorer%20properties.JPG)

*Divergence Explorer properties*



 [Divergence Explorer.lua](files/6496/Divergence%20Explorer.lua)

Thanks.

The Strategy was revised and updated on December 10, 2018.


---

## Re: Divergence Explorer strategy

**Konstantin.Usanov** · Mon Dec 13, 2010 4:01 am

Hi!

There is short report about backtesting of Divergence Explorer strategy.

“Playing with volumes” as price stream (data source) I have discovered amazing result for Divergence Explorer strategy.

For example (using ordinary MACD indicator with 5,34,5 parameters),
if you choose **EUR/JPY**and **Daily**timeframe, the profit gains up to **10 M$** during three year and to 1 M$ (approx) for one year.

 

![Divergence Explorer backtesting on Volumes.JPG](images/6732/Divergence%20Explorer%20backtesting%20on%20Volumes.JPG)

*Divergence Explorer on Volumes*



Please take a look at all used properties for details.

 [All properties.zip](files/6732/All%20properties.zip)

Thanks.


---

## Re: Divergence Explorer strategy

**Jautocurr1** · Sat May 25, 2013 10:42 pm

I recently downloaded this Strategy and really like it.That's
because it is one of the few that has Margin control built in.Also
I like the ability of choosing so many different indicators for backtesting.
Is like having many Strategies all in one.
An account I am using it on right now is very small and I need
to keep at least a minimum of 30% Margin. I am only setting it
for trading 1 lot up to 2 is Ok.Trouble is it keeps on doing 3 and I
get a Margin % warning. I am setting it at 34 for 34% this way I should
be in good shape for the minimum of 30%.
 I would really like to solve this problem because it is testing very well
using the ADX Difference and making money. Otherwise I will only be able
to do manual trading. Overnight is a problem doing the manual trading for me.

Thanks,
Jim C.
"JimTrader1"


---

## Re: Divergence Explorer strategy

**crazymonkey** · Fri Jun 07, 2013 1:12 pm

Hi Konstantin,

Quick question,

I downloaded this strategy and tried testing it out, except I noticed it seemed to be Selling when it should be Buying.

I then tried using the settings you had suggested (MACD 5,34,5, DAILY TF etc) to see if I was doing something wrong, but I get the same results. Double checked everything with the ZIP file you provided, but no, same results.

I tried playing around with the money management settings etc as I have a U.S based account, but that did nothing.

Am I missing something here? I posted a screenshot of the results using your suggestions :

(FYI All the positions are sell (interestingly it shows in the statistics that there were no short trades...)


---

## Re: Divergence Explorer strategy

**Apprentice** · Fri Dec 09, 2016 6:40 am

Strategy was revised and updated.
