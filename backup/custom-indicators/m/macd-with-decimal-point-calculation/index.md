# MACD with decimal point calculation

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60055  
> Forum: 17 · Topic 60055 · 5 post(s)


---

## MACD with decimal point calculation

**Apprentice** · Tue Dec 03, 2013 3:40 am

![MACD with decimal point calculation.png](images/91318/MACD%20with%20decimal%20point%20calculation.png)



MACD which will permit the decimal length of periods for EMA used in the calculation of indicator.

 [MACD with decimal point calculation.lua](files/91318/MACD%20with%20decimal%20point%20calculation.lua)

The indicator was revised and updated


---

## Re: MACD with decimal point calculation

**Apprentice** · Sun Jun 18, 2017 1:05 pm

The indicator was revised and updated.


---

## Re: MACD with decimal point calculation

**fortcentral** · Sun Jan 13, 2019 12:02 am

Dear Apprentice,
I am new to this forum and I am not a programmer. I am planning to put in a request for a new indicator which uses this MACD (with decimal point calculation) as a basis. Before I put in the request I wanted to confirm that the MACD formula below is what is being used in the current MACD calculation. As a starting point, this will provide a common baseline for my new indicator request. I have outlined the MACD formula that I use.

Thanks,
Fortcentral

------------------------------------------------------------------------------------
Indicator: Moving Average Convergence/Divergence (MACD) with decimal point calculation (this MACD indicator can handle decimal point smoothing constants)
-------------------------------------------------------------------------------------
([viewtopic.php?f=17&t=60055&p=112972&hilit=macd+with+decimal#p112972](https://fxcodebase.com/code/viewtopic.php?f=17&t=60055&p=112972&hilit=macd+with+decimal#p112972))
------------------------------------------------------------------------------------

--> Price Source: Bars

Calculation for Exponential Moving Average (EMA)
	EMA(time) = (1-SF)*EMA(time-1) + SF*Price(time)

Calculation for Smoothing Factor
	SF = [2/(n.period+1)]

Note:
1) EMA(time) is the current time-period Exponential Moving Average value
2) EMA(time-1) is the previous time-period Exponential Moving Average value
3) SF is the smoothing factor for the EMA calculation
4) Price(time) is the current time-period closing price of price-bar
5) "n.period" is the total number of bars used in the calculation, i.e. the lookback period --> this could be a decimal value.
6) The smoothing process for the EMA calculation is started by letting EMA(1)=P(1) and calculating the next value EMA(2)=[(1-SF)*EMA(1)]+[SF*P(2)].

--> User Input Parameters:
1) EMA1(n.period) - for first EMA line calculation
2) EMA2(n.period) - for second EMA line calculation
3) SL(n.period) - for signal line calculation
4) Option for choosing line thickness, style and colour for "MACD" and "SL" line display

--> MACD (with decimal point) Calculation:
	EMA1(time) = [(1-SF1)*EMA1(time-1) + SF1*Price(time)]
	EMA2(time) = [(1-SF2)*EMA2(time-1) + SF2*Price(time)]
	MACD(time) = [EMA1(time)-EMA2(time)]
	SL(time) = [(1-SF3)*SL(time-1) + SF3*MACD(time)]

Note:
1) EMA1(time) and EMA2(time) are the two Exponential Averages' current time-period values, based on the EMA formula above.
2) EMA1(time-1) and EMA2(time-1) are the two Exponential Averages' previous time-period values
3) SF1 is the smoothing factor for the EMA1 calculation. The smoothing factor is derived using the formula above.
4) SF2 is the smoothing factor for the EMA2 calculation. The smoothing factor is derived using the formula above.
5) Price(time) is the current period closing price of price-bar
6) MACD(time) is the current time-period MACD value
7) MACD(time-1) is the previous time-period MACD value
8) SL(time) is the current time-period Signal Line value
9) SL(time-1) is the previous time-period Signal Line value
10) SF3 is the signal line smoothing factor


---

## Re: MACD with decimal point calculation

**Apprentice** · Sun Jan 13, 2019 7:27 am

Sure.
The specification is correct.


---

## Re: MACD with decimal point calculation

**fortcentral** · Sun Jan 13, 2019 9:56 am

Thank you - much appreciated!
