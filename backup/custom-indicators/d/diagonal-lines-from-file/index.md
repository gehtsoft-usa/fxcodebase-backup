# Diagonal lines from file

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65187  
> Forum: 17 · Topic 65187 · 2 post(s)


---

## Diagonal lines from file

**Alexander.Gettinger** · Fri Oct 20, 2017 10:13 am

Based on request: [viewtopic.php?f=27&t=64557](https://fxcodebase.com/code/viewtopic.php?f=27&t=64557)

The indicator draws diagonal lines in accordance with the data from the file.

Strings of input file must have such format:
Date1, Time1, Price1, Date2, Time2, Price2, R, G, B, Style, Size, where
Date1, Date2 - date of line points with format MM/DD/YYYY,
Time1, Time2 - time of line points with format HH:MM,
Price1, Price2 - prices of line points,
R, G, B are the components of line color,
Style, Size - style and size of the line (style may be SOLID, DOT, DASH or DASHDOT).

You may not specify color, style and width of lines. In this case, will be used by the default settings.

Download:

 [DrawDiagonalLines.lua](files/115521/DrawDiagonalLines.lua)

Sample of input file:

 [DLSample.csv](files/115521/DLSample.csv)


---

## Re: Diagonal lines from file

**Apprentice** · Tue Aug 07, 2018 4:52 am

The Indicator was revised and updated.
