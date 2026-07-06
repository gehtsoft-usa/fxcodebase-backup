# Big Range Bar Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=933  
> Forum: 29 · Topic 933 · 3 post(s)


---

## Big Range Bar Signal

**Apprentice** · Sun May 02, 2010 11:45 am

![Big Range Bar Signal.png](images/1691/Big%20Range%20Bar%20Signal.png)

*Big Range Bar Signal*



Should give a signal when a closed bar has a range 20% bigger then ATR(14) and

Uptrend: BUY
Price>5EMA and 5EMA>20EMA and 20EMA>50EMA

Downtrend: SELL
Price<5EMA and 5EMA<20EMA and 20EMA<50EMA

 [Big Range Bar Signal.lua](files/1691/Big%20Range%20Bar%20Signal.lua)


---

## Re: Big Range Bar Signal

**atlassudden** · Mon May 03, 2010 5:39 am

Thanks!

I will test it right away

Christian


---

## Re: Big Range Bar Signal

**atlassudden** · Wed May 05, 2010 3:39 am

Hi!

This signal works just fine, thanks!

Is it possible to develope this signal to have it work like this;

1; look for this big range bar(should not give a signal yet)
2; within the next 5 bars(should be optional) there should be a strong close above or under the big range bar, depending on if there is a buy setup or a short setup.(strong close = if you devide a bar into three pieces, the close should be in the 1:st section(buy) or in the third section (short)

When theese conditions are met there should be a signal.

regards

Christian
