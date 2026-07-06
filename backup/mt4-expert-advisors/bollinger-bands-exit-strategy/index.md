# Bollinger Bands Exit Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=64478  
> Forum: 38 · Topic 64478 · 2 post(s)


---

## Bollinger Bands Exit Strategy

**Apprentice** · Fri Feb 24, 2017 5:12 am

[Bollinger_Bands_Exit_Strategy.mq4](files/111176/Bollinger_Bands_Exit_Strategy.mq4)

Description:

In this EA in particular the trader places the trades manually so the EA simply has to exit any ongoing trades when price exceeds any of the Top Band or Bottom Band. There is the option to select which TimeFrame to analyze the trades.


---

## Re: Bollinger Bands Exit Strategy

**Apprentice** · Wed Mar 08, 2017 3:42 pm

Now the EA has the option to turn it on and off with the following parameter:
extern bool EA_Activated = true;
Set false to turn it off.
