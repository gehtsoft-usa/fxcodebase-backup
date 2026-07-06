// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72029

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
 

/*------------------------------------------------------------------------------------
Introduction:


   Time-Zone Inputs:

   LocalTimeZone: TimeZone for which MT4 shows your local time,
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight
                  savings time).  Use zero for no adjustment.
                  The MetaQuotes demo server uses GMT +2.

   DestTimeZone:  TimeZone for the session from which to calculate
                  the levels (e.g. 1 or 2 for the European session
                  (without or with daylight savings time).
                  Use zero for GMT

   Example: If your MT server is living in the EST (Eastern Standard Time,
            GMT-5) zone and want to calculate the levels for the London trading
            session (European time in summer GMT+1), then enter -5 for
            LocalTimeZone, 1 for Dest TimeZone.

            Please understand that the LocalTimeZone setting depends on the
            time on your MetaTrader charts (for example the demo server
            from MetaQuotes always lives in CDT (+2) or CET (+1), no matter
            what the clock on your wall says. If in doubt, leave everything to zero.
---------------------------------------------------------------------------------------

SDK-Pivots-v1.2:

This version is the combination and culmination of all stages of revision/upgrade
subsequent to the original SDX-TzPivots released by Shimodax, plus modifications
to align the expanded Floor Pivot and Camarilla calculations to those described by
Frank Ochoa in his book "Secrets of a Pivot Boss". It also includes a very significant
new feature - the indicator now shows the central pivot range going back the number
of days specified for the the user. These multi day pivot relationships (in particular)
the most recent two days - when combined with the opening price give you a view of
the market type today. For more information see Frabk Ochoa's book.

In the original, you could display both Daily pivots and Fib pivots, but the Fibs
were not per standard formula. You could display mid-pivots, Yesterday H/L, todays
Open, Camarilla and SweetSpots.  Line style and colors were hard coded, meaning if
you wanted to change line styles here and there, or colors, you had to change them
in the code and re-complile the indicator.  In this area, a lot has been added.
Of all the original functions intended, only SweetSpots is eliminated, as Shimodax
has created a separate and better SDX-SweetSpots indicator.

This _v1.2 upgrade provides for full customization of all lines and labels....color,
style, thickness, font style, font size.  Period Separator lines can be displayed,
or not.  Their display can be at the top or bottom of the screen, eliminating some
congestion.  Their labels can be displayed, or not.  Additional cosmetic changes
include label changes, and better label positioning and justification to improve
the overall look.

Additional comments regarding some of the many Indicator Window inputs:

Local_HrsServerTzFromGMT:
     Enter the number of hours difference between GMT and the time zone your
     platform server is in.  MT4 demo servers are GMT +2 hrs.  Use default value
     "0" for normal, non-time shifted pivot calculations.

Dest_HrsNewTZfromGMT:
     Enter the number of hours difference between GMT and the new time zone you
     are selecting as the basis for pivots calculations.  For example, if
     you wish to have the day start at NY time, then enter "-5".  If you wish to
     have the day start at Zurich time, then enter "1".  Use the default value of
     "0" for normal, non-time shifted pivot calculations.

Show_1Daily_2FibonacciPivots:
     Either formula can be used to produce the main pivot line

FullScreenLinesMarginPrices:
     "true" displays lines across entire screen with prices in the right margin.
     "false" displays lines starting at the "Today" Period Separator and which
     do not have margin labels.  For these lines, you will want to add labels.

MoveLabels_LR_DecrIncr:
     Increasing the number moves the line labels to the right on the chart.
     Decreasing the number moves the line labels to the left on the chart.
     This feature is absent in the original indicator.  It is for the
     "FullLinesMarginPrices = true" mode, to relocate line ID labels.  It
     also is used in the "FullLinesMarginPrices = false" mode once the
     Relabeler code takes over and is producing full screen lines.

Color Choices for lines and labels:
     Enter the colors of your choice.

LineStyle_01234:
     Your number entry selects the line style for the lines.  0=solid, 1=dash,
     2=dashdot, 3=dashdot, and 4=dashdotdot.

SolidLineThickness:
     Your number entry selects the width of solid lines.  0 and 1 = single width.
     2, 3, 4 graduate the thickness.  Coding assures that no matter what number
     this is set at, non-solid line styles selected will still display without
     having to change this entry back to 0, or 1.

_Label_Norm_Bold_Black_123:
     Entry of "1" produces Arial.  Entry of "2" produces Arial Bold.  And an
     entry of "3" produces Arial Black font style.

ShowPeriodSeparatorLines:
     The choice of "true" will place a pair of vertical lines on the chart showing
     the start and stop of the new "Destination" 24 hour period you have selected
     for pivot calculations.  Choosing "false" cancels display of these lines and
     their "Yesterday" and "Today" labels.

PlaceAt_TopBot_12_OfChart:
     "1" will place the Period Separator labels "Yesterday" and "Today" at the
     top of the screen.  "2" will place them at the bottom.  The charts are less
     congested.  If the screen is enlarged, downsized, or scrolled, these labels
     will move.  But the next data tick restores their position.

LineLabelsIncludePrice:
     Line labels have IDs such as R#, PV, or S#, but selecting "true" will add the
     price anytime you have these labels on the chart.

Relabeler_Adjustment:
     This number is used in the FullScreenLinesMarginPrices = "false"  mode to
     trigger when the relabeler puts labels on the screen. It works under the
     assumption that the Today Period Separator is soon to go off-screen, taking
     the labels with it.  The ideal number would trigger the relabeler when the
     first labels are about to move off the left of the chart.  Lowering the
     number triggers sooner and raising it delays triggering.  The number is
     the number of candles between the Today Separator and the chart left border.
     For example, a value of "10" will trigger the relabeler when the Today Period
     Separator is 10 candles from the chart left border.  A value of "0" triggers
     when the Today Period Separator hits the left border.  This feature allows
     for fine tuning charts of different scales and timeframes.  In most cases
     either of the example values is sufficient.  If the chart timeframe and
     scale is such that full sessions are displayed without the Today Separator
     ever disappearing, then relabeling and this adjustment to it, will not be
     required.  It only comes into play when the scale is such that the Today
     Period Separator will move off the left of the screen, taking the labels
     with it, before the next session Separators can come on-screen.  Scaling
     down to make larger candles causes more timeframes to require this feature,
     The coding takes this into account and use of this adjustment is really
     only for fine tuning whenever the user desires to do so.

Show_Relabeler_Comment:
     If "true" then Relabeler related data appears in chart upper left. It
     serves to help a new user better understand the Relabeler.

Show_Data_Comment:
     If "true" then key prior/current day pip data appears in chart upper left.

                                                - Traderathome, December 20, 2008
----------------------------------------------------------------------------------
v4.2: Modified code controlling mid-screen placement of line labels when full
screen lines are shown.  Now mid-screen label placement is automatic when zooming
in and out on the charts.
                                                - Traderathome, February 1, 2009
----------------------------------------------------------------------------------
v4.3: Modified code for Period Separator labels so that instead of just showing
"Yesterday" and "Today", these are now replaced with the actual name of the Day
and include the time zone shift from GMT selected by the user.  When the original
selection for full screen lines is "false", after time on small timeframe charts,
like M1 and M5, lines become full screen by necessity.  However, when a new day
starts, the old lines are cleared and the new lines are again not full screen.

                                                - Traderathome, March 14, 2009
---------------------------------------------------------------------------------
v4.4: For simpicity, grouped the main support lines and the main resistance lines,
so far as the selection of color, style and width.

v4.7: Added "ZoomAdjust" window input.... bit difficult to explain, but I'll try.
For the line labels displayed to the left of the current Period Separator, keeping
neat spacing from the Separator line is difficult in that some things "upset the
apple cart".  Adding prices to the labels can necessitate label shifting.  Zooming
the chart in or out can necessitate label shifting.  Even increasing or decreasing
the font size, or changing the font style can necessitate label shifting.  And
this group of labels needs to be shifted independent from the rest of the labels.
The "ZoomAdjust" allows the user to input a number to move those labels to a
neater location relative to the Separator, once the chart zoom has been made, and
the selection of whether or not prices are included has been made, and the choices
of font size and style have been made.  The "ZoomAdjust_3_6_15_30_50" numbers are
there to suggest the range that may be necessary.  If prices are included, and if
a large font and the "3" style are selected, you may need to input a large number
to move the labels far enough away from the Separator to keep the labels from
overlapping it.  An even larger number may be required if the chart is then zoomed
out even more.  You will have to experiment with it to get the hang of it.  You can
simply ignore it, too, and just not use it.  But, if you set up a chart that will
be around a while, and you want things nice on it, this is a useful addition.

                                                - Traderathome, March 27, 2009
----------------------------------------------------------------------------------
v4.7.1: Corrects previous failure to deinitialize when "turned off".
                                                - Traderathome, April 05, 2009
----------------------------------------------------------------------------------
v4.7.2: Altered code so all items displayed except for the Period Separators and
Separator Labels go into the background relative to other charting items.  This
prevents the annoying breakup of other chart study lines.
                                                - Traderathome, April 11, 2009
--------------------------------------------------------------------------------
v1.0-SDK: Reworked the floor pivot and Camarilla pivot calculations to align
with the expanded formulas described by Frank Ochoa in his book "Secrets of a Pivot
Boss". Removed the quarter pivots option, and added a switch to show or not show
the inner Camarillas (S1,S2, R1,R2) which are relevant only during tight ranges.
Added the Top and Bottom of the Central Pivot Range (tc, bc) which are used to
show pivot range width and describe two day pivot relationships.
                                                        - f451, October 6, 2011

v1.2-SDK: Extended calculation and display of the pivot and central pivot range
going back a number of days as specified by the user. 2 days is the minimum required
to see the 2-day pivot relationship.
                                                        - f451, October 10, 2011
--------------------------------------------------------------------------------*/

