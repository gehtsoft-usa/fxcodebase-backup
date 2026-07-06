// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70454
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
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 DodgerBlue // up[]
#property indicator_width1 1
#property indicator_color2 Red // down[]
#property indicator_width2 1
#property indicator_color3 DodgerBlue // atrlo[]
#property indicator_width3 1
#property indicator_color4 Red // atrhi[]
#property indicator_width4 1
#property indicator_color5 DodgerBlue // arrup[]
#property indicator_width5 1
#property indicator_color6 Red // arrdwn[]
#property indicator_width6 1

input int ssd_k = 5; // %K Period
input int ssd_d = 3; // %D Period
input int ssd_slowing = 3; // Slowing
input string TimeFrame = "Current time frame";
input int Amplitude = 2.0; //input double //input int
input bool alertsOn = true;
input bool alertsOnCurrent = false;
input bool alertsMessage = true;
input bool alertsNotification = true; //false;
input bool alertsSound = true;
input bool alertsEmail = false;

input bool ShowBars = false; //true;
input bool ShowArrows = true;
input int arrowSize = 2;
input int uparrowCode = 233;
input int dnarrowCode = 234;
input bool ArrowsOnFirstBar = true;

bool nexttrend;
double minhighprice, maxlowprice;
double up[], down[], atrlo[], atrhi[], trend[];
double arrup[], arrdwn[];

string indicatorFileName;
bool returnBars;
int timeFrame;

