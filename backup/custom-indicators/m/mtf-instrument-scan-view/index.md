# MTF INSTRUMENT SCAN VIEW

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63603  
> Forum: 17 · Topic 63603 · 6 post(s)


---

## MTF INSTRUMENT SCAN VIEW

**Apprentice** · Thu Jun 16, 2016 6:43 am

![MTF INSTRUMENT SCAN VIEW (06-16-2016 1724).png](images/106794/MTF%20INSTRUMENT%20SCAN%20VIEW%20%2806-16-2016%201724%29.png)



Based on request.
[viewtopic.php?f=27&t=63600](https://fxcodebase.com/code/viewtopic.php?f=27&t=63600)

 [MTF Instrument Scan View.lua](files/106794/MTF%20Instrument%20Scan%20View.lua)


---

## Re: MTF INSTRUMENT SCAN VIEW

**daniel.kovacik** · Thu Jun 16, 2016 9:19 am

Hi,

thanks, that was fast...

Will you also add, outside, inside?
Alco, could you add threshold for consecutive candles, where colour could be just darker...
I would erase those numbers for min. around and just add table, like I draw it...

I ll test it soon and let you know...

Regards,
DK


---

## Re: MTF INSTRUMENT SCAN VIEW

**Apprentice** · Sun Jun 19, 2016 3:43 am

> Also, could you add threshold for consecutive candles, where colour could be just darker...

Can you explain in more detail.


---

## Re: MTF INSTRUMENT SCAN VIEW

**Apprentice** · Thu May 10, 2018 6:14 am

The indicator was revised and updated.


---

## Re: MTF INSTRUMENT SCAN VIEW

**ainelle** · Sat Sep 22, 2018 8:54 pm

Hi Aprentice,
In this view, you are using core.host:execute("getHistory1"...) instead of core.host:execute("getHistory"...)

Where can we find a description of this function ?
why "getHistory" is not working ?


---

## Re: MTF INSTRUMENT SCAN VIEW

**Apprentice** · Sun Sep 23, 2018 5:17 am

In SDK help.
[http://fxcodebase.com/documentation.php](https://fxcodebase.com/documentation.php)

Code: [Select all](https://fxcodebase.com/code/)
`public method host:execute("getHistory1", ...)

Brief

Loads the history of the specified instrument.

Declaration
Lua
string host:execute ("getHistory1", cookie, instrument, barSize, count, to, bidOrAsk)
 

Parameters
cookie The integer value to be passed to the AsyncOperationFinished function of the indicator when data is loaded.
 
instrument The name of the instrument.
 
barSize The size of the bar. See also tick_stream:barSize() for information about the period codes.

Use "t1" to load ticks.
 
count The quantity of bars which will be returned by the system. The value must be positive.
 
to The date and time of the price collection end as a number. The number means the number of days past midnight December 30, 1899. Use 0 (zero) to get the data up to the current moment and leave the collection subscribed to the new data, so when a new tick arrives, the collection will be updated to contain the most fresh data. The default date is the current time.
 
bidOrAsk The flag indicating whether bid (true) or ask (false) prices must be loaded.
 

Details

The function returns either bar_stream or tick_stream depending on the bar size specified in the request.

This function is asynchronous, i.e. the data isn't available immediately. This function only starts loading of the data. When the loading is finished, the AsyncOperationFinished function of the indicator or strategy is called.

The recommended approach is the following:

1) Declare the global flag called loading and assign false by default.

2) In the Update() function, check the loading flag and its returns in case it is true.

3) When your indicator decides to load the data:

3.1) set the loading flag to true.

3.2) set a bookmark on the output stream on the first period which cannot be calculated without additional data.

3.3) call host:execute("getHistory1", ...) to start data loading.

4) In AsyncOperationFinished()

4.1) set the loading flag to false.

4.2) get the period of the bookmark set on the output stream.

4.3) call instance:updateFrom() using the bookmarked period as a parameter. The method forces recalculation of the indicator starting at the specified period.

Note: This function is optional and may be not supported by the host application.

Note: Please keep the object returned by the method in a global variable to avoid its removing by the garbage collector. Storing of the open, close and other tick sub-streams of the bar stream does not protect the main stream from being removed by the garbage collector.

The method can be used in both indicators and strategies.

Use host:execute("getHistory", ...) for loading data to the history.

Use also host:execute("extendHistory, ...) for loading more data to the history.

See also the host:execute("getSyncHistory", ...) method if you want to have the history synchronized with an indicator source.

Note: When debugging such indicators always switch on the "Pre-deliver data" option in the indicator parameters.`
