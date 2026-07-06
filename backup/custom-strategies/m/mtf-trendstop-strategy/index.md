# MTF TrendStop Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=23181  
> Forum: 31 · Topic 23181 · 13 post(s)


---

## MTF TrendStop Strategy

**Apprentice** · Sat Sep 08, 2012 1:41 pm

![MTF TrendStop Strategy.png](images/39921/MTF%20TrendStop%20Strategy.png)



Long
D1 Trendstop < Price
H4 Trendstop < Price
H1 Trendstop > Price
m15 Trendstop Price CrossUnder

Short
D1 Trendstop > Price
H4 Trendstop > Price
H1 Trendstop < Price
m15 Trendstop Price CrossOver

 [MTF TrendStop Strategy.lua](files/39921/MTF%20TrendStop%20Strategy.lua)

TrendStop.bin Indicator must be installed for this strategy.
You can find it here.
[viewtopic.php?f=17&t=12728](https://fxcodebase.com/code/viewtopic.php?f=17&t=12728)

The Strategy was revised and updated on January 21, 2019.


---

## Re: MTF TrendStop Strategy

**JOKER83** · Sun Apr 19, 2015 3:38 am

EXIT option at all timeframe


---

## Re: MTF TrendStop Strategy

**Apprentice** · Thu Apr 23, 2015 6:19 am

Once again.
Can you explain this.
in this form.
If {condition is met} then {do something}.


---

## Re: MTF TrendStop Strategy

**JOKER83** · Sat May 02, 2015 8:42 am

I HAVE TRADES OPEN
THE STRATEGY MAKE CLOESE
TRADES TO THE SMALL TIMEFRAME
I WANT CLOSE TRADE TO BIGGER TIMEFRAME

SAME EXIT OPTION WITH
MTF MA PRICE STRATEGY


---

## Re: MTF TrendStop Strategy

**Apprentice** · Mon Dec 12, 2016 4:31 pm

Strategy was revised and updated.


---

## Re: MTF TrendStop Strategy

**albertparis** · Tue Dec 13, 2016 5:36 am

Code: [Select all](https://fxcodebase.com/code/)
`Hello
Sorry for my English I'm French
Can you add: Custom identifier

thank you very much`


---

## Re: MTF TrendStop Strategy

**albertparis** · Fri Dec 16, 2016 8:29 am

hello

In the update there is no addition of Custom identifier

I thank you very much for your work


---

## Re: MTF TrendStop Strategy

**albertparis** · Fri Dec 16, 2016 8:49 am

Here is the file for your request I can not send it to you PV

thanks


---

## Re: MTF TrendStop Strategy

**albertparis** · Sat Dec 24, 2016 8:01 am

Bonjour

Sorry for my English I'm French
Can you add:

Code: [Select all](https://fxcodebase.com/code/)
`strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "STIS");`

If you have the code I can put it myself. Which will make it possible to put it in other strategy that you have made

Thank you for your work


---

## Re: MTF TrendStop Strategy

**albertparis** · Tue Sep 12, 2017 6:22 am

Hello
Sorry for my English I'm French
Can you add: Custom identifier

thank you very much


---

## Re: MTF TrendStop Strategy

**Apprentice** · Fri Sep 29, 2017 7:41 am

Your request is added to the development list under Id Number 3908


---

## Re: MTF TrendStop Strategy

**albertparis** · Sat Sep 30, 2017 9:33 am

> **Apprentice wrote:**
> Your request is added to the development list under Id Number 3908

Thank you for your future work


---

## Re: MTF TrendStop Strategy

**Alexander.Gettinger** · Mon Oct 16, 2017 10:53 am

> **albertparis wrote:**
> Hello
> Sorry for my English I'm French
> Can you add: Custom identifier
>
> thank you very much

Please try this version with Custom ID.

 [MTF TrendStop Strategy.lua](files/115433/MTF%20TrendStop%20Strategy.lua)
