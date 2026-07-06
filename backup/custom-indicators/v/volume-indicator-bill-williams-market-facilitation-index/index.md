# Volume Indicator : Bill Williams' Market Facilitation Index

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=1968  
> Forum: 17 · Topic 1968 · 29 post(s)


---

## Re: Volume Indicator : Bill Williams' Market Facilitation Index

**jcervinka** · Wed Apr 06, 2011 2:08 pm

Hi

Thanks for this great indicator.
I have jus read the B.W. book ''Trading chaos'', and this is the indicator i hve ben searching for...
Exelent!

Can you , please, make an signal for it. I mean, to have a sound whenever some pattern are made.

Thankks a lot and rergards

Jernej


---

## Re: Volume Indicator : Bill Williams' Market Facilitation Index

**Apprentice** · Wed Apr 06, 2011 5:06 pm

Your request has been added to the development Cue.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation Index

**bingyunid** · Wed Apr 06, 2011 9:56 pm

Hi,Nikolay.Gekht , i have a question about this indicator. What does the length of the BAR(indicator value) mean? It changes so fast, does it mean the power of this bar? Thanks very much


---

## Re: Volume Indicator : Bill Williams' Market Facilitation Index

**Apprentice** · Thu Apr 07, 2011 3:13 am

Directly, no.
Indirectly yes.

Bill Williams' Market Facilitation Index is a derivative of volume.
Increase in volume, resulting in the growth of BW MFI.

The larger the volume in the period, the signal is stronger.
But to use it successfully you have to know what mean all and any particular indication of BW MFI.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation Index

**bingyunid** · Fri Apr 08, 2011 3:50 am

Got it. Thanks very much, Apprentice


---

## Re: Volume Indicator : Bill Williams' Market Facilitation Index

**Blackcat2** · Sun Apr 10, 2011 8:29 pm

Any recommended links on how to read, interpret, analyse, etc?

Thanks..


---

## Re: Volume Indicator : Bill Williams' Market Facilitation Index

**Apprentice** · Mon Apr 11, 2011 8:12 am

Not really. Maybe Google.
This is not an exact indicator.
Instead of the signal gives you a feel for the market.
(Correct me if I'm wrong)

Market Facilitation Index (BW MFI) analyzed the amount of price change for each unit
volume.

MFI = (high - low) / VOLUME

We distinguish four different situations

Green - Growing Market Facilitation Index and Volume
a) A growing number of investors entering the market (volume increases)
b) The new open positions are open in the direction of the candle in the making, momentum gained in strength.

Fade - Falling Market Facilitation Index and Volume
Shows a decline in interest for the creation of new positions, suggesting the possible end of the current trend.

Fake - Market Facilitation Index increases while volume decreases.
The growth rates there is no confirmation in turnover, the interest of investors, growth in value caused by speculators (brokers and dealers).

Squat - Market Facilitation Index falls as volume increases.
Pressure to sell is equal to the pressure to purchase. High volume fail to significantly change the price. One of the parties, buyers or sellers, sooner or later will overpower the other. Usually preceded by a significant change in trend. Next candles, gives us a direction, whether there will be a continuation of or changes to the current trend. We call it the Squat bar, the market is on hold before the jump.

From My Blog.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Mist1949** · Mon Apr 06, 2015 12:54 pm

Is it possible to use Real volume (FXCM Trading Station-Marketscope) instead of tick volume for this indicator? I suppose it would be more accurate.
Thanks.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Wed Apr 08, 2015 6:44 am

For now I do not plan to provide support for real volume.
Real volume is available only for selected currency.
Plus Real volume indicator code is not available.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**transformer** · Sun Apr 12, 2015 2:35 am

hi apprendice can you create mtf mcp list based on this indicator with 12 opions

1. color1: mvi ↑ and volume ↑ and price ↑
2.color 2: mvi ↑ and volume ↓ and price ↑
3.color 3: mvi ↓ and volume ↓ and price ↑
4.color 4: mvi ↓ and volume ↑ and price ↑
5. color5: mvi ↑ and volume ↑ and price ↓
6.color 6: mvi ↑ and volume ↓ and price ↓
7.color 7: mvi ↓ and volume ↓ and price ↓
8.color 8: mvi ↓ and volume ↑ and price ↓
9. color9: mvi ↑ and volume ↑ and price -no change
10.color 10: mvi ↑ and volume ↓ and price - no change
11.color 11: mvi ↓ and volume ↓ and price - no change
12.color 12: mvi ↓ and volume ↑ and price - no change

if it shows 4 time frames(h4,h8,d1,w1) with yes/no option for selection of time frame it will be good.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Sun Apr 12, 2015 6:21 am

MTF MCP Market Facilitation Index List.lua Added.
If you are using an old version of Market Facilitation Index, please re-download.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**transformer** · Sun Apr 12, 2015 9:00 am

thank you apprendice.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**transformer** · Sun Apr 12, 2015 9:24 am

hi apprendice,

