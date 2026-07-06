# waddah attar's volume oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72817  
> Forum: 17 · Topic 72817 · 5 post(s)


---

## waddah attar's volume oscillator

**Apprentice** · Fri Oct 07, 2022 1:42 am

![NGAS m15 (10-07-2022 0841).png](images/147821/NGAS%20m15%20%2810-07-2022%200841%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&p=147735](https://fxcodebase.com/code/viewtopic.php?f=27&p=147735)

 [waddah attar's volume oscillator.lua](files/147821/waddah%20attars%20volume%20oscillator.lua)

 [averages waddah attar's volume oscillator.lua](files/147821/averages%20waddah%20attars%20volume%20oscillator.lua)

You can find Averages.lua here.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)


---

## Re: waddah attar's volume oscillator

**bartwas1** · Fri Oct 07, 2022 3:57 am

HI Apprentice

Thanks for this oscillator, but it doesn't look like metatrader's version.
The reason I've requested it, because I was interested in smooth version of volume - easy
to read and interpret. So if I have trending market going up, for example, I see red
I am going to be careful, see green I grin, moving my stop or adding new position.
Current version you've developed is... rugged.
Visually it should have bars looking sort of like in marketscope's MACD with histogram coloring
(MACD - With Histogram Coloring.lua) - smooth but have the same colour when above zero line
and different when below it.
Obviously I don't know if it can be codded similarly to mt4, so don't take it wrong way.

Anyway, thank you again and I am going to test it and mold to my purposes. I've already some
ideas. See attachment.

Kind regards
Bart


---

## Re: waddah attar's volume oscillator

**Apprentice** · Tue Oct 11, 2022 9:13 am

averages waddah attar's volume oscillator.lua has additional smoothing methods.
Will try to add more methods when I find the time.


---

## Re: waddah attar's volume oscillator

**bartwas1** · Wed Oct 12, 2022 4:34 am

Hi apprentice

That's awesome man - more averages. I got great results after using HMA or Jsmooth, thanks. Though I've a question about two averages: VAMA and HPF. When I try to use VAMA or HPF as a method I receive a message that bar source should be selected for VAMA or HPF depending which average one wants to use.
I've got averages installed and VAMA separately - couldn't find HPF, but to be honest mostly I wanted to see VAMA (volume adjusted moving average).
Any chance for little assistance, please.


---

## Re: waddah attar's volume oscillator

**Apprentice** · Wed Oct 12, 2022 2:23 pm

Fix the VAMA and HPF issue.
