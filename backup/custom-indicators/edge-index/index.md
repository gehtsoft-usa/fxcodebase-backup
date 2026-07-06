# Edge Index

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60218  
> Forum: 17 · Topic 60218 · 2 post(s)


---

## Edge Index

**Apprentice** · Mon Jan 20, 2014 6:08 am

![Edge Index with Sorting.png](images/92140/Edge%20Index%20with%20Sorting.png)



Posted by request.
[viewtopic.php?f=27&t=60212](https://fxcodebase.com/code/viewtopic.php?f=27&t=60212)

F = FAST MOVING AVERAGE
M = MEDIUM MOVING AVERAGE
S = SLOW MOVING AVERAGE
R = ROC INDICATOR
RS = ROC SIGNAL LINE

IF F > M > S THEN XXX = +3 , YYY = -3
IF F < M > S THEN XXX = +2 , YYY = -1
IF F < M < S THEN XXX = -3 , YYY = +3
IF F > M < S THEN XXX = -1 , YYY = +2

IF R > RS > 0 LINE THEN XXX = +3 , YYY = -3
IF R < RS > 0 LINE THEN XXX = +2 , YYY = -1
IF R < RS < 0 LINE THEN XXX = -3 , YYY = +3
IF R > RS < 0 LINE THEN XXX = -1 , YYY = +2

For each instruments Edge Index is calculated as sum of individual scores for all currency pairs selected.

 [Edge Index.lua](files/92140/Edge%20Index.lua)

 [Edge Index with Sorting.lua](files/92140/Edge%20Index%20with%20Sorting.lua)

The indicator was revised and updated


---

## Re: Edge Index

**Apprentice** · Sun Jun 18, 2017 1:15 pm

The indicator was revised and updated.
