// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=158854#p158854

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2025, Gehtsoft USA LLC  |
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

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_minimum 0
#property indicator_maximum 1

#property indicator_color1  Red
#property indicator_color2  Blue
#property indicator_width1  2
#property indicator_width2  2

input ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT;
input int    Length             = 1;
input int    barsback           = 500;
input bool   alertsOn           = true;
input bool   alertsOnCurrent    = false;
input bool   alertsMessage      = true;
input bool   alertsSound        = false;
input bool   alertsNotify       = false;
input bool   alertsEmail        = false;
input string soundfile          = "alert2.wav";
input bool   arrowsVisible      = true;
input string arrowsIdentifier   = "filterArrows";
input double arrowsDisplacement = 0.5;
input color  arrowsUpColor      = clrDeepSkyBlue;
input color  arrowsDnColor      = clrRed;
input int    arrowsUpCode       = 233;
input int    arrowsDnCode       = 234;
input int    arrowsUpSize       = 1;
input int    arrowsDnSize       = 1;

double buffer1[];
double buffer2[];
bool cer;
bool cer2;
bool cer3 = true;
string fileName;
int iCustom_handle;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(buffer1, true);
   ArraySetAsSeries(buffer2, true);
   cer3 = true;
//
   SetIndexBuffer(0, buffer1, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 1);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrRed);
//
   SetIndexBuffer(1, buffer2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(1, PLOT_COLOR_INDEXES, 1);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, clrBlue);
//
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//
   fileName = "Holy Grail075";
   iCustom_handle = iCustom(NULL, timeFrame, fileName, 0, Length, barsback, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsNotify, alertsEmail, soundfile, arrowsVisible, arrowsIdentifier, arrowsDisplacement, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, arrowsUpSize, arrowsDnSize);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, arrowsIdentifier);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double custom_indi_calc(int buffer, int shift)
  {
   double value[1];
   int copy = CopyBuffer(iCustom_handle, buffer, shift, 1, value);
   if(copy > 0)
     {
      return value[0];
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);
    if(timeFrame != Period() && timeFrame !=0)
     {
      int limit = MathMin(iBars(Symbol(), Period()) - 1, barsback * timeFrame / Period());
      for(int i = limit; i >= 0; i--)
        {
         int y = iBarShift(NULL, timeFrame, time[i]);
         buffer1[i] = custom_indi_calc(0, y);
         buffer2[i] = custom_indi_calc(1, y);
        }
      return(rates_total);
     }
   double high1;
   double low1;
   double cero[10000][3];
   if(!cer3)
      return(rates_total);
   int pep = 0;
   int bep = 0;
   int tep = 0;
   double high60 = high[barsback];
   double low68 = low[barsback];
   int li3 = barsback;
   int li6 = barsback;
   for(int li2 = barsback; li2 >= 0; li2--)
     {
      low1 = 10000000;
      high1 = -100000000;
      for(int li8 = li2 + Length; li8 >= li2 + 1; li8--)
        {
         if(low[li8] < low1)
            low1 = low[li8];
         if(high[li8] > high1)
            high1 = high[li8];
        }
      if(low[li2] < low1 && high[li2] > high1)
        {
         bep = 2;
         if(pep == 1)
            li3 = li2 + 1;
         if(pep == -1)
            li6 = li2 + 1;
        }
      else
        {
         if(low[li2] < low1)
            bep = -1;
         if(high[li2] > high1)
            bep = 1;
        }
      if(bep != pep && pep != 0)
        {
         if(bep == 2)
           {
            bep = -pep;
            high60 = high[li2];
            low68 = low[li2];
            cer = false;
            cer2 = false;
           }
         tep++;
         if(bep == 1)
           {
            cero[tep][1] = li6;
            cero[tep][2] = low68;
            cer = false;
            cer2 = true;
           }
         if(bep == -1)
           {
            cero[tep][1] = li3;
            cero[tep][2] = high60;
            cer = true;
            cer2 = false;
           }
         high60 = high[li2];
         low68 = low[li2];
        }
      if(bep == 1 && high[li2] >= high60)
        {
         high60 = high[li2];
         li3 = li2;
        }
      if(bep == -1 && low[li2] <= low68)
        {
         low68 = low[li2];
         li6 = li2;
        }
      pep = bep;
      if(cer2)
        {
         buffer2[li2] = 1;
         buffer1[li2] = EMPTY_VALUE;
        }
      else
         if(cer)
           {
            buffer2[li2] = EMPTY_VALUE;
            buffer1[li2] = 1;
           }
         else
           {
            buffer1[li2] = EMPTY_VALUE;
            buffer2[li2] = EMPTY_VALUE;
           }
      
     }
     for(int li2 = barsback; li2 >= 0; li2--)
     {
     manageArrow(iTime(NULL, 0, li2), high[li2], low[li2], buffer1[li2], buffer2[li2],buffer1[li2+1], buffer2[li2+1]);
     }
   manageAlerts(time, buffer1, buffer2);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageArrow(datetime t, double hi, double lo, double b1, double b2, double b11, double b22)
  {
   if(!arrowsVisible)
      return;
   string name = arrowsIdentifier + ":" + IntegerToString((int)t);
   ObjectDelete(0, name);
   double gap = iATRMQL4(NULL, 0, 20, iBarShift(NULL, 0, t));
    
   if(b2 == 1 && b22 != 1)
      drawArrow(name, t, lo - arrowsDisplacement * gap, arrowsUpColor, arrowsUpCode, arrowsUpSize);
   if(b1 == 1 && b11 != 1)
      drawArrow(name, t, hi + arrowsDisplacement * gap, arrowsDnColor, arrowsDnCode, arrowsDnSize);
    
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(string name, datetime t, double price, color theColor, int theCode, int theSize)
  {
   ObjectCreate(0, name, OBJ_ARROW, 0, t, price);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, theCode);
   ObjectSetInteger(0, name, OBJPROP_COLOR, theColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, theSize);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageAlerts(const datetime &time[], const double &buf1[], const double &buf2[])
  {
   static string previousAlert = "nothing";
   static datetime previousTime = 0;
   int whichBar = alertsOnCurrent ? 0 : 1;
   if(buf2[whichBar] == 1 && buf2[whichBar + 1] == 0)
      doAlert(time[whichBar], "up");
   if(buf1[whichBar] == 1 && buf1[whichBar + 1] == 0)
      doAlert(time[whichBar], "down");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(datetime t, string direction)
  {
   static string previousAlert = "";
   static datetime previousTime = 0;
   if(previousAlert != direction || previousTime != t)
     {
      previousAlert = direction;
      previousTime = t;
      string message = Symbol() + " at " + TimeToString(TimeLocal(), TIME_SECONDS) + " FILTER-EXTRA " + direction;
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(Symbol() + " FILTER-EXTRA ", message);
      if(alertsSound)
         PlaySound(soundfile);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iATRMQL4(string symbol, int tf, int period, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   int handle = iATR(symbol, timeframe, period);
   if(handle < 0)
     {
      Print("The iATR object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
