# Wick Length

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63410  
> Forum: 17 · Topic 63410 · 9 post(s)


---

## Wick Length

**Apprentice** · Mon Apr 25, 2016 4:40 am

![EURUSD H8 (04-25-2016 1104).png](images/105944/EURUSD%20H8%20%2804-25-2016%201104%29.png)



Based on request.
[viewtopic.php?f=27&t=63408](https://fxcodebase.com/code/viewtopic.php?f=27&t=63408)
Will show.
Separate wick length (Up and Down)
Cumulative wick length (Up + Down)
Wick Difference (Up - Down)

 [Wick Length.lua](files/105944/Wick%20Length.lua)

 [Average Wick Length.lua](files/105944/Average%20Wick%20Length.lua)

Related indicator is available here.
[viewtopic.php?f=17&t=64019&p=108763#p108763](https://fxcodebase.com/code/viewtopic.php?f=17&t=64019&p=108763#p108763)


---

## Re: Wick Length

**FX.Steady.Trader** · Wed Jul 06, 2016 7:31 pm

Hello! Can you add one more option (maybe called Opposite Wick Only) where it works similar to the Separated option (where it has two separate streams for showing both bars) but ONLY shows the wicks that are opposite of the bar type?

Something like this: I edited a screen shot of the Separated method, to show what I would want it to look like

So a bull bar would only draw the lower wick and a bear bar would only draw the upper wick, instead of both wicks being drawn for every bar.

My strategy hinges on watching wicks on the opposite side of the main bar type, and being able to visualize it in an oscillating graph would help me A LOT!

If this works well, I would easily consider paying for the rest of my method to be added, and have this converted into a full Strategy for automated trading. I would be happy to share it with the community as well.

Thank you for your time!


---

## Re: Wick Length

**Apprentice** · Thu Jul 07, 2016 3:20 am

"Separated Opposite Only" option added.


---

## Re: Wick Length

**FX.Steady.Trader** · Thu Jul 07, 2016 4:53 pm

Works great, thank you for the fast change and response!


---

## Re: Wick Length

**mwmarks1** · Mon Jan 09, 2017 9:09 am

Hi Apprentice

Are you able to add an alert to this indicator when there is no wick at the bottom of the up candle and the no wick at the top of the down candle.

Regards
Mwmarks1


---

## Re: Wick Length

**Apprentice** · Wed Jan 11, 2017 5:46 am

Your request is added to the development list, Under Id Number 3710
 If someone is interested to do this task, please contact me.


---

## Re: Wick Length

**Alexander.Gettinger** · Wed Aug 16, 2017 5:16 pm

> **mwmarks1 wrote:**
> Hi Apprentice
>
> Are you able to add an alert to this indicator when there is no wick at the bottom of the up candle and the no wick at the top of the down candle.
>
> Regards
> Mwmarks1

You can try this version.

 [Wick Length with Alert.lua](files/114240/Wick%20Length%20with%20Alert.lua)


---

## Re: Wick Length

**Cactus** · Mon Feb 05, 2018 4:09 pm

Hello
I just made a request for a very similar maybe even identical indicator. And then I found this thread...
So I'll just make one modification request to this indicator.
Can you add a 2 moving averages on the oscillator, one for low wicks and one for high wicks?


---

## Re: Wick Length

**Apprentice** · Mon Feb 05, 2018 4:40 pm

Average Wick Length.lua added.
