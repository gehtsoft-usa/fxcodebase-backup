//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window
#property show_inputs

#include <WinUser32.mqh>
// The above include is missing some needed function(s)
#import "user32.dll"
   int      GetParent(int hWnd);
#import

/*
Readme:

(v1.6 - v1.9,etc. updates by pips4life, renamed to "P4L PeriodCon.mq4")

This new version adds substantial capability to the previous versions.
Offsets (timeshifts) are now fully supported for (almost) any multiple of any 
chart.  More than one of this indicator can be added to a single source chart 
to generate multiple offline charts with different offsets, e.g. an H1 chart 
can (theoretically) have 24 of this indicator added, each with different
hourly offsets, to generate 24 different Daily charts.  (It would not be
recommended for performance reasons but it *should* work; at least this
indicator is now architected differently to be able to do 24+ offset charts). 
As always, you must keep your source chart open at all times in order that
the generated "offline" charts get their live-updates with each tick.  FYI, 
in v1.7, charts with bars longer than 1 month work but are different from other
normal period charts due to limitations with MT4.  If the effective period 
is >1month, then EITHER the *symbol* name or the *period* will reflect the 
fact the chart is > 1-Month.

If variable "Over_1MN_alters_Symbol_name=true" (default), then the symbol name
will indicate the actual period as a multiple of the apparent period. Examples:
   2-month bars:  EURUSD_x2,Monthly   (2 x Monthly)
   6-week bars:   EURUSD_x6,Weekly    (6 x Weekly  = W6)
   12-month bars:   EURUSD_x12,Monthly  (12 x Monthly, i.e. Yearly)
   12-month +1 month timeshift:  
    (Not) EURUSD+1Nx12,Monthly  (NO!  Illegal 12-character symbol name!)
    (Use) EU+1N_x12,Monthly  (See ***Note)
   
(***Note, if a timeshift is also used, the symbol name will indicate both, BUT
due to an 11-character MT4 limit, the name may get hacked in order to shorten
it to keep within the character limit).

If variable "Over_1MN_alters_Symbol_name=false", then 
IT IS CRITICAL that you note the proper name of the generated offline chart 
that the program tells you (by popup alert) when you add this indicator to 
a chart.  You must then use the menu commands:
  File -> Open offline -> (scroll down to the *same* generated name)
     (e.g. "EURUSD+1H,Daily" is NOT the same chart as "EURUSD,Daily")
FYI, because of the new offline timeshifted chart name, this affects what 
the command "Symbol()" will return.  If you use other indicators that rely 
upon the Symbol() command (or NULL default) to be, e.g. exactly "EURUSD", 
then such programs may not work unless modified to be compatible with this 
new chart naming standard!  Please note that v1.5 had some support for hourly
offsets (on D1's), but the chart name used to be "EURUSD,1441".  The "1441" 
was also a problem for some indicators because it changed the "Period()" value
from the standard "1440" to the non-standard value of "1441".  This broke some
indicators -- but that was an older version and this indicator now returns
the standard values with respect to "Period()".

Another big change is that the older versions could only live-update a single
offline chart with a given name.  This version will live-update every offline 
chart that shares the same name.  (If for reasons of performance you decide
the old single-chart method works better for you, there is an external variable 
you can change to use the older method, but you are advised to open only one
of each offline chart. If "false", the 2nd-Nth ones open will not live-update).

The meaning of an offset such as "+1H" is as follows:  
Suppose you have opened the chart:  EURUSD+1H,Daily (offline)
At the top of your MT4 Market Watch window, the current "broker" time is given.
Suppose it says "21:45:00".  Your offline chart time is therefore "+1H" relative
to the "broker" time, which would be "22:45:00".  A new Daily candle will form
when the broker time is "23:00:00" which is when the "+1H" chart time 
is "00:00:00".

You will note that for the majority of broker feeds, there are SIX Daily candles
formed per week.  Usually there is a small Daily candle with either a Sunday 
date or a Saturday date depending on your broker's time offset.   If your broker,
regardless of broker time, has a trading week <= 5*24 hours (such as from
Sunday 5PM ET to Friday 5PM ET), then a key advantage of this indicator is that
you can choose a timeshift value such that the offline chart time of 00:00:00
corresponds to this key time of Sunday 5PM, ET (17:00:00).  By doing so, you can create 
an offline chart with only 5-bars-per-week!  This may be useful if you are drawing
trendlines or channels over a long period of time.  The slope (and therefore
price intercepts with the lines) will be different when you have 5 vs. 6 bars 
per week on your Daily charts.   Example:  Suppose you have a broker time which
corresponds to GMT.  At 00:00:00 GMT, it is 19:00:00 ST (7PM) in NY, depending on 
ST/DST dates AND depending on whether your broker follows NY ST/DST changeover
dates or some other choice of changeover dates!   What we would like is for an
offline "00:00:00" to correspond to 17:00:00 (5PM NY), so, we choose an offset
of "-2H".  This *MAY* give you the desired 5-bars-per-week.  Many factors are
involved such as what time of year it is vs. the ST/DST changeover dates, whether
your broker follows the U.S. ST/DST dates or some other dates like England or
Australia (or Japan which doesn't have DST).  It also depends on whether your
broker has only 5*24 hourly bars per week or less.  If you are lucky then your
new Daily chart will have 5 daily-bars-per-week year-round.  If it is inconsistent
with 5-per-week part of the year and 6-per-week a different part of the year,
then I don't recommend using that chart for critical slope/trendline intercepts.

Another useful consequence of supporting timeshifts is that you can convert the
broker time into your LOCAL time!  The bars on H1 or below are otherwise the
same shape.  (Bars above H1 like H4 and especially D1 may appear different
because the starting bar 00:00:00 time is now offset).   Suppose your broker
time says it is 21:45:00.   Your local time is 15:45:00.  The difference is
"-6H" which we can generate with a TimeShiftAdd_in_HptMM value.  Open a source chart 
(e.g. an M15), add this indicator, and generate an M15 offline chart (mult = 1)
with an offset of "-6H" which would be entered as "-6.0"  (-6hr + 0min)
The generated chart will then be "xxxxxx-6H,M15".   When you look at the times 
given on the X-axis of the chart, they will show you local times.  Open your 
native M15 chart and the offline M15 chart.  The bars should look exactly the 
same; only the times are different.

The external variable "TimeShiftAdd_in_HptMM" is a number entered as:  H.MM
Examples:   1.0 = 1hr,  1.30 OR 0.9 = 90min,  -0.05= -5min, -2.0 = -2hr
Note that "1.5" does NOT equal 90min, but rather 110min (60+50)! 
(FYI: This somewhat unusual style of number entry makes it easier to enter the
most common values which would be an integer number of hours.  However, you can
still enter a minute offset like 0.05 (5min) with ease.  The alternative would
either be to enter in bars or in minutes.  If in bars, one is constantly
calculating the shift_in_bars based on the current chart, be it M5, M15,
M30, H1, etc.   If entered in minutes, then large numbers of hours are
clumsy to calculate and remember (e.g 23hr*60m/hr = 1380min).  If it were in
pure hours, then how would one accurately enter 5min/60 = 0.0833333333...?! 
With the H.MM syntax, one can enter any timeshift accurately and with ease).

Many people use "CandleTime.mq4" or a variation to graphically display a
countdown timer for how much time is left before the latest bar closes.  As this
is very useful in conjunction with these offline charts, you MUST use a version
such as the new "P4L CandleTime.mq4" v1_6 (Nov 2009).  That program uses the
chart "Symbol()" name to find the chart offset and adjusts the remaining bar 
time accordingly.  Download "P4L CandleTime.mq4" from:
     http://www.forexfactory.com/showthread.php?t=109305


For example, at "21:45:00", a normal Daily chart bar would display "2:15:00" remaining
time for the most recent bar.  However, for the +1H,Daily chart, it should display
"1:15:00" remaining bar time.  The "P4L CandleTime.mq4" indicator also has an 
option to display the remaining time as a chart Comment. (Change an external variable).

Final comment re v1_6:  Note that MT5 is in beta and should be released in 2010.
Supposedly any timeframe chart (in minutes) can be generated with MT5 (e.g. M10, 
M20, H2, H8, ...  I do not know what the maximum supported value is).  Therefore,
you might already be able to accomplish some of your non-standard timeframe 
requirements using a demo MT5 account even today. (Search for MT5 download).
However, I am unfamiliar with the details of MT5 and I cannot say whether or not
the timeshift feature will be available in basic MT5 or whether a new indicator 
or EA must be written to accomplish the same timeshift feature as this indicator
does on MT4.  I guess we'll find out together...


Comments regarding the previous v1_5 update are left here for additional reference:

I. (v1.5 update) Features:
This is an improved version of period converter for MT4 based on the
MT4's default period converter by metaquotes.
The default period converter script do not support real-time refreshing,
and consume lots of CPU (50%-9x%) making the whole system slow.
Also, the default one is a script which do not save when you exit MT4,
so you have to apply every converter script again after restarting, quite
annoying.

This one fixed all above problems:
1. Real-time updating or custom interval millisecond level updating.
2. Low CPU cost, average 5%-10% or less.
3. Works as an indicator, so can be saved and reloaded during restart. 
4. There is no one converter per chart limitation as it is not script
   any more, you can only use one window as source to generate as many
   new timeframe charts as possible.
5. Auto updating if there is new history block loaded.

II. How to use:
Copy the mq4 file to your MT4 indicators folder (experts\indicators)
to install it as an indicator, NOT script. then in the custom indicator 
list, attach period_converter_opt to the chart you want.
It support 4 parameters:
PeriodMultiplier:    new period multiplier factor, default is 2
UpdateInterval_in_msec:      update interval in milliseconds, 
                     zero means update real-time. default is zero.
Indicator_On:        You can disable it without remove it with this option.

Other parameters are comments or for debugging, it is safe to ignore them.

Also Make sure you have Allow Dll imports option checked in common tab or
it won't work

After that, File->Open Offline to open the generated offline data. then
the offline data will be updated automatically.

As long as you keep the source chart open and the converter indicator 
running, the generated chart including indicators inside will always 
be updated. also you can close the generated chart and open again 
later from File->Open Offline without problem.

If you want to quit MT4, you can leave those offline chart as other
normal online charts. when you start MT4 next time, those charts will
also be loaded and updated.


III. Notes:
1. Do NOT uncheck the "offline chart" option in offline chart common properties.
   or after MT4 restart, it will treat that chart as online chart and request
   the data from server, resulting empty chart window.
2. You can attach more than one converter to same window with different 
   PeriodMultiplier, e.g: you can attach 3 converter with 
   PeriodMultiplier = 2, 4, 10 to M1 to generate M2, M4, M10 at the same time.
   It is even ok to use the M1 chart to generate Hourly chart like H2, which
   only cost a few more CPU resource during initial conversion. but usually 
   most server don't have much data for those short period. resulting the 
   generated data isn't long enough for long period. so it is suggested 
   to use Hourly/Daily charts as source when needed.
3. The real-time updating mode updates quotes as fast as possible, but as
   this is done via script, and MT will skip calling start() function when
   your PC is busy and lots of quotes income. anyway, this seldom happen,
   and you can at least get 10 updates each seconds which is much more
   than enough.
4. The offline chart don't have a bid line showing in chart, but all data
   in the chart including the indicators is still being updated, 
   so don't worry. you can show the bid line by unclick the "offline chart" 
   option in chart properties. but which don't helps much and if you forget
   to check "offline chart" option before exit. it will cause errors and
   become empty on next startup. you have to close the window and open
   again from File->Open offline, which don't worth the trouble.


IV. History:
***NOTE: With every release, also update the FYI_Version and FYI_BuildInfo variables below.
2012.10.15  v1.11 by pips4life  
    Variable "InvertChart" (false) added.  If "True", an inverted chart is output with an "i" as
       a prefix to the symbol name.  (e.g. iEURUSD,H1)
    New external variables:
      InvertedOutputMultiplier = 1.0   The inverted prices are = InvertedOutputMultiplier/price.
      InvertedOutputDigits = -1, where -1 is Automatic (a guess), or the user can manually set to >= 0
        Example: Invert USDJPY to get iUSDJPY (same as JPYUSD). Set InvertedOutputMultiplier=1000.0, and
        set InvertedOutputDigits=3 (or 4).  A price of 79.275 would normally invert to 0.012614 but with
        these overrides, inverted price would be 12.614
    Changed primary message from:  Looking for one or more charts named: EURUSD,H12 (offline) (Timeshifted by 0min)
       to: P4L PeriodCon: Do File->Open_Offline of chart: EURUSD,H12 (offline) (Time shifted 0min) and KEEP this Source H1 OPEN!
       If the multi-chart-update option is false, the message is similar except for:  "... Open_Offline of ONLY *ONE* chart: ..."
       All the rest of the popup messages now start with "P4L PeriodCon".
    (Fyi, skipped "v1.10" because as a double var it would look the same as "v1.1")
2011.03.23  v1.9
    Changes to fix *some* of the problems with higher timeframes >=Daily.  The charts would sometimes have
       an arbitrary starting day-of-week, or day-of-month.  Some of those problems are fixed, although the
       use of timeshifts may or may not work in conjunction with the larger timeframes.  This version uses
       a somewhat better algorithm to slice up the time periods, but some things are irregular and tougher
       to solve, like telling a monthly chart to offset by -2 days.  Is that the 31st-2 = 29th?? What if there's
       no "29th" like non-leap Februarys?  Should is always mean the last-day-of-month minus 2?  These questions
       have no absolute answers, however most people wouldn't even care or try to generate such esoteric 
       charts.
    Cosmetic corrections to external FYI_Version and FYI_BuildInfo variables which were incorrect in v1.8 (they still said v1.7).     
2009.12.10  v1.8     
    New external variable: Over_1MN_alters_Symbol_name = true (default; more readable).  If you prefer
      NOT to change the Symbol name for charts > 1-Month, then "false" will alter the Period() instead.
      Indicators that care more about the Symbol() name may be compatible, so long as they
      don't care about getting a correct "Period()" value (which is always wrong anyway for 
      any chart > 1-Month, due to MT4 limitations and the hack this program used to get around this).
2009.12.07  1.7      (By pips4life of forexfactory, enhanced based on an idea by circlesquare)
                     Added external variable:  TimeShiftAdd_in_Bars
                      Note, this value ADDS to any timeshift specified by TimeShiftAdd_in_HptMM.
                      The "Bars" syntax is much easier for very high timeframe timeshifts whereas
                      the "H.MM" syntax is easier for low timeframe timeshifts.
                      
                     This version supports the generation of charts with Period > Monthly.
                      The "Symbol()" name uses new syntax to indicate the period is higher
                      than 1 month (which MT4 cannot display unless tricked into thinking it
                      is <= 1-month).  Here are chartname ("Symbol,Period")  syntax examples:  
                          EURUSD_x2,Monthly (MN2 chart)
                          EURUSD-1Nx2,Monthly (MN2 chart, offset by "-1N" (1 Month) (NOTE: "N" not "MN" or "M")
                          EURUSD-1Wx5,Weekly (W5 chart, offset by -1W timeshift)
                          EURUSD_x12,Monthly (MN12 (i.e. Yearly) chart)
                          EURUSD+1Nx12 (ILLEGAL 12-character name!  NOT created!)
                          EU+1N_x12 (EURUSD is shortened to "EU".  The "_" before "x" is used if within character limit).
                          SEKRUB+1Nx,M43188 ( An unusual example, but if the symbol name is not
                            shortened, and a timeshift is used, and there is no room left (within
                            the 11-characters max) to add the "x#" (# = PeriodMultiplier), then the
                            reported period is the source chart "Period() - PeriodMultiplier".  In this
                            example, M43188 was from Monthly(43200) - 12 (A Monthly chart - PeriodMultiple-of-12)
                            There was no room for "x12" but there was room for just "x" so it was added.
                            Final result:  This is a Yearly (1 bar is 12mo) chart, timeshifted by +1Month.
                     NOTE: The MT4 symbol length limit is only 11.  This requires a lot more
                       hacking and jumping through hoops to keep below this character limit 
                       whenever a timeshift is used for a chart TF > Monthly, or whenever a 
                       large number timeshift is used (regardless of chart TF) that would
                       cause the symbol name to exceed 11 characters.
                     The next v1_3 "P4L CandleTime.mq4" will have the routines needed to unconvert the
                       strange changes to symbol and/or period to get the true effective
                       symbol, period, and timeshift values.
                      
2009.11.11  1.6      (By pips4life of forexfactory, partly based on an idea by rangebound)
                     Users can now open same-timeframe charts with different (multiple)
                      timeshifts.  For example, open an H1 chart and add multiple instances
                      of this indicator, each with multiplier=24, but use several different
                      timeshift values.  This highly-useful feature will show what the bars look
                      like if the start/stop times are shifted by any number of hour(s).
                      Similarly, do the same thing for H4 charts. Compare your native H4 charts
                      with the 3 possible others charts that use timeshifts of 1,2, and 3 hours.
                     Added support for real-time updating of *multiple* offline windows.
                      In other words, you can open 2 or more M10 charts and each will update.
                      Because it loops and checks every window, there *may* be a cost in
                      CPU time.  If you desire only to update the first-found offline
                      chart, go back to the old method by setting LiveUpdateMultipleCharts=false.
                     A few other updates to variable names were made for clarity.  The meaning
                      of the old "TimeShift" was clarified (and is reversed from the previous meaning
                      which had previously subtracted from the broker time; now "+" means ADD).
                     Known problem(s):
                       Adding this indicator to a Monthly chart with PeriodMultipler=2 should
                       generate a ",MN2" chart but the "Open offline" list displays it as ",D60".
                       More importantly, even if you open that ",D60" chart it doesn't seem to work!
                       In fact, anything above a ",Monthly" chart appears not to work (MT4 v4.00 Build 225)
                     
2006.02.16  1.5      (By ???)
                     Added (discontinued) TimeShift (in bars) option, can be used to shift hour 
                     timeframe to generate daily timeframe when your timezone is different
                     from the server, default is zero.
2005.12.24  1.4      (By wfy05@talkforex.com)
                     faster to detect if data changed by removing float point 
                     operations, added support to output CSV file in real time.
                     OutputCSVFile = 0 means no CSV.
                     OutputCSVFile = 1 means CSV + HST
                     OutputCSVFile = 2 CSV only, no HST .
                     (useful if you want to generate CSV for builtin periods)
                     CSV Filename will be the same as HST file except the extension.
                     added safe checking for PeriodMultiplier.
2005.12.04  1.3      Fixed missing data when there is large amount of data
                     loaded in several blocks, and support auto updating
                     when new history is loaded.
2005.11.29  1.2      Additional fix for missing data and server changing.
2005.11.29  1.1      Fixed missing partial data after restart.
                     Reinitialize after changing server or data corrupted.
2005.11.28  1.0      Initial release

FUTURE PLANS:
* Detect whether this indicator was added to an "offline" chart (which is not
typically how it should be done, and may not even work but nothing flags it).
One problem: Adding this to a timeshifted "+1H,2H" with PM=2 results in the
error message that the "H4" cannot be created (because timeshift=0) even though
the offline chart-as-source is already time-shifted.
*/


