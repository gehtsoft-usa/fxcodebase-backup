# Multi Time Frame Stochast

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7955  
> Forum: 31 · Topic 7955 · 7 post(s)


---

## Multi Time Frame Stochast

**Apprentice** · Wed Nov 09, 2011 9:10 am

![Multi Time Frame Stochastic Strategy.png](images/17619/Multi%20Time%20Frame%20Stochastic%20Strategy.png)



Indicators:

Stochastic m5(mva,5,3,3)
With buy entry level 20
With sell entry level 80
Stochastic H15(mva 5,3,3)
With over bought level 80
With over sold level 20
Stochastic H1 (mva 5,3,3)
With over bought level 80
With oversold level 20
Stochastic H4 (mva 5,3,3)
With over bought level 80
With oversold level 20

Bullish trade when:

1.	Stochastic k>d in H4 and k< over bought level {80}{and}
2.	Stochastic k>d in H1 and k< over bought level {80}{and}
3.	Stochastic k>d in m15 and k<over bought level {80}{and}
4.	Stochastic D of h1 >stochastic D of h4{and}
5.	Stochastic D of m15 >stochastic D of h1{and}
6.	Stochastic D of m5 cross oversold level {20}

Bearish trade when:
1.	Stochastic k<d in h4 and k> over sold level{20}
2.	stochastic k<d in h1 and k>over sold level{20}
3.	stochastic k<d in m15 and k>over sold level{20}
4.	stochastic d of h1 < stochastic d of h4
5.	stochastic d of m15 < stochastic d of h1
6.	Stochastic D of m5 cross under over bought level{80}

Exit long when:

1.	stochastic d of m5 cross under overbought level{80} or
2.	stochastic d of h1 cross under stochastic d fo h4
3.	stochastic d of m15 cross under stochastic d fo h1
4.	stochastic k cross under d in m15
5.	stochastic k cross under d in h1
6.	stochastic k cross under d in h4

exit short when:

1.	stochastic d of m5 cross over overbought level {20}
2.	stochastic d of h1 cross over stochastic d of h4
3.	stochastic d of m15 cross over stochastic d of h1
4.	stochastic k cross over d in m15
5.	stochastic k cross over d in h1
6.	stochastic k cross over d in h4

 [Multi Time Frame Stochastic Strategy.lua](files/17619/Multi%20Time%20Frame%20Stochastic%20Strategy.lua)


---

## Re: Multi Time Frame Stochast

**virgilio** · Fri Nov 25, 2011 12:03 pm

Hello, I am trying to use this automatic strategy on a 15-min chart (EUR/USD) for the past 3 day. I only get occasional alerts (see below) but not actual trades. I am using the latest download.
Any adice will be highly appreciated.

Strategy Alert Messages:
MULTI TIME FRAME STOCHASTIC STRATEGY( EUR/USD(m15, 5, 3, 3, MVA, MVA, 82, 24) (m30, 5, 3, 3, MVA, MVA, 84, 2) (H1, 5, 3, 3, MVA, MVA, 73, 21) (H4, 5, 3, 3, MVA, MVA, 94, 12) ) is started.


---

## Re: Multi Time Frame Stochast

**Exolon** · Tue Dec 13, 2011 10:21 pm

Hi guys,

I have a question which may seem a little ignorant, as I'm certainly missing some fundamental understanding of markets and careful trading practices.
Backtesting this strategy gives promising results when multiple trades are allowed, but as with a couple of other strategies, it can lead to having a very large number of open trades which makes it difficult or impossible to automatically manage risk.
For example, I usually set the lot size to 1, but in backtests, this strategy might open 20 short trades within one day. The potential for profit is large, but so is the potential for the entire margin to be wiped out.

What I'm looking for is some more fine-grained risk management in the strategies. For example, to add a rule like "if every open trade including this one went bad and was stopped out, and the resulting balance went below X, then DO NOT open a new trade".
It doesn't really make much sense to apply this kind of rule by modifying the source code of every strategy (although it looks like that may be necessary for now?). Ideally, we could perhaps add a set of constraints to each running strategy, like a filter chain which can reject (or modify?) orders submitted by the strategy.

Would this kind of thing be possible/plausible? Is it already implemented somewhere?

If not, could you perhaps give me a hint at how to at least add something like this to (for example) the MTF Stochastic strategy?
I'm not sure how to easily determine the hypothetical account balance if all open trades were stopped out, but I guess all the information needed is available in the API?

many thanks!


---

## Re: Multi Time Frame Stochast

**Apprentice** · Wed Dec 14, 2011 3:12 am

That something is possible, for some time now plans to offer features that would enable some advanced options but can not seem to find the time.


---

## Re: Multi Time Frame Stochast

**allmobilez** · Wed Feb 22, 2012 2:36 am

A newbie question how to use this stratgey on 2 timeframes only and how on 3 time frames only
Thanks in advance


---

## Re: Multi Time Frame Stochast

**Apprentice** · Wed Feb 22, 2012 4:37 am

Unfortunately this is an asymmetric strategy.
And something like this is not possible.
The new strategy is needed.
Can you describe what you envisioned.


---

## Re: Multi Time Frame Stochast

**Apprentice** · Sat Jan 27, 2018 6:04 am

The strategy was revised and updated.
