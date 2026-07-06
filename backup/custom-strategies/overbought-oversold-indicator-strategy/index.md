# Overbought/Oversold Indicator Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=61064  
> Forum: 31 · Topic 61064 · 13 post(s)


---

## Overbought/Oversold Indicator Strategy

**Apprentice** · Fri Aug 22, 2014 4:48 am

![Overbought Oversold Indicator Strategy.png](images/95497/Overbought%20Oversold%20Indicator%20Strategy.png)



Please Install OBOS Indicator.
[viewtopic.php?f=17&t=3664](https://fxcodebase.com/code/viewtopic.php?f=17&t=3664)

Open Long
On OB Level CrossOver
On Cental Level CrossOver
On OS Level CrossOver

Open Short
On OB Level CrossUnder
On Cental Level CrossUnder
On OS Level CrossUnder

 [Overbought Oversold Indicator Strategy.lua](files/95497/Overbought%20Oversold%20Indicator%20Strategy.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: Overbought/Oversold Indicator Strategy

**7510109079** · Mon Sep 15, 2014 10:40 am

This is a great indicator in both rangebound and trending markets. I use a CCI as confirmation.

Currently alerts are triggered in relation to a numeric value between 100 and -100.

Could we have a 2nd type/choice of alert trigger incorporated?

i.e. an option of triggering an alert with a bar colour change (not numeric value)

Four Options in this category-
 1. high risk long entry: when a bar changes from RED-to-BLUE
 2. high risk short entry: when a bar changes from GREEN-to-BLUE
 3. lower risk long entry: when a bar changes from BLUE-to-GREEN
 4. lower risk short entry: when a bar changes from BLUE-to-RED

 There would need to be an initial master choice selector to tell the program which alert trigger the user wants to use i.e. number trigger or colour trigger


---

## Re: Overbought/Oversold Indicator Strategy

**Apprentice** · Wed Sep 17, 2014 10:50 am

Your request is added to the development list.


---

## Re: Overbought/Oversold Indicator Strategy

**7510109079** · Wed Sep 17, 2014 11:41 am




---

## Re: Overbought/Oversold Indicator Strategy

**7510109079** · Tue Sep 23, 2014 6:25 am

addendum to request:
App,

Maybe to prevent false signals, and therefore allowing more customisable signals to be generated, - instead of an 'either/or' scenario, you can combine the two types of signal so that an alert/trade is only made when both conditions are satisfied

i.e.
an alert/trade will only be actioned if the chosen colour change occurs above or below a specified numeric OBOS value

so the user specifies e.g.
- high risk long entry: when a bar changes from RED-to-BLUE
AND
- OBOS value of e.g. under -75 (user set value)

thx in advance


---

## Re: Overbought/Oversold Indicator Strategy

**7510109079** · Tue Sep 23, 2014 6:31 am

just a real quickie while we are waiting for the above

Can you include user specifiable OBOS horiz lines in the GUI

...because Each time i open MScope my horiz lines i put there previously disappear. they also dont seem to being saved in a template either. Driving me nuts!

i.e.


---

## Re: Overbought/Oversold Indicator Strategy

**7510109079** · Sun Sep 28, 2014 7:07 am

dont worry about this task now as I have someone else working on it, thx


---

## Re: Overbought/Oversold Indicator Strategy

**Hpraspernickel** · Sat Nov 08, 2014 12:28 pm

Bravo! This thing is beautiful!
Ben


---

## Re: Overbought/Oversold Indicator Strategy

**Andersan** · Thu Nov 13, 2014 6:18 am

Read the "Let's develop together" articles in the "Indicator development" forum:


---

## Re: Overbought/Oversold Indicator Strategy

**lobogrande** · Sat Nov 15, 2014 5:14 pm

Was this strategy updated to trigger when the colors change?


---

## Re: Overbought/Oversold Indicator Strategy

**easytrading** · Tue Nov 18, 2014 3:52 am

Hello Apprentice,

 is it posibole to develop a second version of this strategy based on indicator's bar color changing ? as it was requested in detial by 7510109079 and lobogrande .

thank you as always.


---

## Re: Overbought/Oversold Indicator Strategy

**Apprentice** · Thu Nov 20, 2014 5:37 am

Requested can be found here.
[viewtopic.php?f=31&t=61489](https://fxcodebase.com/code/viewtopic.php?f=31&t=61489)


---

## Re: Overbought/Oversold Indicator Strategy

**Apprentice** · Sun Dec 11, 2016 10:23 am

Strategy was revised and updated.