extern double  FYI_Version                     = 1.11;   // code version
extern string  FYI_BuildInfo                   = "2012.10.15 by pips4life of ForexFactory";
extern int     PeriodMultiplier                = 2;      // new period multiplier factor
extern string  FYI_TimeShift_HptMM             = "H.MM 1.0=1hr, 1.3 or 0.9=90min, -0.05= -5min"; //NOTE: "1.5" is NOT 90min but 110min!
extern double  TimeShiftAdd_in_HptMM           = 0.0;    // time shift value, H.MM.
extern int     TimeShiftAdd_in_Bars            = 0;      // time shift value in Bars (easier for higher timeframes). NOTE: The two timeshifts ADD!! (Both are in effect!)
extern bool    InvertChart                     = false;  // If True, all bar data values are inverted.
extern double  InvertedOutputMultiplier        = 1.0;
extern string  _INFO_InvOut_Digits_____        = "-1 is Auto, or set to >= 0";
extern int     InvertedOutputDigits            = -1;
extern int     UpdateInterval_in_msec          = 0;      // update interval in milliseconds, zero means update real-time.
extern string  FYI_OutputCSVFile               = "0=HST only; 1=CSV+HST; 2=CSV only";
extern int     OutputCSVFile                   = 0;      // also output CSV file? (CSV means "comma separated values". File can be imported into various tools & programs)
extern bool    LiveUpdateMultipleCharts        = true;   //True (recommended) is more CPU but will update all offline charts found.
extern bool    LimitedAlertsEnabled            = true;   // Sometimes an Alert is the best way to notify you rather than the experts (Print) log.
extern bool    Over_1MN_alters_Symbol_name     = true;   // If true, Symbol() name changes, if false, Period = (Period() - PeriodMultiplier). Chartname is "symbol,period", so...
                                                         //   Examples:  If true, 2-mo chart: EURUSD_x2,Monthly  False: EURUSD,M43198  (where PERIOD_MN1=43200, and 43200-2=43198)
                                                         //   If true, 5-wk chart: EURUSD_x5,Weekly   False: EURUSD,M10075  (where PERIOD_W1=10080, and 10080-5=10075)
                                                         //   Choice "false" is for indicators (especially MTF) that require the normal "Symbol()" name, but don't 
                                                         //   care about "Period()"
                                                         //   NOTE: A timeshifted chart (ANY timeframe) must always change the Symbol() name, e.g. EURUSD+1H,Daily
