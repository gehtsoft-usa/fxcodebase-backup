# Donchian (Price) Channel Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=1185  
> Forum: 29 · Topic 1185 · 9 post(s)


---

## Donchian (Price) Channel Signal

**Apprentice** · Fri May 28, 2010 12:16 pm

![Donchian Channel Signal.png](images/2265/Donchian%20Channel%20Signal.png)

*Donchian Channel Signal*



If a security trades above its highest/lowest 20 day high/low then go Long/Short.
Changing the default parameters you get the Price Channel signal.

Closing price breakouts above or below the Price Channel indicator to generate buy / sell signal.
Buy - Breakouts of closing price above the upper Price Channel line (resistance).
Sell - Breakouts of closing price above the lower Price Channel line (support).

 [Donchian Channel Signal.lua](files/2265/Donchian%20Channel%20Signal.lua)


---

## Re: Donchian (Price) Channel Signal

**cosmos110** · Thu Nov 11, 2010 4:14 pm

good Morning

 I downloaded your Donchain Channel Signal and am trying to get it to work but I'm having trouble. I have tried to load it into the Indicators and the Strategy's as well. It seems to load Ok but when I try to activate it after the properties box it doesn't show up on the chart.

 do you have any suggestions?

thanks


---

## Re: Donchian (Price) Channel Signal

**Apprentice** · Thu Nov 11, 2010 4:57 pm

I just made a test.
It seems to work as expected.

 

![Donchian Channel Signal.png](images/6051/Donchian%20Channel%20Signal.png)



What time frame are you using,
the options within the parameters.

Second question, what version of TS you are using.


---

## Re: Donchian (Price) Channel Signal

**cosmos110** · Thu Nov 11, 2010 5:38 pm

Trade station 2.

I just upgraded to the "Strategy Trader" because they said the Donchain Strategy was on there but I haven't found it and from the looks of the new interface, I may need a couple of years in college to figure it out.

I couldn't get the Donchain to work on Trade Station 2 and show up like the picture on this page (?)


---

## Re: Donchian (Price) Channel Signal

**sunshine** · Fri Nov 12, 2010 7:38 am

Hello,

Please choose one of the instructions below depending on what you want to do.

**To apply the Donchian (Price) Channel Signal on real time data and get signals in real time:**
1. Install this strategy using the Manage Custom Strategies dialog.
2. Add it to the chart using the Add Strategy dialog.

 You can find detailed instructions at [viewtopic.php?f=29&t=602](http://www.fxcodebase.com/code/viewtopic.php?f=29&t=602)
 Please note that the Donchian (Price) Channel Signal is not displayed on the chart. It sends alerts as text or sound. Text alert cause the Events window pop up when the signal conditions are met.

 Also note that on the picture from the first post in this thread the Donchain Channel indicator (not a signal) is displayed. If you want to view this indicator, download it using the Manage
 Custom Indicators dialog from [http://fxcodebase.com/code/viewtopic.php?f=17&t=20](https://fxcodebase.com/code/viewtopic.php?f=17&t=20)
 Please find detailed instructions at [viewtopic.php?f=17&t=17](http://www.fxcodebase.com/code/viewtopic.php?f=17&t=17)

**To backtest the signal (view signals on historical data):**
 1. If you haven't installed the Donchian (Price) Channel Signal to Marketscope, do this using the Manage Custom Strategies dialog. You can find detailed instructions at [viewtopic.php?f=29&t=602](http://www.fxcodebase.com/code/viewtopic.php?f=29&t=602)
 2. Click the Test Strategy command on the Strategies menu.
 3. The BACKTEST properties dialog appears.
 4. Click Signal and then click the appeared button.
 5. The Strategy Properties dialog will appear.
 6. In the Strategy box choose Donchian (Price) Channel Signal.
 7. Click OK in Strategy Properties.
 8. Click OK in BACKTEST Properties.

 Historical signals will appear on the chart.

Hope this will help.


---

## Re: Donchian (Price) Channel Signal

**Stephanius** · Tue Feb 08, 2011 12:45 pm

Hi "Apprentice",

I'm using the Donchain (Price) Channel Signal for now some weeks. Out of any reason it seens not to work correctly in all cases.

If I understand the function right, the program should send a message at the beginning of each new candle when the last candle touched the upper or lower band.
At 30 minute charts I use a setup as follows:
- Number of periods: 55
- Analyse the current period: yes
- Show middle line: no
- High/Low: true.

If you answer me by email, I will send you two screenshots with examples.

Regards
Stephan


---

## Re: Donchian (Price) Channel Signal

**Apprentice** · Tue Feb 08, 2011 1:37 pm

Depending on how you trade.
Some people are waiting for the conclusion of a candle,
while others react to your touch.

I'll add an option that would include things functionality.


---

## Re: Donchian (Price) Channel Signal

**Stephanius** · Mon Feb 28, 2011 7:39 am

Hi Folks,

as described some time ago I'm looking for a modified Donchian (Price) Channel Signal that sends a message/signal at the beginning of each new candle when the last candle touched the upper or lower band before.

Thanks
Stephan


---

## Re: Donchian (Price) Channel Signal

**Apprentice** · Thu Apr 30, 2015 4:57 am

Bump up.