#property indicator_chart_window
input ENUM_TIMEFRAMES pivotPointTimeFrame=PERIOD_D1;//Time Frame Period For Pivot Point Formula
input bool hideLabels=false;//Toggle Hide all the labels of the pivot points-CPR

bool   Indicator_On                  = true;
input int    Local_HrsServerTzFromGMT       = 0;    //Data collection Tz of your server
input int    Dest_HrsNewTZfromGMT           = 0;    //New destination Tz governing data
int    Show_1Daily_2FibonacciPivots   = 1;
bool   FullScreenLines                = false;
extern bool   withMarginPrices               = true;
extern bool   LineLabelsIncludePrice         = true;
extern int    MoveLabels_LR_DecrIncr         = 0;    //-# to move left, +# to move right
extern int    PercentageOffset               = 25;   //-# to move left, +# to move right
extern color  PivotLinesLabelColor           = Gray;
int    LineLabelsFontSize             = 8;
int    L_Label_Norm_Bold_Black_123    = 2;
int    ZoomAdjust_3_6_15_30_50        = 20;    //for 8,9 fontsize: 2, 5, 10, 20, 40
extern color  R_Color                        = Salmon;
extern int    R_LineStyle_01234              = 0;
extern int    R_SolidLineThickness           = 1;
extern color  CentralPivotColor              = PowderBlue;
extern int    CentralPivotLineStyle_01234    = 0;
extern int    CentralPivotSolidLineThickness = 1;
extern color  C_Color                        = Yellow;
extern int    C_LineStyle_01234              = 0;
extern int    C_SolidLineThickness           = 2;
extern bool   ShowTwoDayPivots               = true;
extern color  S_Color                        = PaleGreen;
extern int    S_LineStyle_01234              = 0;
extern int    S_SolidLineThickness           = 1;
extern color  MidPivotsColor                 = Gray;
extern int    MidPivotsLineStyle_01234       = 0;
extern int    MidPivotsLineThickness         = 1;
extern bool   ShowMidPivots                  = false;
color  YesterdayHighLowColor          = BurlyWood;
int    HighLowLineStyle_01234         = 3;
int    HighLowSolidLineThickness      = 1;
bool   ShowYesterdayHighLow           = false;
color  TodayOpenColor                 = Gainsboro;
int    TodayOpenLineStyle_01234       = 2;
int    TodayOpenSolidLineThickness    = 1;
bool   ShowTodayOpen                  = false;
color  CamarillaHiColor               = LightSkyBlue;
color  CamarillaLoColor               = IndianRed;
int    CamarillaLineStyle_01234       = 0;
int    CamarillaSolidLineThickness    = 1;
bool   ShowCamarilla                  = false;
bool   ShowInnerCamarillas            = false;
color  PeriodSeparatorLinesColor      = RosyBrown;
int    SeparatorLinesStyle_01234      = 2;
int    SeparatorLinesThickness        = 1;
bool   ShowPeriodSeparatorLines       = false;
color  PeriodSeparatorsLabelsColor    = DarkGray;
int    PlaceAt_TopBot_12_OfChart      = 2;
int    SeparatorLabelFontSize         = 8;
int    S_Label_Norm_Bold_Black_123    = 2;
bool   ShowPeriodSeparatorLabels      = false;
int    Relabeler_Adjustment           = 8;       //-# to advance trigger, +# to delay trigger
bool   Show_Relabeler_Comment         = false;
bool   Show_Data_Comment              = false;
extern int    Days                           = 5;       // number of Days back to calculate pivots and central pivot range.