extern bool    Indicator_On                    = true;   // "False" is an easy way to disable without removing from the source chart.
bool    Debug = false; //Generally for developer use

// Regarding the auto-adjustment of the symbol name:
// Always pay attention to the chart name it tells you it will generate so you will know which offline
// chartname to open!   See the experts log or maybe an Alert.
// Unless you have a non-zero timeshift, you cannot create an offline chart with the same name as a 
// regular period: M1,M5,M10,M15,M30,H1,H4,D1(Daily),W1(Weekly),MN1(Monthly)
// If your TimeShiftAdd_in_HptMM is "0", and the new period is not a standard period, it will be called, e.g., "EURUSD,H2".
// If you have a Daily chart with positive time shift of 2 hours, the name would be "EURUSD+2H,D1"
// Similarly, a time shift of -2 hours would be "EURUSD-H2,D1".



int      FileHandle = -1;
int      CSVHandle = -1;
int      NewPeriod = 0;
int      NewPeriodDisplayed;

string   symbol;
string   symboloutput;

#define OUTPUT_HST_ONLY    0
#define OUTPUT_CSV_HST     1
#define OUTPUT_CSV_ONLY    2

#define  CHART_CMD_UPDATE_DATA            33324

// GetWindowTextA overwrites gwstr but it should initially be at least as long a string as it will become later.
//            //12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789  //119 chars                                                                                                                  "};
string gwstr = "                                                                                                                       ";
string offlineChartName;
string sourceChartMsg, sourceChartTF;
int TimeShiftAdd_in_Minutes;

