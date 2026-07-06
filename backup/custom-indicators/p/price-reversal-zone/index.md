# Price Reversal Zone

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72801  
> Forum: 17 · Topic 72801 · 5 post(s)


---

## Price Reversal Zone

**Apprentice** · Tue Oct 04, 2022 9:59 am

![NGAS m15 (10-04-2022 1657).png](images/147738/NGAS%20m15%20%2810-04-2022%201657%29.png)



Price Reversal Zones are nothing more than current-day wicks.

 [Price Reversal Zone.lua](files/147738/Price%20Reversal%20Zone.lua)


---

## Re: Price Reversal Zone

**minifire18** · Wed Oct 05, 2022 3:09 am

Hi Apprentice,
From watching the indicator on live price seems to just print to open to wick high on seller candle and open to wick low on buyers candle Not waiting for current candle to close so its flashing buy zone /sell zone for while candle open even though set to close and condition not met conditions below

Conditions for Sell zones to sellers candle to close below the open of the last buyers candle printed

Conditions for Buy zones to buyers candle to close above the open of the last sellers candle printed

And if you extend zones either to time period eg : if using 1Hr extend zone to 1 week to set in setting or use HTF zigzag so not to clutter price chart
Thanks for work already done
Minifire


---

## Re: Price Reversal Zone

**Apprentice** · Thu Oct 06, 2022 2:46 pm

This is only a presentation/template,
as it is it will only show current candle wicks.
Have not applied any logic.
We have added your request to the development list.
Development reference 629.


---

## Historical Price Reversal Zone

**Apprentice** · Fri Oct 07, 2022 4:09 am

![NGAS H8 (10-07-2022 1107).png](images/147827/NGAS%20H8%20%2810-07-2022%201107%29.png)



 [Historical Price Reversal Zone.lua](files/147827/Historical%20Price%20Reversal%20Zone.lua)

 [Current Price Reversal Zone.lua](files/147827/Current%20Price%20Reversal%20Zone.lua)


---

## Re: Price Reversal Zone

**minifire18** · Fri Oct 07, 2022 9:46 am

Hi Apprentice,

**Historical Price Reversal**
Thanks for all your works gone into this indicator few tweaks. Zone are not correctly drawn when price is continuously trending currently still printing zones, the zones are only to print when the reversal candle or candles close past the last trending candle if then a trending candle printed followed by a reversal candle that close past open on trending then previous zone not to print (as per screenshot)
To extend out till retest of the open or close past the zone
If multiple zone are been printed over lapping if you use the 1st zone and last zone created have option in setting for range
Currently there is an option to set to BID or ASK price can you add option to what the chart is currently on so determined by switching chart manually to bid or ask

Thanks Minifire

 

![Historical Price Reversal.jpeg](images/147830/Historical%20Price%20Reversal.jpeg)
