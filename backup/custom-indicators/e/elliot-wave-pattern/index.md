# Elliot Wave Pattern

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=2380  
> Forum: 17 · Topic 2380 · 17 post(s)


---

## Elliot Wave Pattern

**richardtao** · Tue Oct 12, 2010 1:53 am

The EWP indicator version 1 is applying of Trading Station II. The target user is experienced trader.

EWP stands for Elliot Wave Pattern.
The purpose is to indentify Elliot Wave related apply at a glance.
This indicator including three parts:
The first part is Elliot Wave Specify. The first two parameters are
"Minimum Periods of Main Trend." And "Minimum Periods of Wave”
The personal suggest that the best parameter setting 30,5 on W1, and 50,12 on D1.
You can also let indicator select best fit period just set second parameter as 0.
When you get used to count Elliot Wave, you could set parameter “ShowWaveNo” as false.

The second part is basic Price Pattern Specify.
This version checks only 6 types: "Stair","Flag","SharpV","Double","Triple","Longfloor".
These patterns will appear in difference wave status.
These patterns are used by my trading strategies. You may reference as well.
If you do not like those pattern and probability, you could set parameter “ShowPattern” as false.

The third part is Fibonacci Analysis.
The mark only calculate the significant retrace at .382 & .618, the extension at .618, 1.0 ,1.618 levels.
If you like to hide those levels, you could set parameter “ShowFib” as false.

There are many subjects need to be improved in next version. Such as Weighting most popular price patterns, Specifying non-classic wave by ma, Verifying price direction probability by back test.

Any feedback is welcome.

The indicator was revised and updated


---

## Re: Elliot Wave Pattern

**Apprentice** · Tue Oct 12, 2010 3:28 am

Finally, someone started working on this problem.

But there are many problems to be solved.
I had a document that describes the Elliott wave pattern.
But it seems that I lost It.

When you find it I'll send it to you in order to eliminate deficiencies.


---

## Re: Elliot Wave Pattern

**richardtao** · Tue Oct 12, 2010 8:58 pm

hi there
A hurry useally accompany with some mistake.
Execuse me for typing error. the word "Elliot Wave" ought to be "Elliott Wave".

If someone find any could be imporvement, please kindly notice me.
looking forward of so call document.


---

## Re: Elliot Wave Pattern

**mgammal** · Fri Nov 25, 2011 3:04 pm

Thank you very much.. it is a very fascinating effort. I am not sure of the correctness of the wave counting though as it would sometimes tend to count a wave with a lower low in a dropping trend as 2 or 4 which should be the retrace waves.

Please accept my thanks once again,
Gammal


---

## Re: Elliot Wave Pattern

**mgammal** · Fri Nov 25, 2011 3:06 pm

Can you also please tell me a strategy that works well with this indicator. i am sure this is a very profiting indicator and i can see its usefulness very well. it combines between both Zigzag and EW.


---

## Re: Elliot Wave Pattern

**richardtao** · Sun Nov 27, 2011 9:19 pm

hello mgammal,

please check with new version of wave indicator TWP.
there are some descriptions of project mark.
[viewtopic.php?f=17&t=7023#p15770](https://fxcodebase.com/code/viewtopic.php?f=17&t=7023#p15770)
my favor strategy is the extension of 135, therefore, the focus is on the wave pattern 24.
perhaps this would help.

regards, richard.


---

## Re: Elliot Wave Pattern

**bomberone3** · Mon Nov 28, 2011 12:41 pm

This is a great indicator, is it possible to convert in a strategy to see how much is it profitable?


---

## Re: Elliot Wave Pattern

**bomberone3** · Mon Nov 28, 2011 3:08 pm

Folks is it possible convert this indicator in strategy?
COuld someone do any test and posto the best reult to trade eurusd or the 7 major?

 EUR / USD -
 USD / CHF -
 USD / JPY -
 GBP / USD -
 USD / CAD -
 AUD / USD -


---

## Re: Elliot Wave Pattern

**bomberone3** · Mon Nov 28, 2011 3:11 pm

Is it possible add pesavento pattern?


---

## Re: Elliot Wave Pattern

**mgammal** · Wed Nov 30, 2011 6:13 am

thanks Richard.. i have already tried the new version but it keeps resetting and erroring everytime a new candle appears. i use it on m15, EURUSD


---

## Re: Elliot Wave Pattern

**mgammal** · Wed Nov 30, 2011 7:14 am

Actually Richard both of them error at the same moment.. it says: "An error occurred during the calculation of the indicator 'TWP'. The error details: [string "TWP.lua"]:125: Index is out of range."


---

## Elliot Wave Pattern

**EroHumanFego** · Wed Nov 30, 2011 4:24 pm

Summary :

 According to the Elliott Wave Theory, the market moves in repetitive patterns called waves.

 A trending market moves in a 5-3 wave pattern. The first 5-wave pattern are called impulse waves. The second 3-wave pattern are called corrective waves.

 If you look hard enough at a chart, youll see that the market really does move in waves.


---

## Re: Elliot Wave Pattern

**richardtao** · Thu Dec 08, 2011 5:30 am

hello bomberone3,
regarding to your message,
the topic what i am focus on is predictor which the forecast may not appear everytime.
i am not sure whether it is suitable for the auto trading strategy?

the pesavento pattern is complicated, it will take time to impliment.
i see what i can do in the future.
regards,
richard.


---

## Re: Elliot Wave Pattern

**richardtao** · Thu Dec 08, 2011 5:40 am

hello mgammal,
i am aware the error.
it will be fixed in next version to TWP
i am deeply appreciated!

rdgs,richard


---

## Re: Elliot Wave Pattern

**Apprentice** · Sat Mar 18, 2017 8:00 am

Indicator was revised and updated.


---

## Re: Elliot Wave Pattern

**marcelo2k9** · Sun Aug 17, 2025 4:59 pm

Please Sir can u help us with the mt5


---

## Re: Elliot Wave Pattern

**Apprentice** · Mon Aug 18, 2025 7:06 am

We have added your request to the development list.
Development reference 515