bool FLAG_NO_OFFLINE_CHART = false;
bool FLAG_FIRSTINITDONE = false;
bool FLAG_ERRORFOUND = false;

static double d_open, d_low, d_high, d_close, d_volume;
static int i_time;

//====================
int init()
{
   sourceChartTF = PeriodToString(Period(),true);
   sourceChartMsg = StringConcatenate(WindowExpertName(),",",Symbol(),",",sourceChartTF," :");
   
   string msg;
   int intShiftByNum;
   string strShiftByUnit;
   
   //TimeShiftAdd_in_Minutes = TimeShiftAdd_in_Bars*Period();
   
   TimeShiftAdd_in_Minutes = MathFloor(TimeShiftAdd_in_HptMM)*60 + MathMod(TimeShiftAdd_in_HptMM*100,100) + TimeShiftAdd_in_Bars * Period();
   if (MathMod(TimeShiftAdd_in_Minutes,Period() ) != 0)
   {
   //ERROR. TimeShift must be an even multiple of the source chart Period()
     msg = StringConcatenate(sourceChartMsg,"ERROR. Illegal TimeShift value: ",TimeShiftAdd_in_Minutes,"min must be a multiple of SOURCE timeframe ",Period()," (",sourceChartTF,")" );
     Alert(msg); // This is critical so it is forced to Alert
     //if (!FLAG_FIRSTINITDONE)
     //{
     //    if (LimitedAlertsEnabled) Alert(msg);
     //    else Print(msg);
     //}
     return(-1);
   }
   
   
   //safe checking for PeriodMultiplier.
   if (PeriodMultiplier <= 1) {
      PeriodMultiplier = 1;
      //only output CSV file?  Usually the point of PeriodMultiplier == 1, timeshift=0, AND not inverted would be to have a CSV file.
      if (!InvertChart && TimeShiftAdd_in_Minutes == 0) OutputCSVFile = 1; // Changed from "2" to "1" to cause a better popup message.(No offline, but CSV created)
   }
   
   NewPeriod = Period() * PeriodMultiplier;
   //if(Period() * PeriodMultiplier < PERIOD_MN1) NewPeriod = Period() * PeriodMultiplier;
   //else NewPeriod = Period()-PeriodMultiplier;//feel free to change how you come up with an obscure tf lower than monthly.
   //NewPeriod2=Period() * PeriodMultiplier;
   symbol = Symbol();
   
   // Figure out the timeshift string to be added to the offline Symbol() name:
   //if (MathMod(TimeShiftAdd_in_Minutes,PERIOD_MN1) == 0) {strShiftByUnit= "MN"; intShiftByNum = TimeShiftAdd_in_Minutes/PERIOD_MN1;}
   if (MathMod(TimeShiftAdd_in_Minutes,PERIOD_MN1) == 0) {strShiftByUnit= "N"; intShiftByNum = TimeShiftAdd_in_Minutes/PERIOD_MN1;} // Need to stay within char. limit, so "N" used, not "MN"
   else if (MathMod(TimeShiftAdd_in_Minutes,PERIOD_W1) == 0) {strShiftByUnit= "W"; intShiftByNum = TimeShiftAdd_in_Minutes/PERIOD_W1;}
   else if (MathMod(TimeShiftAdd_in_Minutes,PERIOD_D1) == 0) {strShiftByUnit= "D"; intShiftByNum = TimeShiftAdd_in_Minutes/PERIOD_D1;}
   else if (MathMod(TimeShiftAdd_in_Minutes,PERIOD_H1) == 0) {strShiftByUnit= "H"; intShiftByNum = TimeShiftAdd_in_Minutes/PERIOD_H1;}
   else {strShiftByUnit= "M"; intShiftByNum = TimeShiftAdd_in_Minutes;}
     
   if (!InvertChart && intShiftByNum == 0 && OutputCSVFile != OUTPUT_CSV_ONLY && (NewPeriod == PERIOD_M1 || NewPeriod == PERIOD_M5 || NewPeriod == PERIOD_M15 // || NewPeriod == 10 //e.g. Oanda has M10.
        || NewPeriod == PERIOD_M30 || NewPeriod == PERIOD_H1 || NewPeriod == PERIOD_H4 || NewPeriod == PERIOD_D1
        || NewPeriod == PERIOD_W1 || NewPeriod == PERIOD_MN1 ))   
   {
     symboloutput = symbol;
     FLAG_NO_OFFLINE_CHART = true; // One cannot generate an offline chart with the same name as a regular TF chart!
     if (OutputCSVFile != OUTPUT_HST_ONLY) OutputCSVFile = OUTPUT_CSV_ONLY; //2
   }
   else if (intShiftByNum > 0) symboloutput = StringConcatenate(symbol,"+",DoubleToStr(intShiftByNum,0),strShiftByUnit);
   else if (intShiftByNum < 0) symboloutput = StringConcatenate(symbol,DoubleToStr(intShiftByNum,0),strShiftByUnit); //negative
   else symboloutput = symbol;
   
   //if (InvertChart) symboloutput = StringConcatenate(symboloutput,"i");
   if (InvertChart) symboloutput = StringConcatenate("i",symboloutput);
   
   if (StringLen(symboloutput) > 11) symboloutput = shortenSymbol(symboloutput);
   
   symboloutput = StringSubstr(symboloutput,0,11); // The MAX number of characters for symboloutput is 11, no matter what the offset.
   
   NewPeriodDisplayed = NewPeriod;
   if (NewPeriod > PERIOD_MN1)
   {
     msg = StringConcatenate(sourceChartMsg,"NOTE: For charts > 1-month period, be aware of variable: Over_1MN_alters_Symbol_name");
     if (!FLAG_FIRSTINITDONE)
     {
       if (LimitedAlertsEnabled) Alert(msg);
       else Print(msg);
     }
     
     int solen = StringLen(symboloutput);
     int pmlen = StringLen(DoubleToStr(PeriodMultiplier,0));
     if ( solen+pmlen > 10) symboloutput = shortenSymbol(symboloutput);
     solen = StringLen(symboloutput);
     if ( Over_1MN_alters_Symbol_name && solen+pmlen <= 9)
     {
       NewPeriodDisplayed = Period();
       symboloutput = StringConcatenate(symboloutput,"_x",PeriodMultiplier); //<=9 plus 2chars "_x" is always <= 11 MAX
     }
     else if ( Over_1MN_alters_Symbol_name && solen+pmlen == 10 && intShiftByNum != 0)
     {
       NewPeriodDisplayed = Period();
       symboloutput = StringConcatenate(symboloutput,"x",PeriodMultiplier); // ==10 plus 1 char "x" is == 11 MAX, but there must be a "+" or "-" from a timeshift.
     }
     else
     {
       if ( Over_1MN_alters_Symbol_name && solen <= 10) symboloutput = StringConcatenate(symboloutput,"x"); //The "x" will help to know a larger TF was used.
       NewPeriodDisplayed = Period() - PeriodMultiplier;
       if (NewPeriodDisplayed <= 0) NewPeriodDisplayed = 101; //arbitrary (preferably prime) number 
     }
   }
   
   if (NewPeriodDisplayed == PERIOD_MN1)
     offlineChartName = StringConcatenate(symboloutput,",Monthly (offline)"); //Note, there is no "MN2". Instead it would be D60, but MT4 doesn't handle it (directly).
   else if (MathMod(NewPeriodDisplayed,PERIOD_W1) == 0)
   {
     if (NewPeriodDisplayed == PERIOD_W1) offlineChartName = StringConcatenate(symboloutput,",Weekly (offline)");
     else offlineChartName = StringConcatenate(symboloutput,",W",DoubleToStr(NewPeriodDisplayed/PERIOD_W1,0)," (offline)");
   }
   else if (MathMod(NewPeriodDisplayed,PERIOD_D1) == 0)
   {
     if (NewPeriodDisplayed == PERIOD_D1) offlineChartName = StringConcatenate(symboloutput,",Daily (offline)");
     else offlineChartName = StringConcatenate(symboloutput,",D",DoubleToStr(NewPeriodDisplayed/PERIOD_D1,0)," (offline)");
   }
   else if (MathMod(NewPeriodDisplayed,PERIOD_H1) == 0)
     offlineChartName = StringConcatenate(symboloutput,",H",DoubleToStr(NewPeriodDisplayed/PERIOD_H1,0)," (offline)");
   else
     offlineChartName = StringConcatenate(symboloutput,",M",NewPeriodDisplayed," (offline)");
   
   
   
   if (OpenHistoryAndCSVFiles() < 0) return (-1);
   WriteHistoryHeader();
   UpdateHistoryFile(Bars-1, true);
   
   if (FLAG_NO_OFFLINE_CHART)
   {
     msg = StringConcatenate(sourceChartMsg,"No offline chart because it already exists: ",StringSubstr(offlineChartName,0,StringLen(offlineChartName)-10),"  (shift 0min)");
     if (OutputCSVFile != OUTPUT_HST_ONLY) msg = StringConcatenate(msg," However, CSV file will be created");
     if (!FLAG_FIRSTINITDONE)
     {
        if (LimitedAlertsEnabled) Alert(msg);
        else Print(msg);
     }
   }
   else if (OutputCSVFile == OUTPUT_CSV_ONLY)
   {
     msg = StringConcatenate(sourceChartMsg,"CSV file will be created: ",StringSubstr(offlineChartName,0,StringLen(offlineChartName)-10),".csv   (Time shifted by ",DoubleToStr(TimeShiftAdd_in_Minutes,0),"min )");
     if (!FLAG_FIRSTINITDONE)
     {
        if (LimitedAlertsEnabled) Alert(msg);
        else Print(msg);
     }
   }
   else if (LiveUpdateMultipleCharts) 
   {
     //msg = StringConcatenate("Looking for one or more charts named: ",offlineChartName,"   (Time shifted by ",DoubleToStr(TimeShiftAdd_in_Minutes,0),"min )");
     msg = StringConcatenate(sourceChartMsg,"Do File->Open_Offline of chart: ",offlineChartName,"   (Time shifted ",DoubleToStr(TimeShiftAdd_in_Minutes,0),"min) and KEEP this Source ",sourceChartTF," OPEN!");
     if (OutputCSVFile != OUTPUT_HST_ONLY) msg = StringConcatenate(msg," CSV file will also be created");
     if (!FLAG_FIRSTINITDONE)
     {
        if (LimitedAlertsEnabled) Alert(msg);
        else Print(msg);
     }
     UpdateMultipleChartWindows();
   }
   else 
   {
     //msg = StringConcatenate("Looking for ONLY the FIRST FOUND chart named: ",offlineChartName,"  Others will not live-update!   (Time shifted by ",DoubleToStr(TimeShiftAdd_in_Minutes,0),"min )");
     msg = StringConcatenate(sourceChartMsg,"Do File->Open_Offline of ONLY *ONE* chart named: ",offlineChartName,"   (Time shifted ",DoubleToStr(TimeShiftAdd_in_Minutes,0),"min) and KEEP this Source ",sourceChartTF," OPEN! 2nd-Nth chart will NOT live-update!");
     if (OutputCSVFile != OUTPUT_HST_ONLY) msg = StringConcatenate(msg," CSV file will also be created");
     if (!FLAG_FIRSTINITDONE)
     {
        if (LimitedAlertsEnabled) Alert(msg);
        else Print(msg);
     }
     UpdateChartWindow();
   }
   
   if (IsDllsAllowed() == false) 
   {
     //DLL calls must be allowed
     msg = StringConcatenate(sourceChartMsg,"ERROR. Will not work unless you turn on: Allow DLL imports");
     Alert(msg); // This is critical so it is forced to Alert
     //if (!FLAG_FIRSTINITDONE)
     //{
     //   if (LimitedAlertsEnabled) Alert(msg);
     //   else Print(msg);
     //}
   }
   
   if (StringLen(symboloutput) > 11)
   {
      msg = StringConcatenate(sourceChartMsg,"Probable ERROR. MT4 cannot open offline charts with symbol name > 11 characters: ",symboloutput);
      if (!FLAG_FIRSTINITDONE)
      {
         if (LimitedAlertsEnabled) Alert(msg);
         else Print(msg);
      }
   }
      
   FLAG_FIRSTINITDONE = true; // This is used to prevent double "Alert" commands when init() is executed again by other routines.
   return (0);
} // end of init()

