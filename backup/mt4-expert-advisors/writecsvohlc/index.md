# WriteCsvOHLC

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=72636  
> Forum: 38 · Topic 72636 · 7 post(s)


---

## WriteCsvOHLC

**Apprentice** · Wed Aug 17, 2022 1:49 am

Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=72605](https://fxcodebase.com/code/viewtopic.php?f=38&t=72605)

 [WriteCsvOHLC.mq4](files/147117/WriteCsvOHLC.mq4)


---

## Re: WriteCsvOHLC

**Honest_Trader** · Wed Aug 17, 2022 9:34 am

Thanks mate.

I am just getting one line with all the O-H-L-C having the same price.

Also would greatly help if we can have headers along with this for my analysis like below :

Date Time	Open	High Low Close	Volume
08-11-2022	09:15	483.15	484.85	477.5	483.85	79
08-11-2022	09:30	477.95	478.3	465.75	466.5	91
08-11-2022	09:45	467.7	479.6	467.7	474.1	68
08-11-2022	10:00	473.5	480.2	472 478.8	53
08-11-2022	10:15	478.25	479.6	470.95	476.55	39
xxxxxxxxx xxxxx xxxxxx xxxxx xxxxxx xxxxxx xx
xxxxxxxxx xxxxx xxxxxx xxxxx xxxxxx xxxxxx xx
xxxxxxxxx xxxxx xxxxxx xxxxx xxxxxx xxxxxx xx
xxxxxxxxx xxxxx xxxxxx xxxxx xxxxxx xxxxxx xx

and it should go on till end of the market for each and every instrument that I had attached this indicator to and put in separate .csv files along with the name of the instrument like gpbusd.csv,
eurusd.csv...... Like all other indicators, the data should be updated to .csv files in real time.

Thanks for your continued help mate, god bless.

Warm Regards
GK


---

## Re: WriteCsvOHLC

**Honest_Trader** · Wed Aug 17, 2022 10:38 am

Attaching a file (mql4 format) which seem to be doing exactly that I want, but need following changes if possible.

The file outputs in the following format to include :

Symbol	Date	DayOfWeek	DayOfYear	Open	High	Low	Close	RSI5	RSI11	MOM3_c	CCI11_c
GBPUSD	2022.08.17 20:00	3	229	1.2	1.2	1.2	1.2	54.05	72.39	101.29	102.29	-100.3	19

Dont know the last two columns as it doesnt carry any heading, and if we can remove it and keep the others.

Changes I would probably want is :

(1) This outputs only GBPUSD which is in the script (code). I want script to read the chart it is attached to and output the file in the same above format

(2) Need configurable options in the parameters as everything seem to be available only in the code :

Lookup bars :
RSI :
Overbought :
Oversold :
CCI :
Overbought :
Oversold :
Momentum :

Create a specific folder within "Files", just like your indicator.

Attaching both the indicator and the .csv file output for your ready reference.

Warm Regards
GK


---

## Re: WriteCsvOHLC

**Apprentice** · Thu Aug 18, 2022 8:16 am

We have added your request to the development list.
Development reference 497.


---

## Re: WriteCsvOHLC

**Honest_Trader** · Thu Aug 25, 2022 8:37 pm

Thank you mate, will check.

Currently out of station, will be back on 1st Sep and shall post my update.

Warm Regards
GK


---

## Re: WriteCsvOHLC

**Honest_Trader** · Sat Aug 27, 2022 7:50 am

Hello mate,

Seem to be working fine, but having some issues.

If you can check the attached file,

(1) I get a unknown number figure under Symbol column for many instruments
(2) Generally market opens at 8:45 hours and ends up at 14:45 hours. But in the attached file, probably because of that unknown 'number row at Row # 27', I get data that starts at 09:00 hrs to 15:00 hrs. If you check the file Apollohosp.csv you will probably understand this.

When you find time, could you look at the above issues please.

Thanks mate,

Cheers
GK


---

## Re: WriteCsvOHLC

**Apprentice** · Thu Sep 01, 2022 2:33 am

Try this version.

 [Write OHLC to CSV.mq4](files/147314/Write%20OHLC%20to%20CSV.mq4)