double ssd[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   for (int i = 0; i < indicator_buffers; i++)
      SetIndexStyle(i, DRAW_LINE);
   IndicatorBuffers(8); // +1 buffer - trend[]
   SetIndexBuffer(0, up);
   SetIndexBuffer(1, down);
   SetIndexBuffer(2, atrlo);
   SetIndexBuffer(3, atrhi);
   SetIndexBuffer(4, arrup);
   SetIndexBuffer(5, arrdwn);
   SetIndexBuffer(6, trend);
   SetIndexBuffer(7, ssd);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(6, 0.0);

   if (ShowBars)
   {
      SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID);
      SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID);
   }
   else
   {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
   }
   if (ShowArrows)
   {
      SetIndexStyle(4, DRAW_ARROW, 0, arrowSize);
      SetIndexArrow(4, uparrowCode);
      SetIndexStyle(5, DRAW_ARROW, 0, arrowSize);
      SetIndexArrow(5, dnarrowCode);
   }
   else
   {
      SetIndexStyle(4, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
   }

   nexttrend = 0;
   minhighprice = High[Bars - 1];
   maxlowprice = Low[Bars - 1];
   indicatorFileName = WindowExpertName();
   returnBars = TimeFrame == "returnBars";
   if (returnBars)
      return (0);
   timeFrame = stringToTimeFrame(TimeFrame);
   return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   if (returnBars)
   {
      up[0] = limit + 1;
      return (0);
   }
   if (timeFrame != Period())
   {
      int shift = -1;
      if (ArrowsOnFirstBar)
         shift = 1;
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrame, indicatorFileName, "returnBars", 0, 0) * timeFrame / Period()));
      for (int i = limit; i >= 0; i--)
      {
         int y = iBarShift(NULL, timeFrame, Time[i]);
         int x = iBarShift(NULL, timeFrame, Time[i + shift]);
         up[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Amplitude, alertsOn, alertsOnCurrent, alertsMessage, alertsNotification, alertsSound, alertsEmail, 0, y);
         down[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Amplitude, alertsOn, alertsOnCurrent, alertsMessage, alertsNotification, alertsSound, alertsEmail, 1, y);
         atrlo[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Amplitude, alertsOn, alertsOnCurrent, alertsMessage, alertsNotification, alertsSound, alertsEmail, 2, y);
         atrhi[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Amplitude, alertsOn, alertsOnCurrent, alertsMessage, alertsNotification, alertsSound, alertsEmail, 3, y);
         if (x != y)
         {
            arrup[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Amplitude, alertsOn, alertsOnCurrent, alertsMessage, alertsNotification, alertsSound, alertsEmail, 4, y);
            arrdwn[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Amplitude, alertsOn, alertsOnCurrent, alertsMessage, alertsNotification, alertsSound, alertsEmail, 5, y);
         }
         else
         {
            arrup[i] = EMPTY_VALUE;
            arrdwn[i] = EMPTY_VALUE;
         }
      }
      return (0);
   }
   double atr, lowprice_i, highprice_i, lowma, highma;
   int workbar = 0;

   for (i = Bars - 1; i >= 0; i--)
   {
      ssd[i] = iStochastic(_Symbol, _Period, ssd_k, ssd_d, ssd_slowing, MODE_SMA, 0, MODE_MAIN, i);
      int highestIndex = ArrayMaximum(ssd, Amplitude, i - Amplitude);
      int lowestIndex = ArrayMinimum(ssd, Amplitude, i - Amplitude);
      highprice_i = ssd[highestIndex];
      lowprice_i = ssd[lowestIndex];
      lowma = iMAOnArray(ssd, 0, Amplitude, 0, MODE_SMA, i);
      highma = lowma;
      trend[i] = trend[i + 1];
      atr = iATR(Symbol(), 0, 100, i) / 2;

      arrup[i] = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;
      if (nexttrend == 1)
      {
         maxlowprice = MathMax(lowprice_i, maxlowprice);

         if (highma < maxlowprice && Close[i] < Low[i + 1])
         {
            trend[i] = 1.0;
            nexttrend = 0;
            minhighprice = highprice_i;
         }
      }
      if (nexttrend == 0)
      {
         minhighprice = MathMin(highprice_i, minhighprice);

         if (lowma > minhighprice && Close[i] > High[i + 1])
         {
            trend[i] = 0.0;
            nexttrend = 1;
            maxlowprice = lowprice_i;
         }
      }
      if (trend[i] == 0.0)
      {
         if (trend[i + 1] != 0.0)
         {
            up[i] = down[i + 1];
            up[i + 1] = up[i];
            arrup[i] = up[i] - 2 * atr;
         }
         else
         {
            up[i] = MathMax(maxlowprice, up[i + 1]);
         }
         atrhi[i] = up[i] - atr;
         atrlo[i] = up[i];
         down[i] = 0.0;
      }
      else
      {
         if (trend[i + 1] != 1.0)
         {
            down[i] = up[i + 1];
            down[i + 1] = down[i];
            arrdwn[i] = down[i] + 2 * atr;
         }
         else
         {
            down[i] = MathMin(minhighprice, down[i + 1]);
         }
         atrhi[i] = down[i] + atr;
         atrlo[i] = down[i];
         up[i] = 0.0;
      }
   }
   manageAlerts();
   return (0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M10", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 10, 15, 30, 60, 240, 1440, 10080, 43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tfs == sTfTable[i] || tfs == "" + iTfTable[i])
         return (MathMax(iTfTable[i], Period()));
   return (Period());
}
string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string s = str;

   for (int length = StringLen(str) - 1; length >= 0; length--)
   {
      int tchar = StringGetChar(s, length);
      if ((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
         s = StringSetChar(s, length, tchar - 32);
      else if (tchar > -33 && tchar < 0)
         s = StringSetChar(s, length, tchar + 224);
   }
   return (s);
}

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;
      if (arrup[whichBar] != EMPTY_VALUE)
         doAlert(whichBar, "up");
      if (arrdwn[whichBar] != EMPTY_VALUE)
         doAlert(whichBar, "down");
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string previousAlert = "nothing";
   static datetime previousTime;
   string message;

   if (previousAlert != doWhat || previousTime != Time[forBar])
   {
      previousAlert = doWhat;
      previousTime = Time[forBar];

      //
      //
      //
      //
      //

      message = StringConcatenate(Symbol(), " ", timeFrameToString(timeFrame), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " HalfTrend ", doWhat);
      if (alertsMessage)
         Alert(message);
      if (alertsEmail)
         SendMail(StringConcatenate(Symbol(), "HalfTrend "), message);
      if (alertsNotification)
         SendNotification(message);
      if (alertsSound)
         PlaySound("alert2.wav");
   }
}