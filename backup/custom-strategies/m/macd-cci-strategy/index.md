# MACD CCI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=8341  
> Forum: 31 · Topic 8341 · 19 post(s)


---

## MACD CCI Strategy

**Apprentice** · Tue Nov 22, 2011 1:35 pm

![MACD CCI Strategy.png](images/18452/MACD%20CCI%20Strategy.png)



buying condition:

1. cci [period14] > buy level { and}
2. macd line cross over signal line { and}
3. signal line < buy level {0}

selling condition:

1. cci [ period 14] < sell level{ and }
2. macd line cross under signal line { and }
3. signal line > sell level {0}

exit buy conditions:

1. cci cross below buy level { or}
2. macd line cross under signal line

exit sell conditions:

1. cci cross above sell level {or}
2. macd line cross above signal line

 [MACD CCI Strategy.lua](files/18452/MACD%20CCI%20Strategy.lua)

The Strategy was revised and updated on November 21, 2018.


---

## Re: MACD CCI Strategy

**transformer** · Wed Nov 23, 2011 2:27 am

hi apprentice,

i request an indicator based on this strategy with bigger time frame feature.

**GREEN COLOR:**

1. cci [period 14] > 0 and macd line > signal line

**RED COLOR:**

1. cci [ period 14] < 0 and macd line < signal line

**YELLOW COLOR**

1. cci > 0 and macd line< signal line {or}

2. cci < 0 and macd line> signal line

thank you


---

## Re: MACD CCI Strategy

**Apprentice** · Wed Nov 23, 2011 1:32 pm

