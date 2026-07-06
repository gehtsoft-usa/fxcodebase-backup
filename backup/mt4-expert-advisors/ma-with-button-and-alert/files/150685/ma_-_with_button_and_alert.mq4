// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68338

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property strict

input ENUM_MA_METHOD ma1_method = MODE_EMA;  // MA 1 Method
input int            ma1_length = 8;         // MA 1 Length
input color          ma1_color  = clrGreen;  // MA 1 Color
input int            ma1_width  = 1;         // MA 1 Line Width
input int            ma1_shift  = 0;         // MA 1 Shift
input ENUM_MA_METHOD ma2_method = MODE_EMA;  // MA 2 Method
input int            ma2_length = 21;        // MA 2 Length
input color          ma2_color  = clrRed;    // MA 2 Color
input int            ma2_width  = 1;         // MA 2 Line Width
input int            ma2_shift  = 0;         // MA 2 Shift
input ENUM_MA_METHOD ma3_method = MODE_EMA;  // MA 3 Method
input int            ma3_length = 50;        // MA 3 Length
input color          ma3_color  = clrBlue;   // MA 3 Color
input int            ma3_width  = 1;         // MA 3 Line Width
input int            ma3_shift  = 0;         // MA 3 Shift
input ENUM_MA_METHOD ma4_method = MODE_EMA;  // MA 4 Method
input int            ma4_length = 200;       // MA 4 Length
input color          ma4_color  = clrYellow; // MA 4 Color
input int            ma4_width  = 1;         // MA 4 Line Width
input int            ma4_shift  = 0;         // MA 4 Shift
input ENUM_MA_METHOD ma5_method = MODE_EMA;  // MA 5 Method
input int            ma5_length = 800;       // MA 5 Length
input color          ma5_color  = clrBrown;  // MA 5 Color
input int            ma5_width  = 1;         // MA 5 Line Width
input int            ma5_shift  = 0;         // MA 5 Shift
input string         DisplayID  = "ma x 5";  // Display id
input int            button_x   = 20;        // Horizontal location
input int            button_y   = 30;        // Vertical location
//
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input double pipDistance = 2;
input bool   desktop_notifications = true;                  // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications
double ma1[], ma2[], ma3[], ma4[], ma5[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(ObjectFind(DisplayID) != 0)
     {
      ObjectCreate(ChartID(), DisplayID, OBJ_BUTTON, 0, 0, 0);
      ObjectSetString(ChartID(), DisplayID, OBJPROP_TEXT, "Ma x 5 is on");
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_CORNER, 2);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, clrDimGray);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_YDISTANCE, button_x);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_XDISTANCE, button_y);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_XSIZE, 85);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_YSIZE, 20);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_HIDDEN, true);
      ObjectSetInteger(ChartID(), DisplayID, OBJPROP_STATE, true);
     }
   SetIndexBuffer(0, ma1);
   SetIndexBuffer(1, ma2);
   SetIndexBuffer(2, ma3);
   SetIndexBuffer(3, ma4);
   SetIndexBuffer(4, ma5);
