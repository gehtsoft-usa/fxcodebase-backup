# Adaptive TD Sequential

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=3126  
> Forum: 17 · Topic 3126 · 4 post(s)


---

## Adaptive TD Sequential

**richardtao** · Mon Jan 10, 2011 3:21 am

The TDS indicator version 1 is applying of Trading Station II.
This Indicator is adapted base on TD Indicator.
The TD Indicator is registered by Tom DeMark, all rights are reserved.

The first part is Adaptive TD Sequential. The first three parameters are
"S: Setup Interval ", "C: Countdown Interval” And "N: Number of MA periods”.
Parameter N defines MA periods to identify finish flag by checking ma cross.
The default parameter setting 4,2 and 20.
You can enlarge S and C to fit the selected instrument.
Personal suggestion is the applying time frame not less than H1.
The TD Sequential rules for reference:
Duration 9 price bars Unlimited
Buy signal	9 consecutive price bar closes	13 price bars where each close
	that are less than the close 4 is less than or equal to the low
	price bars earlier 2 price bars earlier
Perfection - buy The low of either price bar 8	The low of price bar 13 must be
	or 9 must be less than the lows	less than or equal to the close of
	of both price bars 6 and 7 price bar 8
Sell signal	9 consecutive price bar closes	13 price bars where each close
	that are greater than the close is greater than or equal to the
	4 price bars earlier low 2 price bars earlier
Perfection - sell The high of either price bar 8 The high of price bar 13 must be
	or 9 must be greater than the greater than or equal to the close
	highs of both price bars 6 and 7 of price bar 8

These setups need to be practiced with caution.
1. The appearance of the second setup above 4 means the momentum of trend still strong. Better to cut lost.
2. Down trend finish “F” flag tag on Buy Countdown Sequential. Down trend finish tag on Sell Countdown Sequential. That could be help to confirm trend exhausting.
If you do not like those texts, you could set parameter “ShowSeq” as false.

 [TDS.lua](files/7300/TDS.lua)

The indicator was revised and updated


---

## Re: Adaptive TD Sequential

**FinnRe** · Fri Feb 08, 2013 9:04 am

This is clearly well coded, but ignores one of the most important features of TD Sequential - the count down is cancelled if there is a setup in the opposite direction. Without this you miss a lot of setups. Not entirely sure what the MA is needed for either.


---

## Re: Adaptive TD Sequential

**Jeffreyvnlk** · Sun Sep 28, 2014 6:03 am

It also missing INTERSECTION CONCEPT as well


---

## Re: Adaptive TD Sequential

**Apprentice** · Thu Jun 29, 2017 6:17 am

The indicator was revised and updated.
