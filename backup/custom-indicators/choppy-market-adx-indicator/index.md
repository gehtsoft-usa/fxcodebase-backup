# Choppy market ADX Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64999  
> Forum: 17 · Topic 64999 · 20 post(s)


---

## Choppy market ADX Indicator

**Apprentice** · Wed Aug 16, 2017 6:24 pm

![AUDNZD H2 (08-16-2017 2332).png](images/114241/AUDNZD%20H2%20%2808-16-2017%202332%29.png)



Based on the request.
[viewtopic.php?f=27&t=64992](https://fxcodebase.com/code/viewtopic.php?f=27&t=64992)

 [Choppy market ADX Indicator.lua](files/114241/Choppy%20market%20ADX%20Indicator.lua)

 [Choppy market ADX Indicator with Alert.lua](files/114241/Choppy%20market%20ADX%20Indicator%20with%20Alert.lua)

 [Non-Standard Time Frame Choppy market ADX Indicator with Alert.lua](files/114241/Non-Standard%20Time%20Frame%20Choppy%20market%20ADX%20Indicator%20with%20Alert.lua)

Smoothed_ADX.lua Is available here.
[viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX](https://fxcodebase.com/code/viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX)


---

## Re: Choppy market ADX Indicator

**jrichardson83** · Wed Aug 16, 2017 9:15 pm

Hey thanks a lot Apprentice. Nearly perfect. I actually have a growing list of ADX specific indicator alterations, based on the book written by Dr. Charles Schapp entitled ADXellence: Power Trend Strategies.

For right now can we add the following parameters:
Show Border Yes/No
Border Style Solid line/Dashed...etc
Border Width 1,2...etc

Signal Style (Wingdings #...for example 238)

Also, can we add a parameter to indicate the candle which has closed either above or below the candle that first gave the signal? I'm thinking of something minor such as a dot or circle or something like that.

Finally, I would like an alert function. By the way, does TS support email? I imagine it would.


---

## Re: Choppy market ADX Indicator

**Apprentice** · Thu Aug 17, 2017 3:14 am

If we have Up Arrow, Second signal will be given if candle crossover Up arrow high.
Vice versa for Down Arrow.
Is this correct?


---

## Re: Choppy market ADX Indicator

**jrichardson83** · Thu Aug 17, 2017 8:34 am

> **Apprentice wrote:**
> If we have Up Arrow, Second signal will be given if candle crossover Up arrow high.
> Vice versa for Down Arrow.
> Is this correct?

Yes, it is only a minor alteration but that is correct. The candle that crosses the high/low and closes above/below of the candle which initially gave the signal would be indicated by some character, like a wingding asterisk (*****) or a dot.


---

## Re: Choppy market ADX Indicator

**Apprentice** · Fri Aug 18, 2017 3:18 am

> I actually have a growing list of ADX specific indicator alterations, based on the book written by Dr. Charles Schapp entitled ADXellence: Power Trend Strategies.

Can you send me pdf of book?


---

## Re: Choppy market ADX Indicator

**Apprentice** · Fri Aug 18, 2017 3:55 am

> does TS support email?

Sure.


---

## Re: Choppy market ADX Indicator

**Apprentice** · Fri Aug 18, 2017 4:01 am

Try it now.


---

## Re: Choppy market ADX Indicator

**jrichardson83** · Fri Aug 18, 2017 11:46 am

> **Apprentice wrote:**
>
>
> > I actually have a growing list of ADX specific indicator alterations, based on the book written by Dr. Charles Schapp entitled ADXellence: Power Trend Strategies.
>
>
> Can you send me pdf of book?

I sent you an email with a google drive link


---

## Re: Choppy market ADX Indicator

**nookie** · Fri Aug 18, 2017 2:48 pm

Can this be translated please for MT4 ? would be great..


---

## Re: Choppy market ADX Indicator

**Apprentice** · Sat Aug 19, 2017 2:51 pm

Your request is added to the development list, Under Id Number 3863
 If someone is interested to do this task, please contact me.


---

## Re: Choppy market ADX Indicator

**jrichardson83** · Sun Sep 03, 2017 10:53 pm

Can we add an alert/email function to this indicator for the 1) +DMI/-DMI cross and 2) ADX above "level"


---

## Re: Choppy market ADX Indicator

**Apprentice** · Mon Sep 04, 2017 7:14 am

Choppy market ADX Indicator with Alert.lua added.


---

## Re: Choppy market ADX Indicator

**jrichardson83** · Wed Sep 20, 2017 5:17 pm

Apprentice,

Can a Paint Bar option be added as a choice for identifying candles in the "chop" zone? Like, add an additional parameter that says something like

Draw Box

or

Draw Paint Bar

And then just a parameter to change the paint bar color.


---

## Re: Choppy market ADX Indicator

**Apprentice** · Thu Sep 21, 2017 4:58 am

Try it now.


---

## Re: Choppy market ADX Indicator

**jrichardson83** · Thu Sep 21, 2017 12:25 pm

> **Apprentice wrote:**
> Try it now.

Thanks Apprentice!

Just a few minor tweaks. Can we use the new code you've added with the updated Choppy Market ADX Indicator with the alert function, rather than the old version of the indicator without the alerts function.

Also, can we use the code for the paint bars that was used to develop this indicator

 [Custom Style Moving Average Paint Bar.lua](files/115044/Custom%20Style%20Moving%20Average%20Paint%20Bar.lua)

I want to able to keep all my candles that are outside the "choppy market" normal, i.e., an unfilled white candle up and a filled black candle down. Only the candles that fall in the "chop" zone will be painted.


---

## Re: Choppy market ADX Indicator

**Apprentice** · Sat Sep 23, 2017 4:26 am

Your request is added to the development list, Under Id Number 3901
 If someone is interested to do this task, please contact me.


---

## Re: Choppy market ADX Indicator

**Apprentice** · Tue Sep 26, 2017 3:16 pm

![EURUSD H1 (09-26-2017 2026).png](images/115106/EURUSD%20H1%20%2809-26-2017%202026%29.png)



Try this version.

 [Choppy market ADX Indicator.lua](files/115106/Choppy%20market%20ADX%20Indicator.lua)

Smoothed_ADX.lua Is available here.
[viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX](https://fxcodebase.com/code/viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX)


---

## Re: Choppy market ADX Indicator

**jrichardson83** · Wed Sep 27, 2017 11:58 am

Apprentice,

Thanks so much, but what happened to the alert/email function?


---

## Re: Choppy market ADX Indicator

**Alexander.Gettinger** · Fri Sep 29, 2017 11:23 am

> **nookie wrote:**
> Can this be translated please for MT4 ? would be great..

MT4 version of the indicator: [viewtopic.php?f=38&t=65132&p=115164#p115164](https://fxcodebase.com/code/viewtopic.php?f=38&t=65132&p=115164#p115164)


---

## Re: Choppy market ADX Indicator

**Apprentice** · Fri Sep 07, 2018 11:19 am

The Indicator was revised and updated.
