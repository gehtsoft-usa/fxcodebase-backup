# Highly adaptable SMI BB Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=15734  
> Forum: 31 · Topic 15734 · 9 post(s)


---

## Highly adaptable SMI BB Strategy

**Apprentice** · Mon Apr 09, 2012 6:49 am

![Highly adaptable SMI BB Strategy.png](images/29602/Highly%20adaptable%20SMI%20BB%20Strategy.png)



This strategy allows you to issue orders, based on a total of 8 signals
obtained by interaction of SMI and BB indicators.
Source of BB could be, SMI line, or SMI signal line.

 [Highly adaptable SMI BB Strategy.lua](files/29602/Highly%20adaptable%20SMI%20BB%20Strategy.lua)

SMI indicator is required to use this strategy.
[viewtopic.php?f=17&t=2071&hilit=SMI](https://fxcodebase.com/code/viewtopic.php?f=17&t=2071&hilit=SMI)


---

## Re: Highly adaptable SMI BB Strategy

**stefania** · Fri Apr 20, 2012 10:52 am

hi
hope someone can help me.
im not able to run the SMi in the Trading Station, i was able to charge the Higly adaptable SMI BB Strategy.lua but, i should use the strategy as the link below told me, but it appear an error when i try to uploaded in the marketscope.
Hope to receive an answer as soon as possible.
Stefania


---

## Re: Highly adaptable SMI BB Strategy

**Apprentice** · Mon Apr 23, 2012 2:45 am

Can you specify the error.
In my testing, I have non.


---

## Re: Highly adaptable SMI BB Strategy

**stefania** · Mon Apr 23, 2012 3:39 am

ok
so first i upload from the marketscope the Highly adaptable SMI BB strategy, and this procedure gone well, then when i charge the SMI.lua if appear an error in the window of the uploading confirmation that this indicatore cannot be uploaded in this window, i change window, named charge personalized indicators, but the result is the same.
i hope i specify in a better way this time my problem


---

## Re: Highly adaptable SMI BB Strategy

**stefania** · Tue Apr 24, 2012 5:34 am

hi,
i need one more help.
i think that my problem started before cos im using windows 7, so when i try to download the lua it appear a window that asked me to save the file and the only option i can get is to save it as a notepad, so .text, i think that that's the point of my problem, cos after when i try to download it again i cannot change my previous option i choose (the notepad) and by marketscope i cannot upload those indicators and signals.
hope someone can help me
have a nice day!!!


---

## Re: Highly adaptable SMI BB Strategy

**Apprentice** · Wed Apr 25, 2012 2:58 am

I can not be sure, can you upload a screen shoot.
But I think your problem is as follows.
There are two interfaces to load indicators/strategys,
One for indicators, other for strategies.
You can not upload Strategy through Import Indicator interface, and vice versa.


---

## Re: Highly adaptable SMI BB Strategy

**Blackcat2** · Fri May 04, 2012 7:43 am

Hi apprentice,

Could you please post the parameter you used for backtesting (the screen you posted). I tried to replicate/guess your setting but couldn't get the right one..

Could you please explain how the options in the selector settings works? For example, which line of SMI that's considered in SMI Top BB Line Crossover Action setting, and what is crossover, does it mean the line crossing from top to bottom or from bottom to top?

Thanks...
BC


---

## Re: Highly adaptable SMI BB Strategy

**Apprentice** · Sun May 06, 2012 4:17 am

I used the indicators, parameters shown on the chart.

Which cross, action, I used, I can not remember.
As you know, we have a few in them.
SMI is data (green) line on SMI indicator.

CrossOver
First line cross over second.
CrossUnder
First line under second cross.


---

## Re: Highly adaptable SMI BB Strategy

**Apprentice** · Mon Dec 05, 2016 5:53 am

Bump up.
