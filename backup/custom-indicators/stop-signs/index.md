# Stop Signs

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=68498  
> Forum: 17 · Topic 68498 · 7 post(s)


---

## Stop Signs

**Apprentice** · Thu May 23, 2019 3:04 am

![EURGBP m1 (05-23-2019 0809).png](images/126498/EURGBP%20m1%20%2805-23-2019%200809%29.png)



Based on request.
[viewtopic.php?f=27&p=126494](https://fxcodebase.com/code/viewtopic.php?f=27&p=126494)

 [Stop Signs.lua](files/126498/Stop%20Signs.lua)


---

## Re: Stop Signs

**scafcid** · Thu May 23, 2019 2:41 pm

I am attaching this image thanks for your patience. It is not correct indicator before developed


---

## Re: Stop Signs

**Apprentice** · Fri May 24, 2019 4:31 am

Try it now.

Try to describe your idea.
If you look at the code, the formula is the same as yours.


---

## Re: Stop Signs

**scafcid** · Sat May 25, 2019 8:14 am

Level1[period]=(source.high[period] - 0.0001) - ???((source.high[period]-source.low[period]-0.0001) / 3) ;
	Level2[period]= (source.close[period] - 0.0001) - ???((source.low[period]-source.close[period]-0.0001) / 3);
	else
	Level1[period]=(source.close[period]+0.0001) +??? ((source.high[period]-source.close[period]-0.0001) / 3) ;
	Level2[period]=(source.high[period]+0.0001) +??? ((source.high[period]-source.low[period]-0.0001) / 3);
	end
i put question marks for the change in the code ,error is in having inverted the + with the - in the codes.


---

## Re: Stop Signs

**scafcid** · Sat May 25, 2019 8:38 am

my mistake then in the code red canverddles 2 level ... sorry.

rewrite: blue candles I have to find only two levels of blue / green stop calculation H - 0.0001 + [(H - L - 0.0001) / 3] then C - 0.0001 + [(C-- L - 0.0001) / 3]

red candles I have to find only two red levels
calculation L + 0.0001 - [(H - L - 0.0001) / 3] then C + 0.001 - [(H - C - 0.0001) / 3]

for it to be right there must be two levels per candle same color red candle red or green candle green
I look for an entrance against trend so I want to see where my stops are in reference H, C green candle, in the red candle in reference L, C
Thanks again


---

## Re: Stop Signs

**scafcid** · Thu May 30, 2019 8:38 am

Hi, I'm writing to you to know if you could check my annotations of the indicator.
Thanks again


---

## Re: Stop Signs

**Apprentice** · Sat Jun 01, 2019 9:48 am

Have a revised indicator formula.
Does not look promising.
Try to use actual price levels, both as input and result.