//
//
//
   if(GetButtonState(DisplayID) != "off")
     {
      SetIndexBuffer(0, ma1);
      SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, ma1_width, ma1_color);
      SetIndexShift(0, ma1_shift);
      SetIndexBuffer(1, ma2);
      SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, ma2_width, ma2_color);
      SetIndexShift(1, ma2_shift);
      SetIndexBuffer(2, ma3);
      SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, ma3_width, ma3_color);
      SetIndexShift(2, ma3_shift);
      SetIndexBuffer(3, ma4);
      SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, ma4_width, ma4_color);
      SetIndexShift(3, ma4_shift);
      SetIndexBuffer(4, ma5);
      SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, ma5_width, ma5_color);
      SetIndexShift(4, ma5_shift);
     }
   else
      for(int i = 0; i < 5; i++)
         SetIndexStyle(i, DRAW_NONE);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   switch(reason)
     {
      case REASON_PARAMETERS  :
      case REASON_CHARTCHANGE :
      case REASON_RECOMPILE   :
      case REASON_CLOSE       :
         break;
      default :
        {
         ObjectDelete(DisplayID);
        }
     }
  }
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
   static string prevState = "";
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == DisplayID)
     {
      string newState = GetButtonState(DisplayID);
      if(newState != prevState)
         if(newState == "off")
           { SetIndexStyle(0, DRAW_NONE); SetIndexStyle(1, DRAW_NONE); SetIndexStyle(2, DRAW_NONE); SetIndexStyle(3, DRAW_NONE); SetIndexStyle(4, DRAW_NONE); prevState = newState; }
         else
           {
            SetIndexStyle(0, DRAW_LINE);
            SetIndexStyle(1, DRAW_LINE);
            SetIndexStyle(2, DRAW_LINE);
            SetIndexStyle(3, DRAW_LINE);
            SetIndexStyle(4, DRAW_LINE);
            prevState = newState;
           }
      ObjectSetString(ChartID(), DisplayID, OBJPROP_TEXT, "MA x 5 is " + newState);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 const long &tick_volume[],
                 const long &volume[],
                 const int &spread[])
  {
   int i = rates_total - prev_calculated + 1;
   if(i >= rates_total)
      i = rates_total - 1;
//
//
//
   for(; i >= 0 && !_StopFlag; i--)
     {
      ma1[i] = iMA(_Symbol, _Period, ma1_length, ma1_shift, ma1_method, PRICE_CLOSE, i);
      ma2[i] = iMA(_Symbol, _Period, ma2_length, ma2_shift, ma2_method, PRICE_CLOSE, i);
      ma3[i] = iMA(_Symbol, _Period, ma3_length, ma3_shift, ma3_method, PRICE_CLOSE, i);
      ma4[i] = iMA(_Symbol, _Period, ma4_length, ma4_shift, ma4_method, PRICE_CLOSE, i);
      ma5[i] = iMA(_Symbol, _Period, ma5_length, ma5_shift, ma5_method, PRICE_CLOSE, i);
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
// Comment((ma1[0]-ma2[0])*Point*pip());
   return(rates_total);
  }

//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetButtonState(string whichbutton)
  {
   bool selected = ObjectGetInteger(ChartID(), whichbutton, OBJPROP_STATE);
   if(selected)
     { return ("on"); }
   else
     {
      return ("off");
     }
  }

//+------------------------------------------------------------------+
double pip()
  {
   double po = MarketInfo(Symbol(), MODE_POINT);
   int di = (int)MarketInfo(Symbol(), MODE_DIGITS);
   return (di % 2 == 1 ? po * 10 : po);
  }
//+------------------------------------------------------------------+
bool alerted;
void checkAlert()
  {
   double p = pipDistance * pip();
   int b = notificationsOn - 1;
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if((MathAbs(ma1[b + 1] - ma2[b + 1]) < p || MathAbs(ma2[b + 1] - ma3[b + 1]) < p ||
          MathAbs(ma3[b + 1] - ma4[b + 1]) < p || MathAbs(ma4[b + 1] - ma5[b + 1]) < p) &&
         MathAbs(ma1[b] - ma2[b]) > p && MathAbs(ma2[b] - ma3[b]) > p &&
         MathAbs(ma3[b] - ma4[b]) > p && MathAbs(ma4[b] - ma5[b]) > p &&
         ma1[b] > ma2[b] && ma2[b] > ma3[b] && ma3[b] > ma4[b] && ma4[b] > ma5[b])
        {
         Notify(1);
         alerted = true;
        }
      if((MathAbs(ma1[b + 1] - ma2[b + 1]) < p || MathAbs(ma2[b + 1] - ma3[b + 1]) < p ||
          MathAbs(ma3[b + 1] - ma4[b + 1]) < p || MathAbs(ma4[b + 1] - ma5[b + 1]) < p) &&
         MathAbs(ma1[b] - ma2[b]) > p && MathAbs(ma2[b] - ma3[b]) > p &&
         MathAbs(ma3[b] - ma4[b]) > p && MathAbs(ma4[b] - ma5[b]) > p &&
         ma1[b] < ma2[b] && ma2[b] < ma3[b] && ma3[b] < ma4[b] && ma4[b] < ma5[b])
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if((MathAbs(ma1[b + 1] - ma2[b + 1]) < p || MathAbs(ma2[b + 1] - ma3[b + 1]) < p ||
          MathAbs(ma3[b + 1] - ma4[b + 1]) < p || MathAbs(ma4[b + 1] - ma5[b + 1]) < p) &&
         MathAbs(ma1[b] - ma2[b]) > p && MathAbs(ma2[b] - ma3[b]) > p &&
         MathAbs(ma3[b] - ma4[b]) > p && MathAbs(ma4[b] - ma5[b]) > p &&
         ma1[b] > ma2[b] && ma2[b] > ma3[b] && ma3[b] > ma4[b] && ma4[b] > ma5[b])
        {
         Notify(11);
        }
      if((MathAbs(ma1[b + 1] - ma2[b + 1]) < p || MathAbs(ma2[b + 1] - ma3[b + 1]) < p ||
          MathAbs(ma3[b + 1] - ma4[b + 1]) < p || MathAbs(ma4[b + 1] - ma5[b + 1]) < p) &&
         MathAbs(ma1[b] - ma2[b]) > p && MathAbs(ma2[b] - ma3[b]) > p &&
         MathAbs(ma3[b] - ma4[b]) > p && MathAbs(ma4[b] - ma5[b]) > p &&
         ma1[b] < ma2[b] && ma2[b] < ma3[b] && ma3[b] < ma4[b] && ma4[b] < ma5[b])
        {
         Notify(22);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   datetime time =  TimeCurrent();
   string text = "MA: ";
   switch(type)
     {
      case 1:
         text += " MAs move away UP in order before bar closes on - " + _Symbol + " " + GetTimeFrame(_Period);
         //ObjectCreate(0, "Alert_UP_BC_" + (string)time, OBJ_VLINE, 0, time, 0);
         break;
      case 2:
         text += " MAs move away DOWN in order before bar closes on - " + _Symbol + " " + GetTimeFrame(_Period);
         //ObjectCreate(0, "Alert_DO_BC_" + (string)time, OBJ_VLINE, 0, time, 0);
         break;
      case 11:
         text += " MAs move away UP in order  after bar closed on - " + _Symbol + " " + GetTimeFrame(_Period);
         //ObjectCreate(0, "Alert_UP_AC_" + (string)time, OBJ_VLINE, 0, time, 0);
         break;
      case 22:
         text += " MAs move away DOWN in order after bar closed on - " + _Symbol + " " + GetTimeFrame(_Period);
         //ObjectCreate(0, "Alert_DO_AC_" + (string)time, OBJ_VLINE, 0, time, 0);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
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
