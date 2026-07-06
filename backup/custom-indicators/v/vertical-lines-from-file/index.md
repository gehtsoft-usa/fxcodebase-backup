# Vertical lines from file

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=14990  
> Forum: 17 · Topic 14990 · 8 post(s)


---

## Vertical lines from file

**Alexander.Gettinger** · Wed Mar 21, 2012 8:56 am

The indicator draws a vertical lines in accordance with the data from the file.

Strings of input file must have such format:
[Date] [Time] [R] [G] [B] [Style] [Size] [Name], where
Date - date of line with format MM/DD/YYYY,
Time - time of line with format HH:MM,
R, G, B are a components of line color,
Style, Size - style and size of line (style may be SOLID, DOT, DASH or DASHDOT),
Name - name of line.

You may not specify color, style, width and name of lines. In this case, will be used by the default settings.

Download:

 [DrawVerticalLines.lua](files/28406/DrawVerticalLines.lua)

Sample of input file:

 [VLSample.csv](files/28406/VLSample.csv)

The indicator was revised and updated


---

## Re: Vertical lines from file

**Rachid** · Tue Jun 26, 2012 12:54 pm

Hi,
Very nice Job Alexander

Is it possible to determine the height of the lines? for example EUR/USD between 1.20000 & 1.30000.

the price levels should be in the file too.

Thank you.


---

## Re: Vertical lines from file

**Apprentice** · Wed Jun 27, 2012 4:34 am

Your request is added to the development list.


---

## Re: Vertical lines from file

**Alexander.Gettinger** · Mon Jul 02, 2012 2:45 pm

The indicator with start and end prices of line.

Strings of input file must have such format:
[Date] [Time] [StartPrice] [EndPrice] [R] [G] [B] [Style] [Size] [Name], where
Date - date of line with format MM/DD/YYYY,
Time - time of line with format HH:MM,
StartPrice - start price of line,
EndPrice - end price of line,
R, G, B are a components of line color,
Style, Size - style and size of line (style may be SOLID, DOT, DASH or DASHDOT),
Name - name of line.

Download:

 [DrawVerticalLines2.lua](files/36404/DrawVerticalLines2.lua)


---

## Re: Vertical lines from file

**Apprentice** · Tue Apr 04, 2017 6:13 am

Indicator was revised and updated.


---

## Re: Vertical lines from file

**mayk01** · Mon Sep 18, 2023 3:07 am

Hello,
is it possible that there is some error in it?
It draws well on Eur/Usd, and also on major currency pairs, copper, but not on the others. The lines are not displayed, only the caption.
Is it possible to improve or extend for example to show the lines on SPX?

thanks,
M.


---

## Re: Vertical lines from file

**Apprentice** · Mon Sep 25, 2023 3:25 am

Try it now.


---

## Re: Vertical lines from file

**mayk01** · Mon Sep 25, 2023 4:17 am

Hi,
I tried it and it works!

thanks,
M.
