# Historic Volatility on tick stream

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=21021  
> Forum: 17 · Topic 21021 · 10 post(s)


---

## Historic Volatility on tick stream

**gmiller** · Thu Jul 12, 2012 6:35 pm

In finance, volatility is a measure for variation of price of a financial instrument over time. Historic volatility is derived from time series of past market prices. It is common for discussions to talk about the volatility of a security's price, even while it is the returns' volatility that is being measured. It is used to quantify the risk of the financial instrument over the specified time period. Volatility is normally expressed in annualized terms and in %.

[http://fxcodebase.com/wiki/index.php/HistoricVolatility_on_tick_stream](https://fxcodebase.com/wiki/index.php/HistoricVolatility_on_tick_stream)


---

## Re: Historic Volatility on tick stream

**gmiller** · Mon Jul 16, 2012 1:54 pm

The lua files attached for your convenience

 [HV.lua](files/36945/HV.lua)

 [HV_TICK.lua](files/36945/HV_TICK.lua)

 [HV on Chart.lua](files/36945/HV%20on%20Chart.lua)

 [HV_TICK on Chart.lua](files/36945/HV_TICK%20on%20Chart.lua)

The indicator was revised and updated


---

## Re: Historic Volatility on tick stream

**Jeffreyvnlk** · Thu Jul 11, 2013 7:24 pm

Why people interested in tick ? If 2000 or 2 contracts traded, there is still 1 tick. More tick but not more volume or fewer tick but more volume. So you would be free if forget all about tick.IMHO


---

## Re: Historic Volatility on tick stream

**Apprentice** · Fri Jun 27, 2014 5:29 am

HV_TICK on Chart.lua & HV on Chart.lua Added.


---

## Re: Historic Volatility on tick stream

**Apprentice** · Wed Jul 02, 2014 2:06 am

Unfortunately I can not reproduce this crash.
Advice, try to do a complete uninstall and install.
If this continues after this please contact me again.

As for indicator formula, This is a simplified version.

Code: [Select all](https://fxcodebase.com/code/)
`LogReturn[period] = Log (close[period] / open[period]);

    sigma = 100 * (Stdev of LogReturn for Last Period Periods);
   
        if    Annualization then    
       sigma= sigma *  Sqrt( Number of days since the beginning of the year.);
      end

     HV[period] =  sigma;`


---

## Re: Historic Volatility on tick stream

**xyz1453** · Thu Jul 17, 2014 7:19 pm

Hi

Is there any mql4 version of this indicator?Thanks.


---

## Re: Historic Volatility on tick stream

**Apprentice** · Sat Jul 19, 2014 4:24 am

Your request is added to the development list.


---

## Re: Historic Volatility on tick stream

**zmender** · Sat Jul 19, 2014 8:44 pm

I tried to call this indicator from a strategy but received "364: [string "C:\Gehtsoft\IndicoreSDK\indicators\HV.lua"]:178: attempt to index field 'close' (a nil value)" error. What do you think the problem is? It occurs during the update line

Declaration:

Code: [Select all](https://fxcodebase.com/code/)
`Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
   LP = core.indicators:create("HV", Source[Price1], LongPeriod);`

Code: [Select all](https://fxcodebase.com/code/)
`LP:update(core.UpdateLast);`


---

## Re: Historic Volatility on tick stream

**Apprentice** · Sun Jul 20, 2014 3:44 am

HV is using the whole bar.
In your example HV is only getting close component of Bar.

You should use this
LP = core.indicators: create ("HV", Source, longperiod);


---

## Re: Historic Volatility on tick stream

**Apprentice** · Thu Apr 06, 2017 3:35 pm

Indicator was revised and updated.