Requested can be found here.
[viewtopic.php?f=17&t=8389](https://fxcodebase.com/code/viewtopic.php?f=17&t=8389)


---

## Re: MACD CCI Strategy

**transformer** · Wed Nov 23, 2011 4:22 pm

thank you very much.


---

## Re: MACD CCI Strategy

**nicdu40** · Fri Nov 25, 2011 3:08 pm

hello , i'm new member here, first thank for all.

i modified this strategy like this :

buy condition : macd line cross over signal line and
signal line < - 0.0000X x line 0 and
macd line [period -1] < macd line [periode] - X <-------------------------

in fact i would want find something to change this last line by "macd line cross over signal line" whith X degres (betwen 45° and 135°for example) .
 can you help me please?

 this is a part of the modified code:

 -- buying condition:

if core.crossesOver( Short["MACD"], Short["SIGNAL"] , period)
and Short["MACD"][period] < - MACDBS / 100000
and Short["MACD"][period -1] < - MACDec / 100000 + Short["MACD"][period]

 then
 if Direction then
 BUY();
 else
 SELL();
 end

 --selling condition:

elseif core.crossesUnder( Short["MACD"], Short["SIGNAL"] , period)
and Short["MACD"][period] > MACDBS / 100000
and Short["MACD"][period -1] > MACDec / 100000 + Short["MACD"][period]

 then

 if Direction then
 SELL();
 else
 BUY();
 end
 end

	--	exit buy conditions

if core.crossesUnder( Short["MACD"], Short["SIGNAL"] , period)
and (( Short["MACD"][period] < - MACDBS /100000 ) or (( Short["MACD"][period -1] > MACDec / 100000 + Short["MACD"][period] ) and Short["SIGNAL"][period] < MACDBS /100000 ))

 then

 if Direction then
 if haveTrades("B") then
 exit("B");
 Signal ("Close Long");
 end
 else
 if haveTrades("S") then
 exit("S");
 Signal ("Close Short");
 end

 end
 end
 --exit sell conditions:

if core.crossesOver( Short["MACD"], Short["SIGNAL"] , period)
and (( Short["MACD"][period] > MACDBS /100000 ) or (( Short["MACD"][period -1] < Short["MACD"][period] - MACDec / 100000 ) and Short["SIGNAL"][period] > - MACDBS /100000 ))

 then
 if Direction then
 if haveTrades("S") then
 exit("S");
 Signal ("Close Short");
 end

 else

 if haveTrades("B") then
 exit("B");
 Signal ("Close Long");


---

## Re: MACD CCI Strategy

**Apprentice** · Sat Nov 26, 2011 4:49 am

X degres ?
Do you think the pips.
I'm not sure, from where degrees came.
Describe to me what you want, add the formula.
I'm not sure that it is wisest to read your code.


---

## Re: MACD CCI Strategy

**nicdu40** · Sat Nov 26, 2011 8:48 am

for this example i want sell if angle (macd/signal) > X degres

i think i found :

but the angle is not realy the true angle but i think it's a good indice

tanMACD= (macd(period-1) -macd(period)

tanSIGNAL= signal(period-1) -signal(period)

angle(in radian) = math.atan (tanMAcD) + math.atan (tanSIGNAL)

thank you


---

## Re: MACD CCI Strategy

**Apprentice** · Sat Nov 26, 2011 10:27 am

Here you have a serious problem.

X axis. We use periods
Y axis. We use Value
These are apples and pears.
And as such, does not mix.

What is the distance between two points on the x axis.

I suppose I could use the average change in some time.
As a reference value for the distance between two points on the X axis.

I suggest something simpler.
Difference in slope.
A = MACD [period]-MACD [period-1]
B = Signal [period] - Signal [period-1]

Difference = A - B

Basically it is a histogram.
You should only define trigger level for it.


---

## Re: MACD CCI Strategy

**nicdu40** · Sat Nov 26, 2011 11:01 am

Yes ! its more simpler, and also effective, thank you very mutch!!!


---

## Re: MACD CCI Strategy

**Apprentice** · Sun Nov 27, 2011 3:31 pm

![MACD Strategy.png](images/18840/MACD%20Strategy.png)



This is a simple MACD Zero line, Cross Strategy.
As an additional filter you can add a minimum difference of MACD histogram,
that must be achieved, in order to enter the trade.

**buying condition:**

MACD / MACD Buy LineCrossover
 and
Histogram[period-1] - Histogram[period] < Trigger

**selling condition:**
MACD / MACD Sell LineCrossunder
Histogram[period-1] - Histogram[period] > Trigger

**exit buy conditions:**
MACD / MACD Buy LineCrossunder
 and
Histogram[period-1] - Histogram[period] > Trigger

**exit sell conditions:**
MACD / MACD Sell LineCrossover
 and
Histogram[period-1] - Histogram[period] < Trigger

 [MACD Strategy.lua](files/18840/MACD%20Strategy.lua)

This is only first draft.
I hope that I understood the intent.


---

## Re: MACD CCI Strategy

**nicdu40** · Mon Nov 28, 2011 3:57 pm

yes it's what i say
just a change for me :

i change this
if core.crossesOver( Short["MACD"], MB , period)
 and math.abs(Short["Histogram"][period-1] - Short["Histogram"][period]) > Trigger
by:

if core.crossesOver( Short["Histogram", zero , period)
 and math.abs(Short["Histogram"][period-1] - Short["Histogram"][period]) > Trigger

or
if core.crossesOver( Short["MACD"], Short["signal"] , period)
 and math.abs(Short["Histogram"][period-1] - Short["Histogram"][period]) > Trigger

can you help me once more, i would want this strategy whith "macd+ cci + RSI + BB like the RSI-MACD-BB strategy
but this cci macd strategy base please
thank you .


---

## Re: MACD CCI Strategy

**Apprentice** · Mon Nov 28, 2011 6:11 pm

I need more info on second Strategy.
Entry And Exit Rules.


---

## Re: MACD CCI Strategy

**nicdu40** · Tue Nov 29, 2011 6:26 pm

ok :
macd/cci/rsi/bb startegy

CCIBS=CCI buy/sell level (level sell = -level buy)
RSIBS=CCI buy/sell level (level sell = -level buy)
CCICLOSE=CCI LEVEL close (~138)
MACDBS=MACD level buy/sell (level sell = -level buy)
Trigger=Trigger Level (~ 0.000158)
TriggerCLOSE= TriggerCLOSE ratio (~1.63)
BB_gapB= bb gap for long
BB_gapS= bb gab for short

buying condition:

if macd crossesover signal
and macd < - macdBS
and Histogram [period-1] - Histogram[period]) > Trigger
and rsi>RSIBS

selling condition:

if macd crossesunder signal
and macd > macdBS
and Histogram [period-1] - Histogram[period]) > Trigger
and rsi<-RSIBS
and bb
exit buy condition
if CCI crossesunder CCICLOSE
and Histogram [period-1] * TriggerCLOSE > Histogram [period]
and BB.TL[period]-BB.BL[period]>=BB_gapB*pipSize and source[period]>BB.AL[period]

exit sell condition
if CCI crossesover - CCICLOSE
and Histogram [period-1] * TriggerCLOSE > Histogram [period]
and BB.TL[period]-BB.BL[period]>=BB_gapS*pipSize and source[period]<BB.AL[period]

it is tests I will post the strategy optimized later
thank you


---

## Re: MACD CCI Strategy

**Apprentice** · Thu Dec 01, 2011 9:47 am

Your request is added to the developmental cue.


---

## Re: MACD CCI Strategy

**Apprentice** · Sat Dec 03, 2016 7:40 am

Bump up.


---

## Re: MACD CCI Strategy

**Avignon** · Fri Jul 26, 2019 8:07 am

Hello,

Already there is a bug in the notification: either I have the dialog box alert or I have the email alert, but not both at the same time. And for the same parity.

Otherwise I would like the following improvements:

- dialog box alert in option
- add end of turn

A model: [viewtopic.php?f=17&t=64970#p114057](http://www.fxcodebase.com/code/viewtopic.php?f=17&t=64970#p114057)

Thank you.


---

## Re: MACD CCI Strategy

**Apprentice** · Sun Jul 28, 2019 7:31 am

Your request is added to the development list under Id Number 4812


---

## Re: MACD CCI Strategy

**Apprentice** · Mon Jul 29, 2019 3:19 pm

Try it now.
(Topmost/First post in the topic)


---

## Re: MACD CCI Strategy

**Avignon** · Mon Jul 29, 2019 6:09 pm

Really? I saw some added features but not the ones requested.
