// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=60891

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
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red

extern color Bullish = Blue;
extern color Bearish = Red;
extern int Extend = 50;

extern int Period = 5;
extern int ArrowSize = 2;

input bool   notificationsOn       = false;                  // Notifications On:
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications


double UpArrow[], DnArrow[];
double Count[];

string IndicatorName;
string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
  {
   string name = target;
   int try
         = 2;
   while(WindowFind(name) != -1)
     {
      name = target + " #" + IntegerToString(try
                                                ++);
     }
   return name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
   IndicatorName = GenerateIndicatorName("ConsecutiveCandleRangeLine");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   SetIndexStyle(0, DRAW_ARROW, 0, ArrowSize);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, UpArrow);
   SetIndexStyle(1, DRAW_ARROW, 0, ArrowSize);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, DnArrow);
   SetIndexBuffer(2, Count);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawARROW(int pos, int Flag, double Price)
  {
   if(Flag == 1)
      UpArrow[pos] = Price ;
   if(Flag == -1)
      DnArrow[pos] = Price ;
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   bool nb = IsNewBar();
   int counted_bars = IndicatorCounted();
   if(counted_bars > 0)
      counted_bars--;
   int limit = Bars - counted_bars;
   if(nb)
     {
      ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
      limit = Bars - 1;
     }
   int pos;
   pos = limit - 1;
   int x;
   while(pos >= 0)
     {
      if(pos == limit - 1)
        {
         Count[pos + 1] = pos + 1;
        }
      Count[pos] = Count[pos + 1];
      x = Count[pos + 1];
      if(Close[pos] > Open[pos]  && Close[x] < Open[x])
        {
         Count[pos] = pos;
        }
      if(Close[pos] < Open[pos] && Close[x] > Open[x])
        {
         Count[pos] = pos;
        }
      pos--;
     }
   pos = limit - 1;
   while(pos >= 1)
     {
      if((Count[pos] - pos + 1) >= Period  && Count[pos - 1] == pos - 1)
        {
         x = Count[pos];
         if(Close[pos] > Open[pos])
           {
            DrawARROW(pos, -1, High[pos]);
            DrawARROW(x, 1, Low[x]);
            DrawLine(pos, true);
            DrawLine(x,  false);
           }
         if(Close[pos] < Open[pos])
           {
            DrawARROW(x, -1, High[x]);
            DrawARROW(pos, 1, Low[pos]);
            DrawLine(x, true);
            DrawLine(pos, false);
           }
        }
      pos--;
     }
   if(notificationsOn && nb)
     {
      static datetime lastArrowAlerted;
      int lastArrow;
      for(int i = 0; i < Bars; i++)
        {
         if(UpArrow[i] != EMPTY_VALUE || DnArrow[i] != EMPTY_VALUE)
           {
            lastArrow = i;
            break;
           }
        }
      if(Time[lastArrow] != lastArrowAlerted)
        {
         if(lastArrowAlerted != 0)
            Notify(0);
         lastArrowAlerted = Time[lastArrow];
        }
     }
   return(0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(int First, bool BullFl)
  {
   string ObjName = IndicatorObjPrefix + (string)Time[First];
   int WindowNumber = 0;
   if(ObjectFind(ObjName) == -1)
     {
      //  WindowNumber=WindowFind("ConsecutiveCandleRangeLine");
      //  WindowNumber=0;
      if(WindowNumber != -1)
        {
         int x = MathMax((First - Extend), 0);
         if(BullFl)
           {
            ObjectCreate(ObjName, OBJ_TREND, WindowNumber, Time[First], High[First], Time[x], High[First]);
            ObjectSet(ObjName, OBJPROP_RAY, false);
            ObjectSet(ObjName, OBJPROP_COLOR, Bullish);
            // ObjectCreate(ObjName+"A", OBJ_ARROW, WindowNumber, Time[First], High[First]);
            //  ObjectSet(ObjName+"A", OBJPROP_COLOR, Bullish);
            // ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 242);
           }
         else
           {
            ObjectCreate(ObjName, OBJ_TREND, WindowNumber, Time[First], Low[First], Time[x], Low[First]);
            ObjectSet(ObjName, OBJPROP_RAY, false);
            ObjectSet(ObjName, OBJPROP_COLOR, Bearish);
            //ObjectCreate(ObjName+"A", OBJ_ARROW, WindowNumber, Time[First], Low[First]);
            // ObjectSet(ObjName+"A", OBJPROP_COLOR, Bearish);
            //  ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 241);
           }
        }
     }
   return;
  }

//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Consecutive Candle Range Indicator: ";
   switch(type)
     {
      case 0:
         text += " New arrow is appeared - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(!notificationsOn)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