void deinit()
{
   //Close file handle
   if(FileHandle >=  0) { 
      FileClose(FileHandle); 
      FileHandle = -1; 
   }
   if (CSVHandle >= 0) {
      FileClose(CSVHandle);
      CSVHandle = -1; 
   }
} // end of deinit()



//+------------------------------------------------------------------+
//| program start function                                           |
//+------------------------------------------------------------------+
int start()
{
   static int last_time = 0;

   if (!Indicator_On) return (0);
         
   //always update or update only after certain interval
   if (UpdateInterval_in_msec !=  0) {
      int cur_time;
      
      cur_time = GetTickCount();
      if (MathAbs(cur_time - last_time) < UpdateInterval_in_msec) {
         return (0);
      }
      last_time = cur_time;
   }

   //if (Debug) PerfCheck(true);
   int n = CheckNewData();
   //if (Debug) PerfCheck(false);   
   if (n < 0) return (0);

   //update history file with new data
   UpdateHistoryFile(n);
   
   
   //refresh chart window
   if (LiveUpdateMultipleCharts) UpdateMultipleChartWindows();
   else UpdateChartWindow();
   
   //if (Debug) PerfCheck(false);
   return(0);
} // end of start()



int OpenHistoryAndCSVFiles()
{
   string fileOpenChartName;
   
   fileOpenChartName = StringConcatenate(symboloutput,DoubleToStr(NewPeriodDisplayed,0));
   if (!FLAG_NO_OFFLINE_CHART && OutputCSVFile != OUTPUT_CSV_ONLY) {
      FileHandle = FileOpenHistory(fileOpenChartName + ".hst", FILE_BIN|FILE_WRITE);
      if (FileHandle < 0) return(-1);
   }
   if (OutputCSVFile != OUTPUT_HST_ONLY) {
      CSVHandle = FileOpen(fileOpenChartName + ".csv", FILE_CSV|FILE_WRITE, ',');
      if (CSVHandle < 0) return(-1);
   }
   return (0);
} // end of OpenHistoryAndCSVFiles

