# Heikin-Ashi Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69690  
> Forum: 17 · Topic 69690 · 6 post(s)


---

## Heikin-Ashi Alert

**Apprentice** · Sun Apr 19, 2020 5:32 am

![UKOil D1 (04-19-2020 1041).png](images/132947/UKOil%20D1%20%2804-19-2020%201041%29.png)



Based on request.
[viewtopic.php?f=29&t=1101&start=10](https://fxcodebase.com/code/viewtopic.php?f=29&t=1101&start=10)

Buy when color is green and the candle hadn't a low wick
Sell when color is red and the candle hadn't a high wick

 [Heikin-Ashi Alert.lua](files/132947/Heikin-Ashi%20Alert.lua)


---

## Re: Heikin-Ashi Alert

**Mountaintrader** · Wed Jun 08, 2022 12:20 pm

Hi Apprentice,

Is it possible to base a scalping strategy around the arrow alerts this indicator provides ?

A manual strategy I have successfully used is to apply the Heiken-Ashi Alert indicator to five different ¨below chart" instruments, manually entering trades when all five alert arrows trigger simultaneously in the same direction at the close of the candle.

One of the below chart instruments I use is the VOLX instrument, which I inverted the Heiken-Ashi Alert arrow colour and direction, so its arrows now align with the other instruments when the markets all move together. Therefore if possible a "Direct or Indirect" parameters option would be very useful for each instruments to overcome this situation in a strategy.

Regards
Mountain Trader.


---

## Re: Heikin-Ashi Alert

**Apprentice** · Fri Jun 10, 2022 6:06 am

Five alert arrows?

Is this correct?
Heikin-Ashi Up arrow on Instrument
Heikin-Ashi Up arrow on VOLX instrument

If differ, can you provide the entry rules for all five?
If you use any indicators posted on the forum,
Make sure to provide the links to the forum post where they are posted.


---

## Re: Heikin-Ashi Alert

**Mountaintrader** · Sun Jun 12, 2022 4:48 pm

Hi Apprentice,

Thank you for your reply.

The attached screenshot shows the Heikin-Ashi Alert indicators arrow alerts applied to the NAS100 chart and its five "below chart" instruments. The yellow highlighted area shows an example of all the six Heikin-Ashi Alerts arrows simultaneously painting after the close of the 07:37 candle.

 

![1 Heikin-Ashi Alert Buy Example.png](images/146352/1%20Heikin-Ashi%20Alert%20Buy%20Example.png)



However, for the purposes of uniform arrow alignment when manually scalping as shown in the NAS100 chart screenshot, the code of the Heikin-Ashi Alert Indicator applied to the VOLX instrument is slightly modified (mod) to account for its general inverse relationship with the five Indices.

The mod reverses the VOLX Heikin-Ashi Alert painted arrow direction as follows:
At code line 211, text changed to read 226 (originally 225)
At code line 216, text changed to read 225 (originally 226)

With the mod applied to “ONLY” the VOLX indicator, all the arrows are now pointing UP and configured with the same RGB, allowing clarity when reading the chart. Without applying the mod to the VOLX indicator, its arrow would have pointed DOWN, whilst the remaining five indicator arrows would point UP.

 

![2 Heikin-Ashi Alert VOLX - Code Lines 211 and 216.png](images/146352/2%20Heikin-Ashi%20Alert%20VOLX%20-%20Code%20Lines%20211%20and%20216.png)



I believe the strategy would require a "Direct" or "Indirect" parameter option for each instrument, allowing for the inclusion of the VOLX when selecting the instruments to apply to the new strategy.

The below screenshot shows the Heikin-Ashi Alert indicator parameter currently used in all six of the indicators settings to trade the strategy manually. I request they are also incorporated into the new strategy.

 

![3 Heikin-Ashi Alert Properties’ settings currently used to trade manually..png](images/146352/3%20Heikin-Ashi%20Alert%20Properties%20settings%20currently%20used%20to%20trade%20manually..png)



**Entry Rules.**
BUY: After the close of the candle. The strategy would enter a BUY position with the same criteria that would cause all six Heikin-Ashi Alert indicator UP arrows to paint (Including modified VOLX)
SELL: After the close of the candle. The strategy would enter a SELL position with the same criteria that would cause all six Heikin-Ashi Alert indicator DOWN arrows to paint (Including modified VOLX)

The new strategy would:
1.	Be applied to TS2 platform (.Lua)
2.	Remove the need for the below chart instruments.
3.	Paint a single arrow on the chart when a Buy or Sell positioned opened.
4.	Sound the associated audio alert.

**Strategy Parameters**
Instrument To Trade (Drop down menu to select)
The standard Strategy parameters:
Allow Strategy to trade: Y/N
End of Turn/Live: End of Turn
Allowed Side: Both/ Buy/ Sell
Close On Opposite: Y/N
Custom Identifier:
Max Number of Open Positions in any Direction: 1
Trade Amount in Lots: 1
Maximum number of open trades: 1
Set Limit Order: Y/N
Limit Order Pips:
Set Stop Order: Y/N
Set Stop Order Pips:
Trailing Stop Order: Y/N
HA Trend Change Type: Without Wicks First Only Alert (See Heikin-Ashi Alert Properties screenshot)

Set 1
1 Use this set: Y/N
2 Time Frame: m1
3 Direct/Indirect: Direct
4 Instrument: NAS100

Set 2
1 Use this set: Y/N
2 Time Frame: m1
3 Direct/Indirect: Indirect
4 Instrument: VOLX

Set 3
1 Use this set: Y/N
2 Time Frame: m1
3 Direct/Indirect: Direct
4 Instrument: US30

Set 4
1 Use this set: Y/N
2 Time Frame: m1
3 Direct/Indirect: Direct
4 Instrument: SPX500

Set 5
1 Use this set: Y/N
2 Time Frame: m1
3 Direct/Indirect: Direct
4 Instrument: US2000

Set 6
1 Use this set: Y/N
2 Time Frame: m1
3 Direct/Indirect: Direct
4 Instrument: US Equities

**Alerts**
Chart Alerts
Show Alert: Y/N
Paint Arrow onto Chart at candle (Buy Below candle / Sell above. RGB 225/226 arrows)

Sound Alerts
1.	Sound File 1 BUY - User defined .wav file
2.	Sound File 2 SELL - User Defined .wav file
Recurrent Sound: Y/N
Send Email: Y/N

**Time Parameters**
The standard Strategy Start/ Finish parameters

END


---

## Re: Heikin-Ashi Alert

**Apprentice** · Wed Jun 15, 2022 1:43 pm

We have added your request to the development list.
Development reference 355.


---

## Re: Heikin-Ashi Alert

**Apprentice** · Thu Aug 17, 2023 1:57 pm

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=31&t=74046](https://fxcodebase.com/code/viewtopic.php?f=31&t=74046)