int MoveLabels, MoveLabels2;
int A,B; //relabeler triggers
int digits; //decimal digits for symbol's price
int offset;
double pts;

string ObjPivot = "[PIVOT]";
string ObjCamarilla = "[CAMARILLA]";
string ObjSeparator = "[TIME]";

string dayString[];
int idxfirstbar[];
int idxlastbar[];
double day_open[];
double day_close[];
double day_high[];
double day_low[];
double p[];
double bc[];
double tc[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   pts = MarketInfo(Symbol(), MODE_POINT);
   if(Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1))
     { pts = Point*10; }
   else
      if(Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1))
        { pts = Point*100; }
      else
        { pts = Point; }

   if(Ask>10)
      digits=2;
   else
      digits=4;
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
int deinit()
  {
   int obj_total= ObjectsTotal();
   for(int i= obj_total; i>=0; i--)
     {
      string name= ObjectName(i);
      if((StringSubstr(name,0,7)==ObjPivot) || (StringSubstr(name,0,11)==ObjCamarilla) || (StringSubstr(name,0,6)==ObjSeparator))
         ObjectDelete(name);
     }
   Comment(" ");
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(Indicator_On == false)
     {
      deinit();
      return(0);
     }


   MoveLabels = (WindowFirstVisibleBar()/2)- MoveLabels_LR_DecrIncr;
   MoveLabels2=  MoveLabels+ZoomAdjust_3_6_15_30_50;

   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;

   datetime startofday= 0,
            startline= 0,
            endline=0,
            startlabel= 0;

   ArrayResize(dayString,Days+1);
   ArrayResize(day_open,Days+1);
   ArrayResize(day_close,Days+1);
   ArrayResize(day_high,Days+1);
   ArrayResize(day_low,Days+1);
   ArrayResize(p,Days+1);
   ArrayResize(bc,Days+1);
   ArrayResize(tc,Days+1);
   ArrayResize(idxfirstbar,Days+1);
   ArrayResize(idxlastbar,Days+1);

   lasttimeframe= Period();
   timelastupdate= CurTime();

//-----let's find out which bars mark the beginning and end going back the user specified days -----
   ComputeDayIndices(Local_HrsServerTzFromGMT, Dest_HrsNewTZfromGMT, Days);
   GetOHLC(idxfirstbar,idxlastbar, day_open, day_high, day_low, day_close,pivotPointTimeFrame);

// set label offset
   int PC = idxfirstbar[1]-idxlastbar[1]; //# of bars btwn day separators - use as offset
   offset = MathRound((PercentageOffset/100) * PC);

//----relabeler code--------------------------------------------------------------------------------------
   A=0;
   B=0; //reset:  relabeler off, margin labels off
   if(FullScreenLines == true && withMarginPrices == true)
     {
      B = 1;  //B=1 asserts margin labels
     }
   if(FullScreenLines == true && withMarginPrices == false)
     {
      B = 0;  //B=0 prevents margin labels
     }
   if(FullScreenLines == false)
     {
      int AA = WindowFirstVisibleBar();  //# of visible bars on chart
      int BB = ((Time[0]-Time[idxfirstbar[0]])/(Period()*60));  //# of bars btwn current time and first day separator
      int RR = (AA - BB); //# number of bars btwn first day Separator and chart left margin
      int AL = Relabeler_Adjustment; //default of zero activates relabeler as first day separator goes off-screen
      if(RR >  AL)
        {
         A = 0;  //labels not near enough to chart left margin to trigger relabeler
        }
      if(RR <= AL)
        {
         A = 1;   //labels close enough - switch to full-screen
         if(withMarginPrices == true)
            B = 1;
        }
     }

//----Autolabeler test comment
   string test = "A = "+A+",  ";
   test = test + "Current time to Separator = "+BB+" candles.";
   test = test + "   Separator to Chart left = "+RR+" candles.";
   test = test + "   Total candles visable = "+AA+" candles.";
   test = test + "   Relabeler is set to trigger when Separator is  "+AL+"  candles from chart left. \n";
   test = test + "   Number of candles between days = " + PC;
   if(Show_Relabeler_Comment ==true)
     {
      Comment(test);
     }
   else
     {
      Comment(" ");
     }

//----clear all objects before redrawing screen
   int obj_total= ObjectsTotal();
   for(int x= obj_total; x>=0; x--)
     {
      string name= ObjectName(x);
      if((StringSubstr(name,0,7)==ObjPivot) || (StringSubstr(name,0,11)==ObjCamarilla) || (StringSubstr(name,0,6)==ObjSeparator))
         ObjectDelete(name);
     }

//------draw the vertical bars/labels that mark the session spans------------------------------------------
   if(ShowPeriodSeparatorLines == true)
     {
      int DZ = Dest_HrsNewTZfromGMT;
      string GMT = "(GMT +0)  ";
      if(DZ>0 &&  DZ<10)
        {
         GMT = "(GMT +"+ Dest_HrsNewTZfromGMT +")  ";
        }
      if(DZ>9)
        {
         GMT = "(GMT +"+ Dest_HrsNewTZfromGMT +")";
        }
      if(DZ<0 &&  DZ>-10)
        {
         GMT = "(GMT +"+ Dest_HrsNewTZfromGMT +")  ";
        }
      if(DZ<-9)
         GMT = "(GMT "+ Dest_HrsNewTZfromGMT +")";
      if(SeparatorLinesStyle_01234>0)
        {
         SeparatorLinesThickness=1;
        }
      double top = WindowPriceMax();
      double bottom = WindowPriceMin();
      double scale = top - bottom;
      double YadjustTop = scale/5000; //250;
      double YadjustBot = scale/(350/SeparatorLabelFontSize);
      double level = top - YadjustTop;
      if(PlaceAt_TopBot_12_OfChart==2)
        {
         level = bottom + YadjustBot;
        }
      for(int dy = 0; dy < Days; dy++)
        {
         SetTimeLine("Day "+DoubleToStr(dy,0), dayString[dy] + GMT, idxfirstbar[dy]+0,  PeriodSeparatorsLabelsColor, level);
        }
     }

//---- Calculate Pivot Levels -------------------------------------------------------------------------------
// TODO: generalise all pivot calcs at some point
   double q, d, r1,r2,r3,r4,r5, s1,s2,s3,s4,s5;

   d     = (day_high[0] - day_low[0]);
   q     = (day_high[1] - day_low[1]); // RANGE

// calculate pivots going back as many days as specified
   for(int idx = 1; idx <= Days; idx++)
     {
      p[idx]  = (day_high[idx] + day_low[idx] + day_close[idx]) / 3;
      bc[idx] = (day_high[idx] + day_low[idx])/2;
      tc[idx]  = 2*p[idx] - bc[idx];

      if(bc[idx] > tc[idx])
        {
         double temp = bc[idx];
         bc[idx] = tc[idx];
         tc[idx] = temp;

        }
     }

   if(Show_1Daily_2FibonacciPivots == 1)
     {
      r1 = (2*p[1])-day_low[1];
      r2 = p[1]+(day_high[1] - day_low[1]);       //r2 = p-s1+r1;
      r3 = (2*p[1])+(day_high[1]-(2*day_low[1])); // r3 = r1 + (day_high[1] - yersterday_low);
      r4 = r3 + (r2 - r1);
      s1 = (2*p[1])-day_high[1];
      s2 = p[1]-(day_high[1] - day_low[1]);                 //s2 = p-r1+s1;
      s3 = (2*p[1])-day_high[1] - (day_high[1]-day_low[1]); // s3 = s1 - (day_high[1] - day_low[1]);
      s4 = s3 - (s1-s2);
     }
   if(Show_1Daily_2FibonacciPivots == 2)
     {
      r1 = p[1] + (q * 0.382);
      r2 = p[1] + (q * 0.618);
      r3 = p[1] +  q;
      r4 = p[1] + (q * 1.618);
      r5 = p[1] + (q * 2.618);
      s2 = p[1] - (q * 0.618);
      s1 = p[1] - (q * 0.382);
      s3 = p[1] -  q;
      s4 = p[1] - (q * 1.618);
      s5 = p[1] - (q * 2.618);
     }
   if(FullScreenLines==false&&A==0) //lines start at separators, no margin labels in this mode
     {
      startlabel= iTime(NULL,pivotPointTimeFrame,0)+offset;
      startline = iTime(NULL,pivotPointTimeFrame,0);  //was "+1", "+0" stops line at Separator
      /*
       startlabel= Time[idxfirstbar[0]+offset];
       startline = Time[idxfirstbar[0]+1];  //was "+1", "+0" stops line at Separator
       */
      if(Time[0] > Time[idxfirstbar[0]])
        {
         startline = iTime(NULL,pivotPointTimeFrame,0);
        }
     }
   if(FullScreenLines==false&&A==1) //lines started at separators, but switched to full screen, value of B governs margin labels
     {
      startlabel= Time[MoveLabels]+offset;
      startline = WindowFirstVisibleBar();
     }
   if(FullScreenLines==true) //lines selected to be full screen, margin labels governed by value of B in relabeler code
     {
      startlabel=Time[MoveLabels]+offset;
      startline = WindowFirstVisibleBar();
     }
   if(R_LineStyle_01234>0)
     {
      R_SolidLineThickness=0;
     }
   if(S_LineStyle_01234>0)
     {
      S_SolidLineThickness=0;
     }
   if(C_LineStyle_01234>0)
     {
      S_SolidLineThickness=0;
     }
   SetLevel(" R5 ", r5, R_Color, R_LineStyle_01234, R_SolidLineThickness, startline, startlabel, B);
   SetLevel(" R4 ", r4, R_Color, R_LineStyle_01234, R_SolidLineThickness, startline, startlabel, B);
   SetLevel(" R3 ", r3, R_Color, R_LineStyle_01234, R_SolidLineThickness, startline, startlabel, B);
   SetLevel(" R2 ", r2, R_Color, R_LineStyle_01234, R_SolidLineThickness, startline, startlabel, B);
   SetLevel(" R1 ", r1, R_Color, R_LineStyle_01234, R_SolidLineThickness, startline, startlabel, B);
   SetLevel(" BC ", bc[1], C_Color, C_LineStyle_01234, C_SolidLineThickness, startline, startlabel, B);
   SetLevel(" TC ", tc[1], C_Color, C_LineStyle_01234, C_SolidLineThickness, startline, startlabel, B);

   if(Show_1Daily_2FibonacciPivots == 1)
     {
      SetLevel(" PV ", p[1], CentralPivotColor, CentralPivotLineStyle_01234, CentralPivotSolidLineThickness, startline, startlabel, B);
     }
   if(Show_1Daily_2FibonacciPivots == 2)
     {
      SetLevel(" FPV ", p[1], CentralPivotColor, CentralPivotLineStyle_01234, CentralPivotSolidLineThickness, startline, startlabel, B);
     }
   SetLevel(" S1 ", s1, S_Color, S_LineStyle_01234, S_SolidLineThickness, startline, startlabel, B);
   SetLevel(" S2 ", s2, S_Color, S_LineStyle_01234, S_SolidLineThickness, startline, startlabel, B);
   SetLevel(" S3 ", s3, S_Color, S_LineStyle_01234, S_SolidLineThickness, startline, startlabel, B);
   SetLevel(" S4 ", s4, S_Color, S_LineStyle_01234, S_SolidLineThickness, startline, startlabel, B);
   SetLevel(" S5 ", s5, S_Color, S_LineStyle_01234, S_SolidLineThickness, startline, startlabel, B);

//----- Camarilla Lines
   if(ShowCamarilla==true)
     {
      if(CamarillaLineStyle_01234>0)
        {
         CamarillaSolidLineThickness=0;
        }
      double cr5, cr4, cr3, cr2, cr1, cs1, cs2, cs3, cs4, cs5; // Expanded Camarilla Equation values based on Frank Ochoa
      cr5 = (day_high[1]/day_low[1])*day_close[1];
      cr4 = (q*0.55)+day_close[1];
      cr3 = (q*0.275)+day_close[1];
      cr2 = (q*0.1833)+day_close[1];
      cr1 = (q*0.09167)+day_close[1];
      cs1 = day_close[1]-(q*0.09167);
      cs2 = day_close[1]-(q*0.1833);
      cs3 = day_close[1]-(q*0.275);
      cs4 = day_close[1]-(q*0.55);
      cs5 = day_close[1]-(cr5-day_close[1]);
      if(ShowInnerCamarillas)
        {
         SetLevel(" R1 ", cr1, CamarillaLoColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
         SetLevel(" R2 ", cr2, CamarillaLoColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
         SetLevel(" S1 ", cs1, CamarillaHiColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
         SetLevel(" S2 ", cs2, CamarillaHiColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
        }
      SetLevel(" R3 ", cr3, CamarillaLoColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
      SetLevel(" R4 ", cr4, CamarillaLoColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
      SetLevel(" R5 ", cr5, CamarillaLoColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
      SetLevel(" S3 ", cs3, CamarillaHiColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
      SetLevel(" S4 ", cs4, CamarillaHiColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
      SetLevel(" S5 ", cs5, CamarillaHiColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B, 0, 1);
     }

//------ Midpoints Pivots (mid-levels between pivots)
   if(ShowMidPivots==true)
     {
      if(FullScreenLines==false&&A==0)
        {


         startlabel= iTime(NULL,pivotPointTimeFrame,0)+offset;
         startline = iTime(NULL,pivotPointTimeFrame,0);  //was "+1", "+0" stops line at Separator
         /*
          startlabel= Time[idxfirstbar[0]+offset];
          startline = Time[idxfirstbar[0]+1];  //was "+1", "+0" stops line at Separator
          */
         if(Time[0] > Time[idxfirstbar[0]])
           {
            startline = iTime(NULL,pivotPointTimeFrame,0);
           }
        }
      if(FullScreenLines==false&&A==1)
        {
         startlabel= Time[MoveLabels]+offset;
         startline = WindowFirstVisibleBar();
        }
      if(FullScreenLines==true)
        {
         startlabel=Time[MoveLabels]+offset;
         startline = WindowFirstVisibleBar();
        }
      if(MidPivotsLineStyle_01234>0)
        {
         MidPivotsLineThickness=0;
        }
      SetLevel(" mR5", (r4+r5)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mR4", (r3+r4)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mR3", (r2+r3)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mR2", (r1+r2)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mR1", (p[1]+r1)/2,  MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mS1", (p[1]+s1)/2,  MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mS2", (s1+s2)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mS3", (s2+s3)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mS4", (s3+s4)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
      SetLevel(" mS5", (s4+s5)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline, startlabel, B);
     }

//---- Yesterday High/Low
   if(ShowYesterdayHighLow == true)
     {
      if(FullScreenLines==false&&A==0)
        {

         startlabel= iTime(NULL,pivotPointTimeFrame,0)+offset;
         startline = iTime(NULL,pivotPointTimeFrame,0);  //was "+1", "+0" stops line at Separator
         /*
          startlabel= Time[idxfirstbar[0]+1+ZoomAdjust_3_6_15_30_50 ];
          startline = Time[idxfirstbar[1]+1];  //was "+1", "+0" stops line at Separator
          */
         if(Time[0] > Time[idxfirstbar[0]])
           {
            startline = iTime(NULL,pivotPointTimeFrame,0);
           }
        }
      if(FullScreenLines==false&&A==1)
        {
         startlabel= Time[MoveLabels2];
         startline = WindowFirstVisibleBar();
        }
      if(FullScreenLines==true)
        {
         startlabel=Time[MoveLabels2];
         startline = WindowFirstVisibleBar();
        }
      if(HighLowLineStyle_01234>0)
        {
         HighLowSolidLineThickness=0;
        }
      SetLevel(" yHigh",day_high[1],YesterdayHighLowColor,HighLowLineStyle_01234, HighLowSolidLineThickness, startline, startlabel, B);
      SetLevel(" yLow ",day_low[1],YesterdayHighLowColor,HighLowLineStyle_01234, HighLowSolidLineThickness, startline, startlabel, B);
     }

//---- Today Open
   if(ShowTodayOpen == true)
     {
      if(FullScreenLines==false&&A==0)
        {
         startlabel= iTime(NULL,pivotPointTimeFrame,0)+offset;
         startline = iTime(NULL,pivotPointTimeFrame,0);  //was "+1", "+0" stops line at Separator
         /*
          startlabel= Time[idxfirstbar[0]+1+ZoomAdjust_3_6_15_30_50];
          startline = Time[idxfirstbar[0]+1+ZoomAdjust_3_6_15_30_50];  //was "+1", "+0" stops line at Separator
          */
        }
      if(FullScreenLines==false&&A==1)
        {
         startlabel= Time[MoveLabels2];
         startline = WindowFirstVisibleBar();
        }
      if(FullScreenLines==true)
        {
         startlabel=Time[MoveLabels2];
         startline = WindowFirstVisibleBar();
        }
      if(TodayOpenLineStyle_01234>0)
        {
         TodayOpenSolidLineThickness=0;
        }
      SetLevel(" Open", day_open[0],TodayOpenColor,TodayOpenLineStyle_01234, TodayOpenSolidLineThickness, startline, startlabel, B);
     }

   if(ShowTwoDayPivots)
     {
      for(idx = 2; idx <=Days; idx++)
        {
         startlabel= iTime(NULL,pivotPointTimeFrame,idx-1)+offset;
         startline = iTime(NULL,pivotPointTimeFrame,idx-1);  //was "+1", "+0" stops line at Separator
         endline   = iTime(NULL,pivotPointTimeFrame,idx-2);

         /*

         startline = Time[idxlastbar[idx]-1];  //was "+1", "+0" stops line at Separator
         endline   = Time[idxlastbar[idx-1]-1];
         */
         SetLevel(" BC "+DoubleToStr(idx,0), bc[idx], C_Color, C_LineStyle_01234, C_SolidLineThickness, startline, startlabel, 0, endline);
         SetLevel(" TC "+DoubleToStr(idx,0), tc[idx], C_Color, C_LineStyle_01234, C_SolidLineThickness, startline, startlabel, 0, endline);
         SetLevel(" PV "+DoubleToStr(idx,0), p[idx], CentralPivotColor, CentralPivotLineStyle_01234, CentralPivotSolidLineThickness, startline, startlabel, 0, endline);
        }
     }

//------ Comment for upper left corner
   if(Show_Data_Comment)
     {
      string comment= "\n";
      comment= comment + "Range: Yesterday "+DoubleToStr(MathRound(q/pts),0)
               +" pips, Today "+DoubleToStr(MathRound(d/pts),0)+" pips" + "\n";
      comment= comment + "Highs: Yesterday "+DoubleToStr(day_high[1],Digits)
               +", Today "+DoubleToStr(day_high[0],Digits) +"\n";
      comment= comment + "Lows:  Yesterday "+DoubleToStr(day_low[1],Digits)
               +", Today "+DoubleToStr(day_low[0],Digits)  +"\n";
      comment= comment + "Close: Yesterday "+DoubleToStr(day_close[1],Digits) + "\n";
      comment= comment + "Pivot: Yesterday " + DoubleToStr(p[2],Digits) + " Today " + DoubleToStr(p[1],Digits) + "\n";
      comment= comment + "Central Pivot Range: Yesterday " + DoubleToStr(MathRound((tc[2]-bc[2])/pts),0)+" pips, Today " + DoubleToStr(MathRound((tc[1]-bc[1])/pts),0)+" pips" + "\n";
      comment= comment + "Fibos: 38.2% " + DoubleToStr(day_low[1] + q*0.382, Digits) + ", " + DoubleToStr(day_high[1] - q*0.382,Digits) + "\n";
      comment= comment + "Fibos: 61.8% " + DoubleToStr(day_low[1] + q*0.618, Digits) + ", " + DoubleToStr(day_high[1] - q*0.618,Digits) + "\n";
      Comment(comment);
     }
   return(0);
  }


//+-------------------------------------------------------------------------------------+
//| Get Open, High, Low, Close of the day                                               |
//+-------------------------------------------------------------------------------------+
void GetOHLC(int &idxfirstbarv[], int &idxlastbarv[], double &open[], double &high[], double &low[], double &close[],ENUM_TIMEFRAMES timeframe)
  {
//------walk forward through user specificed number of days and collect high/lows within the day------------------------------
   for(int d = 0; d <= Days; d++)
     {
      high[d] = iHigh(NULL,timeframe,d);
      low[d] = iLow(NULL,timeframe,d);
      open[d]= iOpen(NULL,timeframe,d);
      close[d]= iClose(NULL,timeframe,d);
     }
  }
/*
//+-------------------------------------------------------------------------------------+
//| Get Open, High, Low, Close of the day                                               |
//+-------------------------------------------------------------------------------------+
void GetOHLC(int &idxfirstbarv[], int &idxlastbarv[], double &open[], double &high[], double &low[], double &close[])
{
   //------walk forward through user specificed number of days and collect high/lows within the day------------------------------
   for (int d = 0; d <= Days; d++)
   {
      high[d] = -99999; // not high enough to remain alltime high
      low[d] =  +99999; // not low enough to remain alltime low
      for (int k = idxfirstbar[d]; k>=idxlastbar[d]; k--)
      {
         if (open[d]==0)  // grab first value for open
         open[d]= Open[k];
         high[d]= MathMax(High[k], high[d]);
         low[d]= MathMin(Low[k], low[d]);
         // overwrite close in loop until we leave with the last iteration's value
         close[d]= Close[k];
      }
   }
}
*/
//+-------------------------------------------------------------------------------------+
//| Compute index of first/last bar of Yesterday and today                              |
//+-------------------------------------------------------------------------------------+
void ComputeDayIndices(int tzlocal, int tzdest, int days)
  {
   int tzdiff= tzlocal - tzdest,
       tzdiffsec= tzdiff*3600,
       dayminutes= 24 * 60,
       barsperday= dayminutes/Period();

   int dayofweek= TimeDayOfWeek(Time[0] - tzdiffsec),  // what day is today in the dest timezone?
       dayofweektofind= -1;
// due to gaps in the data, and shift of time around weekends (due
// to time zone) it is not as easy as to just look back for a bar
// with 00:00 time

   idxfirstbar[0]= 0;
   for(int z = 0; z <= days; z++)
     {
      switch(dayofweek)
        {
         case 6: // sat
         case 0: // sun
         case 1: // mon
            dayofweektofind = 5; // Yesterday in terms of trading was previous friday
            break;
         default:
            dayofweektofind = dayofweek -1;
            break;
        }
      //----search  backwards for the last occurrence (backwards) of the day today (today's first bar)-----------
      for(int i=(z*barsperday)+1; i<=(z+1)*barsperday+1; i++)
        {
         datetime timec= Time[i] - tzdiffsec;
         if(TimeDayOfWeek(timec)!=dayofweek)
           {
            idxfirstbar[z]= i-1;
            idxlastbar[z+1] = i;
            break;
           }
        }
      if(dayofweektofind == 1)
        {
         dayString[z+1] = "      Monday    ";
         dayString[z] = "     Tuesday    ";
        }
      if(dayofweektofind == 2)
        {
         dayString[z+1] = "     Tuesday    ";
         dayString[z] = "Wednesday    ";
        }
      if(dayofweektofind == 3)
        {
         dayString[z+1] = "Wednesday    ";
         dayString[z] = "    Thursday    ";
        }
      if(dayofweektofind == 4)
        {
         dayString[z+1] = "    Thursday    ";
         dayString[z] = "        Friday    ";
        }
      if(dayofweektofind == 5)
        {
         dayString[z+1] = "        Friday    ";
         dayString[z] = "      Monday    ";
        }
      dayofweek = dayofweektofind;
     }
  }

//+-----------------------------------------------------------------------------------------+
//| Helper sub-routine that creates lines and their labels                                  |                                                                                  |
//+-----------------------------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle,
              int thickness, datetime startline, datetime startlabel, int CC, datetime endline = 0, int type = 0)
  {
//   int digits= Digits;
   digits= Digits;
   string labelname, linename, pricelabel;

   if(endline==0)
      endline = Time[0];
   if(type == 1)   // scope to include Obj for Central Pivots etc etc
     {
      labelname = ObjCamarilla+" " + text + " Label";
      linename= ObjCamarilla + " " + text + " Line";
     }
   else
     {
      labelname = ObjPivot+" " + text + " Label";
      linename= ObjPivot + " " + text + " Line";
     }

//----create or move the horizontal line-------------------------------------------------
   int Z;
   if(CC == 0)
     {
      Z = OBJ_TREND;
     }
   if(CC == 1)
     {
      Z = OBJ_HLINE;
     }
   if(ObjectFind(linename) != 0)
     {
      ObjectCreate(linename, Z, 0, startline, level, endline, level);
      ObjectSet(linename, OBJPROP_RAY, false);
      ObjectSet(linename, OBJPROP_STYLE, linestyle);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_WIDTH, thickness);
      ObjectSet(linename, OBJPROP_BACK, true);
     }
   else
     {
      ObjectMove(linename, 1, endline, level);
      ObjectMove(linename, 0, startline, level);
     }
   if(hideLabels==false)
     {
      //----create or move the labels-----------------------------------------------------------
      string FontStyle;
      if(L_Label_Norm_Bold_Black_123 <= 1)
        {
         FontStyle = "Arial";
        }
      if(L_Label_Norm_Bold_Black_123 == 2)
        {
         FontStyle = "Arial Bold";
        }
      if(L_Label_Norm_Bold_Black_123 >= 3)
        {
         FontStyle = "Arial Black";
        }
      pricelabel= "                         " + text;
      if(LineLabelsIncludePrice && StrToInteger(text)==0)
        {
         pricelabel= pricelabel + ": "+DoubleToStr(level, Digits);
        }

      if(ObjectFind(labelname) != 0)
        {
         ObjectCreate(labelname, OBJ_TEXT, 0, startlabel, level);
         ObjectSetText(labelname, pricelabel, LineLabelsFontSize, FontStyle, PivotLinesLabelColor);
         ObjectSet(labelname, OBJPROP_BACK, true);
        }
      else
        {
         ObjectMove(labelname, 0, startlabel, level);
        }
     }

  }

//+-------------------------------------------------------------------------------------------+
//| Helper=draws vertical timelines & gets "Yesterday/today" from elsewhere and displays them.|
//+-------------------------------------------------------------------------------------------+
void SetTimeLine(string objname, string text, int idx, color col1, double vleveltext)
  {
   string FontStyle;
   string name= "[TIME] " + objname;
   int x= Time[idx];
   if(ObjectFind(name) != 0)
     {
      ObjectCreate(name, OBJ_TREND, 0, x, 0, x, 100);
      ObjectSet(name, OBJPROP_STYLE, SeparatorLinesStyle_01234);
      ObjectSet(name, OBJPROP_COLOR, PeriodSeparatorLinesColor);
      ObjectSet(name, OBJPROP_WIDTH, SeparatorLinesThickness);
     }
   else
     {
      ObjectMove(name, 0, x, 0);
      ObjectMove(name, 1, x, 100);
     }
   if(ShowPeriodSeparatorLabels ==true)
     {
      if(S_Label_Norm_Bold_Black_123 <= 1)
        {
         FontStyle = "Arial";
        }
      if(S_Label_Norm_Bold_Black_123 == 2)
        {
         FontStyle = "Arial Bold";
        }
      if(S_Label_Norm_Bold_Black_123 >= 3)
        {
         FontStyle = "Arial Black";
        }
      if(ObjectFind(name + " Label") != 0)
        {
         ObjectCreate(name + " Label", OBJ_TEXT, 0, x, vleveltext);
         ObjectSetText(name + " Label", text, SeparatorLabelFontSize, FontStyle,  PeriodSeparatorsLabelsColor);
        }
      else
        {
         ObjectMove(name + " Label", 0, x, vleveltext);
        }
     }
  }

//+-------------------------------------------------------------------------------------------+
//|                       End of Program                                                      |
//+-------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