int WriteHistoryHeader()
{
   string c_copyright;
   int    i_digits = Digits; // For a non-inverted chart.
   if (InvertChart)
   {
      // For an inverted chart:
      if (InvertedOutputDigits >= 0) i_digits = InvertedOutputDigits;
      else if (i_digits <= 1) i_digits = 8;
      else if (i_digits <= 3) i_digits = 6;
      else i_digits = 5;
   }
   int    i_unused[13] = {0};
   int    version = 400;   
   
   if (FileHandle < 0) return (-1);
   c_copyright = "(C)opyright 2003, MetaQuotes Software Corp.";
   FileWriteInteger(FileHandle, version, LONG_VALUE);
   FileWriteString(FileHandle, c_copyright, 64);
   FileWriteString(FileHandle, symboloutput, 12);
   FileWriteInteger(FileHandle, NewPeriodDisplayed, LONG_VALUE);
   FileWriteInteger(FileHandle, i_digits, LONG_VALUE);
   FileWriteInteger(FileHandle, 0, LONG_VALUE);       //timesign
   FileWriteInteger(FileHandle, 0, LONG_VALUE);       //last_sync
   FileWriteArray(FileHandle, i_unused, 0, ArraySize(i_unused));
   return (0);
} // end of WriteHistoryHeader


void WriteHistoryData()
{
   double d_openi, d_lowi, d_highi, d_closei;
   int i_digits = Digits; // For a non-inverted chart.
   if (InvertChart)
   {
      // For an inverted chart:
      if (InvertedOutputDigits >= 0) i_digits = InvertedOutputDigits;
      else if (i_digits <= 1) i_digits = 8;
      else if (i_digits <= 3) i_digits = 6;
      else i_digits = 5;
         
      d_openi  = NormalizeDouble(InvertedOutputMultiplier/d_open,i_digits);
      d_highi   = NormalizeDouble(InvertedOutputMultiplier/d_low,i_digits); // NOTE, highi is from low, and vice-versa
      d_lowi  = NormalizeDouble(InvertedOutputMultiplier/d_high,i_digits);
      d_closei = NormalizeDouble(InvertedOutputMultiplier/d_close,i_digits);
   }
   
   if (FileHandle >= 0) 
   {
      if (InvertChart)
      {
         FileWriteInteger(FileHandle, i_time, LONG_VALUE);
         FileWriteDouble(FileHandle, d_openi, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_lowi, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_highi, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_closei, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_volume, DOUBLE_VALUE);
      }
      else
      {
         FileWriteInteger(FileHandle, i_time, LONG_VALUE);
         FileWriteDouble(FileHandle, d_open, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_low, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_high, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_close, DOUBLE_VALUE);
         FileWriteDouble(FileHandle, d_volume, DOUBLE_VALUE);
      }
   }
   if (CSVHandle >= 0) {
      if (InvertChart)
      {
         FileWrite(CSVHandle,
            TimeToStr(i_time, TIME_DATE),
            TimeToStr(i_time, TIME_MINUTES),
            DoubleToStr(d_openi, i_digits), 
            DoubleToStr(d_highi, i_digits), 
            DoubleToStr(d_lowi, i_digits), 
            DoubleToStr(d_closei, i_digits), 
            d_volume);
      }
      else
      {
         FileWrite(CSVHandle,
            TimeToStr(i_time, TIME_DATE),
            TimeToStr(i_time, TIME_MINUTES),
            DoubleToStr(d_open, i_digits), 
            DoubleToStr(d_high, i_digits), 
            DoubleToStr(d_low, i_digits), 
            DoubleToStr(d_close, i_digits), 
            d_volume);
      }
   }
} // end of WriteHistoryData