i have added the indicator of mtf mcp list mfi indicator to trading statiton i get following picture.
is there any error.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Sun Apr 12, 2015 10:48 am

Not really.
Try it now, I adjusted the screen adaptation algorithm a bit.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**transformer** · Sun Apr 12, 2015 10:55 am

where is new version of Market Facilitation Index is present. can you upload url to download it.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Sun Apr 12, 2015 6:18 pm

bwmfi.lua from topmost / first post of this topic.


---

## BWMFI BAR INDICATOR REQUEST

**transformer** · Mon Apr 13, 2015 4:26 am

hi apprendice,

can you add bwmfi bar indicator like 3 ma bar indicator as in following page

[http://fxcodebase.com/code/viewtopic.php?f=17&t=9634](https://fxcodebase.com/code/viewtopic.php?f=17&t=9634)

because it will look better for interperate


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Wed Apr 15, 2015 5:18 am

Market Facilitation Index Bar Added.
To be sure you have the latest version,
Please re-download bwmfi.lua


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Mon Apr 23, 2018 8:28 am

The indicator was revised and updated.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**ANTONIO** · Mon Dec 31, 2018 12:05 pm

Hi Apprentice,
YOU CAN ADD AN ALERT TO THIS INDICATOR WHEN THE BAR EXCEEDS A PREDEFINED LEVEL?

(alert not change the colour of bar but if one bar exceeds for example the 0,10)


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Wed Jan 02, 2019 4:57 am

BWMFI with Alert.lua added.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**fortcentral** · Tue Jan 22, 2019 6:35 am

Dear Apprentice,
Please find suggested modification to make the indicator a little more user friendly. As summarised in previous posts, the "squat" is a directional indicator and is based on the range of a given price bar and the volume that occurs while that range is being created.

The "squat" is based on the idea that high volume and little price movement, indicates substantial support or resistance. Once the required conditions for a "squat" are satisfied, it would be great to have a "flag/marker" above the price bar to highlight the "squat". An overlay of a small flag (say a coloured triangle or an arrow) would make it really easy to identify the "squat" and still keep the display uncluttered.

User parameters:
1) %volume - the percentage increase in tick volume compared to the previous bar, which will generate the "squat"
2) Colour option for the "squat" marker

--> Squat calculation

Squat is represented with a marker above the price bar when both of the following conditions are satisfied:
1) At least a 30% increase in (TIC) volume and
2) A smaller "MFI" than the previous price bar

MFI = [(range of bar)/volume]

Note:
1) "range of bar" is the price range of the bar in tics, pips or points -> range=(high-low)
2) "volume" is the (TIC) volume.

Not sure if code for "real.volume" based on the FXCM "Real Volume Transactions" indicator is now available but otherwise whatever feed for volume volume data is available in the price chart could be used. I normally only run the FXCM "real.volume" indicator for some specific charts and particular timeframes such as 1-min or 5-min. Volume data gets averaged on larger time frame charts and the "squat" is not so useful then.


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Tue Jan 22, 2019 8:50 am

Your request is added to the development list under Id Number 4438


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Mon Jan 28, 2019 8:27 am

Try this version.

 [bwmfi.fortcentral.lua](files/123561/bwmfi.fortcentral.lua)


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**fortcentral** · Wed Feb 06, 2019 9:52 am

Dear Apprentice,
Thank you for getting this through. The "squat" signal is regarded as the most powerful of the four signals. I ran a few tests using forex pairs and unfortunately the "tick.volume" is not generating reliable signals. Using "Real Volume" indicator data to calculate the "squat" signals is generating much more reliable signals!

The squat bar is typically a low-range, high-volume bar. Currently, the indicator is picking up many high range low volume bars (as measured based on the real volume data) in Marketscope. This could be an issue of using retail trade data, where there may be higher transactions, but which may not amount to large overall volume due to the relatively smaller size of these numerous transactions.

Could you please confirm:
1) The thinking behind the "range" input in the parameter section?
2) Is it possible to only have the "squat" arrows on the price chart, rather than the 4-colour bar panel?
3) Is it possible to use "real volume" data in the "squat" indicator calculation? Tick volume is not getting reliable results as noted above.

Thanks,
Fortcentral


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**logicgate** · Fri Aug 09, 2019 9:51 am

Hello dear friend Apprentice.

Can you please code this indicator for MT4? But the indicator being plotted as a line, not color coded bars.

So you just grab the result of this formula:

MFI = (High - Low) / Volume

And display as a line on bottom of the screen.

Thanks


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Sun Aug 11, 2019 9:07 am

Your request is added to the development list under Id Number 4836


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**Apprentice** · Sun Aug 11, 2019 9:24 am

Try this version.
[viewtopic.php?f=38&t=68771](https://fxcodebase.com/code/viewtopic.php?f=38&t=68771)


---

## Re: Volume Indicator : Bill Williams' Market Facilitation In

**ahmedalhosenyy** · Wed Nov 26, 2025 12:08 pm

I found that topic ,

thanks
