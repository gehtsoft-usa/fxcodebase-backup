# DailyFX News Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=61584  
> Forum: 31 · Topic 61584 · 8 post(s)


---

## DailyFX News Strategy

**moomoofx** · Tue Dec 09, 2014 3:48 am

It's here! After a couple of years and a number of requests on here [viewtopic.php?f=17&t=1972](https://fxcodebase.com/code/viewtopic.php?f=17&t=1972) ... I have implemented a strategy based off the DailyFX News.

The strategy downloads the DailyFX News for the current week every n seconds and can be configured to trade depending on if news that comes out is <,>,= the expected/previous value, or greater than or less than zero (positive/negative). It does not depend on the above linked indicator to operate.

The configuration is a bit confusing but you can setup pretty much any combination of the above rules, like:
 When less than expected - sell
 or when less than previous - sell
 or when greater than zero - buy

To handle multiple possible rules, and multiple possible announcements at the same time, it assigns a point in each direction where the rule is met. So after it evaluates the configured rules for each news event if it had 10 buy rules be true and 5 sell rules be true, then the score is 10:5 and it will buy once.

Now - some news announcements have both a previous and expected value. It doesn't make sense to assign two points to the same news event, so you also have a parameter that allows you to choose if it should use previous or expected when the two would be applicable. The two would only be applicable if you have a rule setup for both the expected and previous values AND the news announcement has both expected AND previous values.

The strategy does not track if the news is due now or not, it simply keeps checking for updates and if there is suddenly a new Actual value in the file, then the news must have just come out. This means if the news is late you won't miss it, also if you set it up to only check the news every 4 hours, you'll get all 4 hours of news in one hit.

Additionally, there are other timing issues like.... suppose 8 items of news are supposed to be announced at 10:30:00 am, and you setup the strategy to check for new news every 10 seconds. If 4 news events come out at 10:30:05 and then the strategy checks at 10:30:10, it might trade.
5 seconds later at 10:30:15 another 3 news come out and at 10:30:20 the strategy sees the updates, it might trade again. When the final one comes out, it might trade again.

If you want to avoid this, don't check every 10 seconds The default is every 60 seconds. The minimum is 10 seconds to prevent everyone overloading the DailyFX server.

The last thing worth mentioning is the strategy appears to be back-testable, but I do not believe it would operate properly as I don't think it waits for the news to load properly before continuing. If requested, I'll try to find some way to make it work properly in the back-tester.

Cheers,
MooMooForex

The Strategy was revised and updated on December 11, 2018.


---

## Re: DailyFX News Strategy

**moomoofx** · Fri Jan 02, 2015 2:07 am

Hi,

Please note the file has been updated to fix the comma-separated instrument list functionality.

Cheers,
MooMooForex


---

## Re: DailyFX News Strategy

**thetruth** · Fri May 22, 2015 11:27 am

Exelent strategy, thanks! and good work!
i have an idea, some like "entry order strategy", for example you think that USD will be strong, then think in sell XXXUSD some pairs and buy USDXXX other pairs. then you decide put some entry orders (variable number) above or below some pips, in some specific symbols. this is possible? can you develop the idea?


---

## Re: DailyFX News Strategy

**Apprentice** · Mon Dec 12, 2016 3:47 pm

Strategy was revised and updated.


---

## Re: DailyFX News Strategy

**SANTOSH** · Sun May 03, 2020 4:15 pm

> **moomoofx wrote:**
> It's here! After a couple of years and a number of requests on here [viewtopic.php?f=17&t=1972](https://fxcodebase.com/code/viewtopic.php?f=17&t=1972) ... I have implemented a strategy based off the DailyFX News.
>
> The strategy downloads the DailyFX News for the current week every n seconds and can be configured to trade depending on if news that comes out is <,>,= the expected/previous value, or greater than or less than zero (positive/negative). It does not depend on the above linked indicator to operate.
>
> The configuration is a bit confusing but you can setup pretty much any combination of the above rules, like:
> When less than expected - sell
> or when less than previous - sell
> or when greater than zero - buy
>
> To handle multiple possible rules, and multiple possible announcements at the same time, it assigns a point in each direction where the rule is met. So after it evaluates the configured rules for each news event if it had 10 buy rules be true and 5 sell rules be true, then the score is 10:5 and it will buy once.
>
> Now - some news announcements have both a previous and expected value. It doesn't make sense to assign two points to the same news event, so you also have a parameter that allows you to choose if it should use previous or expected when the two would be applicable. The two would only be applicable if you have a rule setup for both the expected and previous values AND the news announcement has both expected AND previous values.
>
> The strategy does not track if the news is due now or not, it simply keeps checking for updates and if there is suddenly a new Actual value in the file, then the news must have just come out. This means if the news is late you won't miss it, also if you set it up to only check the news every 4 hours, you'll get all 4 hours of news in one hit.
>
> Additionally, there are other timing issues like.... suppose 8 items of news are supposed to be announced at 10:30:00 am, and you setup the strategy to check for new news every 10 seconds. If 4 news events come out at 10:30:05 and then the strategy checks at 10:30:10, it might trade.
> 5 seconds later at 10:30:15 another 3 news come out and at 10:30:20 the strategy sees the updates, it might trade again. When the final one comes out, it might trade again.
>
> If you want to avoid this, don't check every 10 seconds The default is every 60 seconds. The minimum is 10 seconds to prevent everyone overloading the DailyFX server.
>
> The last thing worth mentioning is the strategy appears to be back-testable, but I do not believe it would operate properly as I don't think it waits for the news to load properly before continuing. If requested, I'll try to find some way to make it work properly in the back-tester.
>
> Cheers,
> MooMooForex
>
> The Strategy was revised and updated on December 11, 2018.

Can be backtested in historical charts ?


---

## Re: DailyFX News Strategy

**Apprentice** · Mon May 04, 2020 4:23 am

Unfortunately no.
"Demo" is the only option.


---

## Re: DailyFX News Strategy

**SANTOSH** · Mon May 04, 2020 6:37 am

> **Apprentice wrote:**
> Unfortunately no.
> "Demo" is the only option.

In Simulation ?
Will the news alerts work ?


---

## Re: DailyFX News Strategy

**Apprentice** · Mon May 04, 2020 7:12 am

Log in to your demo account.
Should work there.