int UpdateHistoryFile(int start_pos, bool init = false)
{
   static int last_fpos, csv_fpos;
   int i, ps;
   int shift;
   
   int i_month, i_year;
   
//   if (FileHandle < 0) return (-1);
   // normalize open time
   ps = NewPeriod * 60;
   shift = 60 * TimeShiftAdd_in_Minutes;
   
   if (MathMod(NewPeriod,PERIOD_W1) == 0)
   {
      // Works for "W1", not sure about "W2" and higher.
      i_time = (Time[start_pos]+shift+345600)/ps;
      i_time =  i_time*ps - 345600;  //345600 = 4days in seconds, because 1/1/1970 was a thursday, so subtract 4 to always get Sunday start-of-week.
   }
   else if (MathMod(NewPeriod,518400) == 0) // 518400 = 12*PERIOD_MN1.   MUST GO BEFORE Monthly's below.
   {
      // Need to find in what year is the first data:
      i_time = (Time[start_pos]+shift)/ps;
      i_time *=  ps;
      i_year  = TimeYear(i_time);
      // FYI, shift *may* work...
      i_month  = -shift/(PERIOD_MN1*60); // "-shift" because a shift of "+1N" (1 month) uses the PREVIOUS month's data for what it labels this month.  "-1N" is opposite.
      if (i_month < 0) { i_month += 12; }
      i_month = MathMod(i_month,12)+1;
      if (i_month < 10) i_time = StrToTime(StringConcatenate(i_year,".0",i_month,".01"));
      else i_time = StrToTime(StringConcatenate(i_year,".",i_month,".01"));
      //Alert("DEBUG...  i_month: ",i_month," i_time: ",TimeToStr(i_time,TIME_DATE|TIME_MINUTES));
   }
   else if (MathMod(NewPeriod,PERIOD_MN1) == 0)
   {
      // Need to find in what month is the first data:
      // FYI, SHIFT DOES NOT WORK!  Plus, can't create a "MN2" chart in MT4 anyway, so this is not likely to work, and low priority to me.
      i_time = (Time[start_pos]+shift)/ps;
      i_time *=  ps;
      i_year  = TimeYear(i_time);
      //i_time = (Time[start_pos]+shift);
      i_month  = -shift/(PERIOD_MN1*60); // "-shift" because a shift of "+1N" (1 month) uses the PREVIOUS month's data for what it labels this month.  "-1N" is opposite.
      if (i_month < 0) { i_month += 12; }
      i_month = MathMod(i_month,12)+1;
      if (i_month < 10) i_time = StrToTime(StringConcatenate(i_year,".0",i_month,".01"));
      else i_time = StrToTime(StringConcatenate(i_year,".",i_month,".01"));
   }
   else 
   {
      i_time = (Time[start_pos]+shift)/ps;
      i_time *=  ps;
   }
   
   if (init) {
         //first time, init data
         d_open = Open[start_pos];
         d_low = Low[start_pos];
         d_high = High[start_pos]; 
         d_close = Close[start_pos];
         d_volume = Volume[start_pos];                           
         i = start_pos - 1;
         if (FileHandle >= 0) last_fpos = FileTell(FileHandle);
         if (CSVHandle >= 0) csv_fpos = FileTell(CSVHandle);
   } else {
         i = start_pos;
         if (FileHandle >= 0) FileSeek(FileHandle,last_fpos,SEEK_SET);
         if (CSVHandle >= 0) FileSeek(CSVHandle, csv_fpos, SEEK_SET);
   }
   if (i < 0) return (-1);

   int cnt = 0;
   int LastBarTime;
   //int dow;
   //static int last_dow = -1;
   
   //processing bars
   while (i >= 0) {
      //LastBarTime = Time[i]-shift;
      LastBarTime = Time[i]+shift;
      //dow = TimeDayOfWeek(LastBarTime);
      //int dow = TimeDayOfWeek(Time[i]);
      
      
      bool startNewBar = false;
      //Alert("DEBUG i_time: ",TimeToStr(i_time,TIME_DATE|TIME_MINUTES)," LastBarTime: ",TimeToStr(LastBarTime,TIME_DATE|TIME_MINUTES)," i_time+31708800: ",TimeToStr(i_time+31708800,TIME_DATE|TIME_MINUTES));
      
      if (MathMod(NewPeriod,518400) == 0)
      {
         i_month  = -shift/(PERIOD_MN1*60); // "-shift" because a shift of "+1N" (1 month) uses the PREVIOUS month's data for what it labels this month.  "-1N" is opposite.
         if (i_month < 0) { i_month += 12; }
         i_month = MathMod(i_month,12)+1;
         if (TimeMonth(Time[i]) == i_month) startNewBar = true; // Needs work. May not work for 2-year charts.  Seems OK for 1-year, and somewhat for 1yr&shifted.
      }
      //else if (MathMod(NewPeriod,PERIOD_MN1) == 0) // Doesn't work!
      //{
      //   i_month  = -shift/(PERIOD_MN1*60); // "-shift" because a shift of "+1N" (1 month) uses the PREVIOUS month's data for what it labels this month.  "-1N" is opposite.
      //   if (i_month < 0) { i_month += 12; }
      //   i_month = MathMod(i_month,12)+1;
      //   if (TimeDay(Time[i]) == 1) startNewBar = true;
      //}
      else if (LastBarTime >=  i_time+ps) startNewBar = true;
      
      //a new bar
      if (startNewBar) {
         //write the previous bar data
         WriteHistoryData();
         cnt++;
         if (MathMod(NewPeriod,PERIOD_W1) == 0)
         {
            i_time = (LastBarTime+345600)/ps;
            i_time =  i_time*ps - 345600;  //345600 = 4days in seconds, because 1/1/1970 was a thursday, so subtract 4 to always get Sunday start-of-week.
         }
         else if (MathMod(NewPeriod,518400) == 0) // 518400 = 12*PERIOD_MN1
         {
            // Need to find in what year is the first data:
            i_month  = -shift/(PERIOD_MN1*60); // "-shift" because a shift of "+1N" (1 month) uses the PREVIOUS month's data for what it labels this month.  "-1N" is opposite.
            if (i_month < 0) { i_month += 12; }
            i_month = MathMod(i_month,12)+1;
            i_year  = TimeYear(LastBarTime);
            if (i_month < 10) i_time = StrToTime(StringConcatenate(i_year,".0",i_month,".01"));
            else i_time = StrToTime(StringConcatenate(i_year,".",i_month,".01"));
         }
         //else if (MathMod(NewPeriod,PERIOD_MN1) == 0) // PERIOD_MN1  Doesn't work yet.
         //{
         //   // FYI, shift does not work AFAIK
         //   // Need to find in what year is the first data:
         //   i_month  = -shift/(PERIOD_MN1*60); // "-shift" because a shift of "+1N" (1 month) uses the PREVIOUS month's data for what it labels this month.  "-1N" is opposite.
         //   if (i_month < 0) { i_month += 12; }
         //   i_month = MathMod(i_month,12)+1;
         //   i_year  = TimeYear(LastBarTime);
         //   if (i_month < 10) i_time = StrToTime(StringConcatenate(i_year,".0",i_month,".01"));
         //   else i_time = StrToTime(StringConcatenate(i_year,".",i_month,".01"));
         //}
         else
         {
            i_time = LastBarTime/ps;
            i_time *= ps;
         }
         d_open = Open[i];
         d_low = Low[i];
         d_high = High[i];
         d_close = Close[i];
         d_volume = Volume[i];
      } else {
         //no new bar
         d_volume +=  Volume[i];
         if (Low[i]<d_low) d_low = Low[i];
         if (High[i]>d_high) d_high = High[i];
         d_close = Close[i];      
      }
      i--;
   }
   
   //record last_fpos before writing last bar.
   if (FileHandle >= 0) last_fpos = FileTell(FileHandle);
   if (CSVHandle >= 0) csv_fpos = FileTell(CSVHandle);
   
   WriteHistoryData();
   cnt++;
   d_volume -=  Volume[0];
   
   //flush the data writen
   if (FileHandle >= 0) FileFlush(FileHandle);
   if (CSVHandle >= 0) FileFlush(CSVHandle);
   return (cnt);
} // end of UpdateHistoryFile

int UpdateChartWindow()
{
   static int hwnd = 0;

   if (FileHandle < 0) {
      //no HST file opened, no need updating.
      return (-1);
   }
   if(hwnd == 0) {
      //trying to detect the chart window for updating
      hwnd = WindowHandle(symboloutput, NewPeriodDisplayed);
   }
   if(hwnd!= 0) {
      if (IsDllsAllowed() == false) {
         //DLL calls must be allowed
         DebugMsg("DLL calls must be allowed");
         return (-1);
      }
      if (PostMessageA(hwnd,WM_COMMAND,CHART_CMD_UPDATE_DATA,1) == 0) {
         //PostMessage failed, chart window closed
         hwnd = 0;
      } else {
         //PostMessage succeed
         return (0);
      }
   }
   //window not found or PostMessage failed
   return (-1);
} //end of UpdateChartWindow


void UpdateMultipleChartWindows()
{
  // This routine by pips4life is an offshoot of an incomplete (but useful)
  // suggestion by rangebound (of ForexFactory) how to solve
  // the problem that WindowHandle() only returns the first window it finds.
  
  int hwnd,len;
  
  if (FileHandle < 0) {
      //no HST file opened, no need updating.
      return (-1);
   }
  
  // GetWindowTextA overwrites gwstr but it should initially be at least as long as it will become.
  //     //12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789  //119 chars
  gwstr = "                                                                                                                       ";
  
  hwnd = WindowHandle(symboloutput,NewPeriodDisplayed); //This is non-zero if at least one matching window exists
  if (hwnd != 0)
  {
    if (Debug) Print("Initial WindowHandle: ",hwnd);
    //if (Debug) Print("Initial gwstr:",gwstr,":");
    //len = GetWindowTextA(hwnd,gwstr,80); //Unfortunately, len is always 0, gwstr doesn't get text
    //if (Debug) Print("First gwstr:",gwstr,":"); //This is often zero-chars even though it was just set to spaces above!
    //offlineChartName = StringSubstr(gwstr,0,len-1);
    
    //hwnd = GetWindow(hwnd,GW_HWNDFIRST); //Always same as WindowHandle
    //if (Debug) Print("Initial GetWindow: ",hwnd," len: ",len," offlineChartName: ",offlineChartName);
    //if (Debug) Print("   Owner window: ",GetWindow(hwnd,GW_OWNER)); //Always 0
    //if (Debug) Print("   Child window: ",GetWindow(hwnd,GW_CHILD)); //Always 0
    //if (Debug) Print("   First window: ",GetWindow(hwnd,GW_HWNDFIRST));
    //if (Debug) Print("   Last  window: ",GetWindow(hwnd,GW_HWNDLAST)); //same as FIRST
    //if (Debug) Print("   Next  window: ",GetWindow(hwnd,GW_HWNDNEXT)); //Always 0
    //if (Debug) Print("   Prev  window: ",GetWindow(hwnd,GW_HWNDPREV)); //Always 0
    //if (Debug) Print("   GetParent window: ",GetParent(hwnd));
    //if (Debug) Print("   GetAncestor-Parent window: ",GetAncestor(hwnd,GA_PARENT));
    
    hwnd=GetParent(hwnd);
    if (Debug) Print("Initial window using GetParent: ",hwnd);
    hwnd = GetWindow(hwnd,GW_HWNDFIRST); //Not sure if this is redundant or not. Doesn't hurt and it may be necessary.
    while (hwnd !=0)
    {
      len = GetWindowTextA(hwnd,gwstr,80);
      if ((len >0) && gwstr == offlineChartName)
      {
         PostMessageA(hwnd,WM_COMMAND,CHART_CMD_UPDATE_DATA,1);
         if (Debug) Print("Found and updated this GetWindow: ",hwnd," gwstr: ",gwstr);
      }
      
      hwnd = GetWindow(hwnd,GW_HWNDNEXT);
    }
  }
} // end of UpdateMultipleChartWindows


