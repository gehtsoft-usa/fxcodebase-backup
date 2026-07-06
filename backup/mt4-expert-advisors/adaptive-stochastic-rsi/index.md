# Adaptive Stochastic RSI

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=61260  
> Forum: 38 · Topic 61260 · 2 post(s)


---

## Adaptive Stochastic RSI

**ThemBonez** · Thu Sep 25, 2014 11:26 am

Hello
I would like to contribute this adaptive Stochastic RSI indicator I have created.
Overall it works, but there are a couple of problems that I can't figure out.
Download the code and check it out.

It analyzes 4 different parameter settings:
34,21,13,13
 21,13,8,8
13,8,5,5
 8,5,3,3

Looking for 2 consecutive K/D Crossovers-
One in oversold range -
One in overbought range - In either order.

It uses the highest set that meets the criteria to draw indicator lines
If none of them meet the criteria,
it will draw the lines using the 8,5,3,3 settings and alert not to trade.

The problems I am having are:

1: It doesn't draw the indicator lines when the settings are 34,21,13,13
2: It doesn't always draw the level lines at the oversold and overbought regions on the chart at 75 and 25. I used Object_Create to draw them
3: Sometimes it gets hung up and doesn't do anything.
 I think this happens when either K=D, in which I would like it to got to the next bar and continue analyzing; or it doesn't find the above criteria on any of the settings....in which I would like it to use the 8,5,3,3 settings and give an alert not to trade the pair.

If anyone could help me figure out these issues, it would be greatly appreciated.

 [Adaptive Stoch_RSI.mq4](files/96208/Adaptive%20Stoch_RSI.mq4)

Thank You
ThemBonez


---

## Re: Adaptive Stochastic RSI

**ThemBonez** · Thu Sep 25, 2014 3:02 pm

I made some changes based on debugging and on strategy and its working like a charm except for one issue.
As far as strategy,
I reversed the order of priority for the settings, so that the lowest settings get first priority in this order:
8,5,3,3
13,8,3,3
21,13,8,8
34,21,13,13

The only issue I am having is that when the 8,5,3,3 settings are chosen,
for some reason it doesn't draw the lines.

Attached is the new file.

If you can see what's wrong, please let me know.

 [Adaptive Stoch_RSI.mq4](files/96212/Adaptive%20Stoch_RSI.mq4)

Thanx
ThemBonez
