# Highly adaptable Bollinger Band Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63644  
> Forum: 31 · Topic 63644 · 31 post(s)


---

## Highly adaptable Bollinger Band Strategy

**Apprentice** · Tue Jul 05, 2016 3:07 pm

![EURUSD m5 (07-05-2016 2135).png](images/107009/EURUSD%20m5%20%2807-05-2016%202135%29.png)



You can decide which action strategy will take if we have Top/Bottom/Centaral line cross over/under.

Actions can be.
Close Position, Open Short or Long Position, take no action, Give Alert.

 [Highly adaptable Bollinger Band Strategy.lua](files/107009/Highly%20adaptable%20Bollinger%20Band%20Strategy.lua)

 [Highly adaptable Bollinger Band Strategy with Trend Stop Filter.lua](files/107009/Highly%20adaptable%20Bollinger%20Band%20Strategy%20with%20Trend%20Stop%20Filter.lua)

TrendStop is available here.
[viewtopic.php?f=17&t=12728&hilit=TRENDSTOP](https://fxcodebase.com/code/viewtopic.php?f=17&t=12728&hilit=TRENDSTOP)

MT4/MQ4 version is available here
[viewtopic.php?f=38&t=64536](https://fxcodebase.com/code/viewtopic.php?f=38&t=64536)


---

## Re: Highly adaptable Bollinger Band Strategy

**lendoo** · Fri Jul 08, 2016 1:22 pm

Hi!

Thanks for the smart responze
but I would like to ask a little upgrade still:
Parameters:
 - end of turn/live choosing
Selector
 - and duplicate the selector menu with
 top line touch
 bottom line touch
 central line touch

 Thank you


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Mon Aug 08, 2016 7:30 am

Major update.
 End of turn/live added.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Sat Dec 17, 2016 9:32 am

Strategy was revised and updated.


---

## Re: Highly adaptable Bollinger Band Strategy

**albertparis** · Mon Feb 06, 2017 8:22 am

> **Apprentice wrote:**
> Strategy was revised and updated.

Code: [Select all](https://fxcodebase.com/code/)
`Bonjour
Serait-il possible d’ajouter un filtre
TRENDSTOP avec différents périodes
Exemple  pour le filtre
TRENDSTOP
Time frame : 40
Période : 20
Merci de votre futur travaille`


---

## Re: Highly adaptable Bollinger Band Strategy

**albertparis** · Tue Feb 07, 2017 4:22 am

Hello
Would it be possible to add a filter
TRENDSTOP with different periods
Example for filter
TRENDSTOP
Time frame: 40
Period: 20
Thank you for your future work


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Sat Feb 11, 2017 5:33 am

Your request is added to the development list, Under Id Number 3741
 If someone is interested to do this task, please contact me.


---

## Re: Highly adaptable Bollinger Band Strategy

**marketspot** · Wed Feb 15, 2017 9:09 am

Hey Apprentice,

Would it be possible to have this strategy coded for MT4?

Now that FXCM is closing in the US I would need to run this on mt4, since forex.com doesnt allow custom strats on their other platform.

I loved how you could change the buy/sell depending on cross above or below each band.

It would be greatly appreciated!!!!


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Thu Feb 16, 2017 3:54 am

Highly adaptable Bollinger Band Strategy with Trend Stop Filter Added.


---

## Re: Highly adaptable Bollinger Band Strategy

**albertparis** · Thu Feb 16, 2017 5:04 am

> **Apprentice wrote:**
> Highly adaptable Bollinger Band Strategy with Trend Stop Filter Added.

Hello
I made the same request on this strategy, I do not know if you saw it

Highly adaptable BB_ANALYSER
[viewtopic.php?f=31&t=64447](https://fxcodebase.com/code/viewtopic.php?f=31&t=64447)

Merci de votre futur travail


---

## Re: Highly adaptable Bollinger Band Strategy

**albertparis** · Wed Feb 22, 2017 12:46 pm

> **Apprentice wrote:**
> Highly adaptable Bollinger Band Strategy with Trend Stop Filter Added.

hello.

The filter does not work in the direction of my strategy
Example:

If trendstop is green then take all entries

If possible can you make the same filter for this strategy?

[viewtopic.php?f=31&t=64447](https://fxcodebase.com/code/viewtopic.php?f=31&t=64447)

Thank you for your future work


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Fri Mar 17, 2017 5:07 am

Your request is added to the development list, Under Id Number 3768
 If someone is interested to do this task, please contact me.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Fri Mar 17, 2017 5:51 am

Try it now.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Wed Mar 22, 2017 5:25 pm

MT4/MQ4 version is available here
[viewtopic.php?f=38&t=64536](https://fxcodebase.com/code/viewtopic.php?f=38&t=64536)


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Mon Oct 30, 2017 12:43 pm

Based on the request.
[viewtopic.php?f=27&t=65296](https://fxcodebase.com/code/viewtopic.php?f=27&t=65296)

 [Highly adaptable Bollinger Band Strategy with Trend Stop Filter.lua](files/115774/Highly%20adaptable%20Bollinger%20Band%20Strategy%20with%20Trend%20Stop%20Filter.lua)

 [Highly adaptable Bollinger Band Strategy.lua](files/115774/Highly%20adaptable%20Bollinger%20Band%20Strategy.lua)


---

## Re: Highly adaptable Bollinger Band Strategy

**Denmark1009** · Tue Apr 24, 2018 8:20 am

Great EA, that I tested with some success. Especially the order management is stellar.
So thanks to Apprentice!

Request for added functions.

Order entry and exit:
Add option to individually set Price_check_cross_with_BB:

Entry: CLOSE or HIGH LOW, option to choose between sell or buy.
Exit : CLOSE or HIGH LOW.

Add option:
If
Last order for present pair closed at stop-loss value,
then
Wait’x’-number of minutes after that close before entering a new order in present pair.

Stop-Loss.
 Add function:
 Stop_Loss at ’X’ % of ’X’-day ATR

Regarding entering new order at same bar as closed order:

If settings are:
entry: CLOSE outside band
exit: HIGH LOW outside band
Wait_mins_for_next_trade = 0

I want EA to place new order - provided the closed order was closed at take profit - immediately the entry condition is hit.
Like this: price crosses band – take profit – same bar then closes outside same band = new entry.
I suppose that this will follow from the settings, but please double check

Block entering trades at specific times:
Enable blocking of entering trade: True/False
if true: Time from - Time to. Date. Two or more time blocks. To prevent placing orders at news-hours.

Can this be made to stop all .sets of the EA? (Maybe using a special prefix name for .set files?)
I use the EA on several pairs, hence the request.

Enabling/disabling filter BB-width, please see attached indicator.

Use BBwidth: true/false

If midrangepercent is above setting: define market as trending:
sell at lower cross, buy at upper cross.

If midrangepercent is below setting: define market af consolidating:
lower cross: buy – upper cross: sell

Use general order settings.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Tue Apr 24, 2018 8:32 am

Your request is added to the development list under Id Number 4122


---

## Re: Highly adaptable Bollinger Band Strategy

**chai88888** · Thu Jan 07, 2021 7:30 am

hi there can you please add adx filter to this strategy

trade only if the adx is above a specific level thanks


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Mon Jan 11, 2021 5:15 am

Your request is added to the development list.
Development reference 67.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Tue Jan 12, 2021 10:05 am

[Highly adaptable BB ADX Filter Strategy.lua](files/140172/Highly%20adaptable%20BB%20ADX%20Filter%20Strategy.lua)

Version with ADX filter.


---

## Re: Highly adaptable Bollinger Band Strategy

**chai88888** · Tue Feb 23, 2021 8:06 am

hi there can you please add a target profit and loss

if the equity reach a certain % or $ profit or loss the strategy will pause who will come first the strategy will pause

thanks


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Wed Feb 24, 2021 3:56 am

Your request is added to the development list.
Development reference 228.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Wed Feb 24, 2021 11:35 am

[Highly adaptable BB ADX Filter Strategy.lua](files/140923/Highly%20adaptable%20BB%20ADX%20Filter%20Strategy.lua)

Try this version.


---

## Re: Highly adaptable Bollinger Band Strategy

**chai88888** · Mon Mar 01, 2021 2:20 am

hi there the can you please edit the last strategy and close all open position when it hit profit limit or loss limit and pause the the strategy..

thanks


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Mon Mar 01, 2021 7:41 am

Your request is added to the development list.
Development reference 238.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Mon Mar 01, 2021 5:34 pm

[Highly adaptable BB ADX Filter Strategy.lua](files/140985/Highly%20adaptable%20BB%20ADX%20Filter%20Strategy.lua)

Try this version.


---

## Re: Highly adaptable Bollinger Band Strategy

**shaloiulabcde** · Wed Jan 19, 2022 5:56 pm

Can you please create this strategy to use entry orders instead of market orders?
so instead of buy or sell MO action, parameters would be SE/LE - Buy or sell x pips above/below TL, BL and AL (the entry orders should is pegged and updated with every new TL, BL and AL update)

Thanks


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Fri Jan 21, 2022 9:12 am

Your request is added to the development list.
Development reference 51.


---

## Re: Highly adaptable Bollinger Band Strategy

**albertparis** · Sun Jul 21, 2024 7:24 am

Good morning
Can we replace trend stop with supertrend.lua or st.lua

Link: [https://fxcodebase.com/code/viewtopic.php?f=17&t=605](https://fxcodebase.com/code/viewtopic.php?f=17&t=605)
And if possible add a trend stop with: supertrend.lua

Thank you for your future work


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Mon Jul 22, 2024 3:17 pm

We have added your request to the development list.
Development reference 596


---

## Re: Highly adaptable Bollinger Band Strategy

**albertparis** · Tue May 20, 2025 9:24 am

no news for this request