static int LastStartTime = 0;
static int LastEndTime = 0;
static int LastBarCount = 0;

int reinit()
{
   deinit();
   init();
   LastStartTime = Time[Bars-1];
   LastEndTime = Time[0];
   LastBarCount = Bars;
} // end of reinit

bool IsDataChanged()
{
/*
   static int LastBars = 0, LastTime = 0, LastVolume = 0;
   static double LastOpen = 0, LastClose = 0, LastHigh = 0, LastLow = 0;
   
   if (LastVolume != Volume[0] || LastBars != Bars || LastTime != Time[0]|| 
      LastClose != Close[0] || LastHigh != High[0] || LastLow != Low[0] || 
      LastOpen != Open[0]) {

      LastBars = Bars;
      LastVolume = Volume[0];
      LastTime = Time[0];
      LastClose = Close[0];
      LastHigh = High[0];
      LastLow = Low[0];
      LastOpen = Open[0];
      return (true);
   }
   return (false);
*/
/*
   fast version without float point operation
*/
   static int LastBars = 0, LastTime = 0, LastVolume = 0;
   bool ret;
   
   ret = false;
   if (LastVolume != Volume[0]) {
      LastVolume = Volume[0];
      ret = true;
   }
   if (LastTime != Time[0]) {
      LastTime = Time[0];
      ret = true;
   }
   if (LastBars != Bars) {
      LastBars = Bars;
      ret = true;
   }
   return (ret);
} // end of IsDataChanged

int CheckNewData()
{
   static string LastServer = "";
   
   if (Bars < 2) {
      //the data is not loaded yet.
      DebugMsg("Data not loaded, only " +  Bars + " Bars");
      return (-1);
   }

   string serv = ServerAddress();
   if (serv == "") {
      //no server yet
      DebugMsg("No server connected");
      return (-1);
   }

   //server changed? check this and reinit to prevent wrong data while changing server.
   if (LastServer != serv) {
      DebugMsg("Server changed from " + LastServer + " to " + serv);
      LastServer = serv;
      reinit();
      return (-1);
   }

   if (!IsDataChanged()) {
      //return if no data changed to save resource
      //DebugMsg("No data changed");
      return (-1);
   }

   if (Time[Bars-1] != LastStartTime) {
      DebugMsg("Start time changed, new history loaded or server changed");
      reinit();
      return (-1);
   }
      
   int i, cnt;
   
   //try to find LastEndTime bar, which should be Time[0] or Time[1] usually,
   //so the operation is fast
   for (i = 0; i < Bars; i++) {
      if (Time[i] <= LastEndTime) {
         break;
      }
   }
   
   if (i >= Bars || Time[i] != LastEndTime) {
      DebugMsg("End time " + TimeToStr(LastEndTime) + " not found");
      reinit();
      return (-1);
   }
   
   cnt = Bars - i;
   if (cnt != LastBarCount) {
      DebugMsg("Data loaded, cnt is " + cnt + " LastBarCount is " + LastBarCount);
      reinit();
      return (-1);
   }

   //no new data loaded, return with LastEndTime position.
   LastBarCount = Bars;
   LastEndTime = Time[0];
   return (i);
} // end of CheckNewData

//+------------------------------------------------------------------+
string shortenSymbol(string symbolname)
{
  symbolname = stringReplaceFirstMatch(symbolname,"CHF","CF");
  symbolname = stringReplaceFirstMatch(symbolname,"CAD","CD");
  symbolname = stringReplaceFirstMatch(symbolname,"USD","U");
  symbolname = stringReplaceFirstMatch(symbolname,"EUR","E");
  symbolname = stringReplaceFirstMatch(symbolname,"GBP","G");
  symbolname = stringReplaceFirstMatch(symbolname,"JPY","J");
  symbolname = stringReplaceFirstMatch(symbolname,"AUD","A");
  symbolname = stringReplaceFirstMatch(symbolname,"NZD","NZ");
  // Not planning to convert these less common names... the more one converts, the longer the un-convert routine.
  //symbolname = stringReplaceFirstMatch(symbolname,"NOK","NK");
  //symbolname = stringReplaceFirstMatch(symbolname,"SEK","SK");
  //symbolname = stringReplaceFirstMatch(symbolname,"DKK","DK");
  //symbolname = stringReplaceFirstMatch(symbolname,"HKD","HK");
  //symbolname = stringReplaceFirstMatch(symbolname,"SEKRUB","SKRU"); // Note, one could change pairs of names instead of just base-currency names.
  
  //Note: Changing these names back will likely require all possible pairs be specified, EU->EURUSD, NOT just E->EUR & U->USD
  // More specifically for "EU" in particular, any unconvert must be careful not to change "EURUSD"->"EURUSDRUSD" (wrong). Use:  
  //    if (StringFind(symbolname,"EU,0) == 0 && StringFind(symbolname,"EUR",0) != 0) symbolname=stringReplaceFirstMatch(symbolname,"EU","EURUSD")
  
  return(symbolname);
} // end of shortenSymbol

//+------------------------------------------------------------------+
string stringReplaceFirstMatch(string str, string toFind, string toReplace) 
{
    int len = StringLen(toFind);
    int pos = StringFind(str, toFind);
    if (pos == -1) {
        return (str);
    } else if (pos == 0) {
        return (StringConcatenate(toReplace,StringSubstr(str, pos + len)));
    }
    return (StringConcatenate(StringSubstr(str, 0, pos),toReplace,StringSubstr(str, pos + len)));
} // end of stringReplaceFirstMatch
//+------------------------------------------------------------------+
string PeriodToString(int tf, bool longName)
{
   string tfs;
   if      (longName && tf == PERIOD_MN1) tfs="Monthly";
   else if (MathMod(tf,PERIOD_MN1) == 0)  tfs=StringConcatenate("MN",tf/PERIOD_MN1);
   else if (longName && tf == PERIOD_W1)  tfs="Weekly";
   else if (MathMod(tf,PERIOD_W1 ) == 0)  tfs=StringConcatenate("W",tf/PERIOD_W1);
   else if (longName && tf == PERIOD_D1)  tfs="Daily";
   else if (MathMod(tf,PERIOD_D1 ) == 0)  tfs=StringConcatenate("D",tf/PERIOD_D1);
   else if (MathMod(tf,PERIOD_H1 ) == 0)  tfs=StringConcatenate("H",tf/PERIOD_H1);
   else tfs=StringConcatenate("M",tf);
   //if (tf == Period()) tfs = "Current time frame";
   return(tfs);
}
//+------------------------------------------------------------------+
void DebugMsg(string msg)
{
   if (Debug) Alert(msg);
}
//+------------------------------------------------------------------+

