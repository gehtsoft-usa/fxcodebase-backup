//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75251

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 7

#property strict

//
//
//
enum enTimeFrames
  {
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mn1 = PERIOD_MN1,     // Monthly
   tf_n1  = -1,             // First higher time frame
   tf_n2  = -2,             // Second higher time frame
   tf_n3  = -3              // Third higher time frame
  };
//
enum  enMaTypes
  {
   ma_sma,                                  // Simple moving average
   ma_ema,                                  // Exponential moving average
   ma_smma,                                 // Smoothed MA
   ma_lwma,                                 // Linear weighted MA
   ma_slwma,                                // Smoothed LWMA
   ma_dsema,                                // Double Smoothed Exponential average
   ma_tema,                                 // Triple exponential moving average - TEMA
   ma_lsma                                  // Linear regression value (lsma)
  };
//

extern enTimeFrames      TimeFrame    = tf_cu ;          // Time frame
input int                MAPeriod1    = 33;              // Fast channel Ma period
input int                MAPeriod2    = 144;             // Slow channel Ma period
input enMaTypes          MAType       = ma_ema;          // Ma type
input int                LineWidth    = 2;               // Lines   width
input color              Scolor       = clrDeepSkyBlue;  // Short channel  line  color
input color              Lcolor       = clrOrange;       // Long channel  line  color
extern int                btn_Subwindow = 0;
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER;
extern string             btn_text              = "channel";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;
extern color              btn_text_ON_color     = clrLime;
extern color              btn_text_OFF_color    = clrRed;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 900;
extern int                button_y              = 20;
extern int                btn_Width             = 60;
extern int                btn_Height            = 20;
input bool               Interpolate  = true;            // Interpolate in multi time frame mode on/off?

enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications

bool show_data = true;
bool recalc    = true;

string IndicatorName, IndicatorObjPrefix, buttonId;

double shortl[], shorth[], longl[], longh[], count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,MAPeriod1,MAPeriod2,MAType,LineWidth,Scolor,Lcolor,btn_Subwindow,btn_corner,btn_text,btn_Font,btn_FontSize,btn_text_ON_color,btn_text_OFF_color,btn_background_color,btn_border_color,button_x,button_y,btn_Width,btn_Height,_buff,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   double val;
   if(GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;
   IndicatorBuffers(5);
   SetIndexBuffer(0, shortl, INDICATOR_DATA);
   SetIndexStyle(0, DRAW_LINE, EMPTY, LineWidth, Scolor);
   SetIndexBuffer(1, shorth, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_LINE, EMPTY, LineWidth, Scolor);
   SetIndexBuffer(2, longl,  INDICATOR_DATA);
   SetIndexStyle(2, DRAW_LINE, EMPTY, LineWidth, Lcolor);
   SetIndexBuffer(3, longh,  INDICATOR_DATA);
   SetIndexStyle(3, DRAW_LINE, EMPTY, LineWidth, Lcolor);
   SetIndexBuffer(4, count);
   indicatorFileName = WindowExpertName();
   TimeFrame         = (enTimeFrames)timeFrameValue(TimeFrame);
   IndicatorSetString(INDICATOR_SHORTNAME, timeFrameToString(TimeFrame) + " (" + (string)MAPeriod1 + "," + (string)MAPeriod2 + ")");
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + (btn_text);
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   ObjectsDeleteAll(0, "arrD");
   ObjectsDeleteAll(0, "arrU");
  }

//
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
  {
   ObjectDelete(0, buttonID);
   ObjectCreate(0, buttonID, OBJ_BUTTON, btn_Subwindow, 0, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(0, buttonID, OBJPROP_FONT, font);
   ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
  }
//+------------------------------------------------------------------+
void handleButtonClicks()
  {
   if(ObjectGetInteger(0, buttonId, OBJPROP_STATE))
     {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      // start();
     }
  }
//
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   handleButtonClicks();
   if(id == CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam, OBJPROP_TYPE) == OBJ_BUTTON)
      SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   if(show_data)
     {
      handleButtonClicks();
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_ON_color);
     }
   else
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_OFF_color);
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
      ObjectsDeleteAll(0, "arrD");
      ObjectsDeleteAll(0, "arrU");
     }
  }
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
  {
   int i, limit = fmin(rates_total - prev_calculated + 1, rates_total - 1);
   count[0] = limit;
   if(TimeFrame != _Period)
     {
      limit = (int)fmax(limit, fmin(rates_total - 1, _mtfCall(4, 0) * TimeFrame / _Period));
      for(i = limit; i >= 0 && !_StopFlag; i--)
        {
         int y = iBarShift(NULL, TimeFrame, time[i]);
         shortl[i] = _mtfCall(0, y);
         shorth[i] = _mtfCall(1, y);
         longl[i]  = _mtfCall(2, y);
         longh[i]  = _mtfCall(3, y);
         //
         //
         //
         if(!Interpolate || (i > 0 && y == iBarShift(NULL, TimeFrame, time[i - 1])))
            continue;
         //
         //
         //
#define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
         int n, k;
         datetime dtime = iTime(NULL, TimeFrame, y);
         for(n = 1; (i + n) < rates_total && time[i + n] >= dtime; n++)
            continue;
         for(k = 1; k < n && (i + n) < rates_total && (i + k) < rates_total; k++)
           {
            _interpolate(shortl);
            _interpolate(shorth);
            _interpolate(longl);
            _interpolate(longh);
           }
        }
      return(rates_total);
     }
//
//
//
   for(i = limit; i >= 0; i--)
     {
      shortl[i]  = iCustomMa(MAType, iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_LOW, i), MAPeriod1, i, rates_total, 0);
      shorth[i]  = iCustomMa(MAType, iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_HIGH, i), MAPeriod1, i, rates_total, 1);
      longl[i]   = iCustomMa(MAType, iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_LOW, i), MAPeriod2, i, rates_total, 2);
      longh[i]   = iCustomMa(MAType, iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_HIGH, i), MAPeriod2, i, rates_total, 3);
     }
   for(i = rates_total - 1; i >= 0; i--)
     {
      if((shorth[i] >= longl[i] && shorth[i] >= longh[i] && shortl[i] >= longl[i] && shortl[i] >= longh[i]) &&
         (shortl[i + 1] < longl[i + 1] || shortl[i + 1] < longh[i + 1]) &&
         show_data)
        {
         drawArrow(1, i);
        }
      else
         drawArrow(11, i);
      if((shorth[i] <= longl[i] && shorth[i] <= longh[i] && shortl[i] <= longl[i] && shortl[i] <= longh[i]) &&
         (shorth[i + 1] > longl[i + 1] || shorth[i + 1] > longh[i + 1]) &&
         show_data)
        {
         drawArrow(-1, i);
        }
      else
         drawArrow(-11, i);
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input bool  drawArr = true; // Draw arrow
input color arrUpColor = clrBlue;
input color arrDoColor = clrRed;
input int arrUpCode = 233;
input int arrDoCode = 234;
input int arrWidth = 2;
input int Distance = 20; // Arrow distance from Hi/Lo
void drawArrow(int dir, int bar)
  {
   if(!drawArr)
      return;
   if(dir == 11)
     {
      ObjectDelete(0, "arrU" + (string)bar);
     }
   if(dir == -11)
     {
      ObjectDelete(0, "arrD" + (string)bar);
     }
   if(dir == -1)
     {
      ObjectCreate(0, "arrD" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), High[bar] + Distance * Point());
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_COLOR, arrDoColor);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_WIDTH, arrWidth);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_ARROWCODE, arrDoCode);
     }
   if(dir == 1)
     {
      ObjectCreate(0, "arrU" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), Low[bar] - Distance * Point());
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_COLOR, arrUpColor);
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_WIDTH, arrWidth);
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_ARROWCODE, arrUpCode);
     }
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 4
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo = 0)
  {
   r = bars - r - 1;
   switch(mode)
     {
      case ma_sma   :
         return(iSma(price, (int)length, r, bars, instanceNo));
      case ma_ema   :
         return(iEma(price, length, r, bars, instanceNo));
      case ma_smma  :
         return(iSmma(price, (int)length, r, bars, instanceNo));
      case ma_lwma  :
         return(iLwma(price, (int)length, r, bars, instanceNo));
      case ma_slwma :
         return(iSlwma(price, (int)length, r, bars, instanceNo));
      case ma_dsema :
         return(iDsema(price, length, r, bars, instanceNo));
      case ma_tema  :
         return(iTema(price, (int)length, r, bars, instanceNo));
      case ma_lsma  :
         return(iLinr(price, (int)length, r, bars, instanceNo));
      default       :
         return(price);
     }
  }

//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workSma, 0) != _bars)
      ArrayResize(workSma, _bars);
   workSma[r][instanceNo + 0] = price;
   double avg = price;
   int k = 1;
   for(; k < period && (r - k) >= 0; k++)
      avg += workSma[r - k][instanceNo + 0];
   return(avg / (double)k);
  }

//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workEma, 0) != _bars)
      ArrayResize(workEma, _bars);
   workEma[r][instanceNo] = price;
   if(r > 0 && period > 1)
      workEma[r][instanceNo] = workEma[r - 1][instanceNo] + (2.0 / (1.0 + period)) * (price - workEma[r - 1][instanceNo]);
   return(workEma[r][instanceNo]);
  }

//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workSmma, 0) != _bars)
      ArrayResize(workSmma, _bars);
   workSmma[r][instanceNo] = price;
   if(r > 1 && period > 1)
      workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
   return(workSmma[r][instanceNo]);
  }

//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workLwma, 0) != _bars)
      ArrayResize(workLwma, _bars);
   workLwma[r][instanceNo] = price;
   if(period <= 1)
      return(price);
   double sumw = period;
   double sum  = period * price;
   for(int k = 1; k < period && (r - k) >= 0; k++)
     {
      double weight = period - k;
      sumw  += weight;
      sum   += weight * workLwma[r - k][instanceNo];
     }
   return(sum / sumw);
  }

//
//
//


double workSlwma[][_maWorkBufferx2];
double iSlwma(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workSlwma, 0) != _bars)
      ArrayResize(workSlwma, _bars);
//
//
//
   int SqrtPeriod = (int)floor(sqrt(period));
   instanceNo *= 2;
   workSlwma[r][instanceNo] = price;
//
//
//
   double sumw = period;
   double sum  = period * price;
   for(int k = 1; k < period && (r - k) >= 0; k++)
     {
      double weight = period - k;
      sumw  += weight;
      sum   += weight * workSlwma[r - k][instanceNo];
     }
   workSlwma[r][instanceNo + 1] = (sum / sumw);
//
//
//
   sumw = SqrtPeriod;
   sum  = SqrtPeriod * workSlwma[r][instanceNo + 1];
   for(int k = 1; k < SqrtPeriod && (r - k) >= 0; k++)
     {
      double weight = SqrtPeriod - k;
      sumw += weight;
      sum  += weight * workSlwma[r - k][instanceNo + 1];
     }
   return(sum / sumw);
  }

//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iDsema(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workDsema, 0) != _bars)
      ArrayResize(workDsema, _bars);
   instanceNo *= 2;
//
//
//
   workDsema[r][_ema1 + instanceNo] = price;
   workDsema[r][_ema2 + instanceNo] = price;
   if(r > 0 && period > 1)
     {
      double alpha = 2.0 / (1.0 + sqrt(period));
      workDsema[r][_ema1 + instanceNo] = workDsema[r - 1][_ema1 + instanceNo] + alpha * (price                         - workDsema[r - 1][_ema1 + instanceNo]);
      workDsema[r][_ema2 + instanceNo] = workDsema[r - 1][_ema2 + instanceNo] + alpha * (workDsema[r][_ema1 + instanceNo] - workDsema[r - 1][_ema2 + instanceNo]);
     }
   return(workDsema[r][_ema2 + instanceNo]);
  }

//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iTema(double price, double period, int r, int bars, int instanceNo = 0)
  {
   if(ArrayRange(workTema, 0) != bars)
      ArrayResize(workTema, bars);
   instanceNo *= 3;
//
//
//
   workTema[r][_tema1 + instanceNo] = price;
   workTema[r][_tema2 + instanceNo] = price;
   workTema[r][_tema3 + instanceNo] = price;
   if(r > 0 && period > 1)
     {
      double alpha = 2.0 / (1.0 + period);
      workTema[r][_tema1 + instanceNo] = workTema[r - 1][_tema1 + instanceNo] + alpha * (price                         - workTema[r - 1][_tema1 + instanceNo]);
      workTema[r][_tema2 + instanceNo] = workTema[r - 1][_tema2 + instanceNo] + alpha * (workTema[r][_tema1 + instanceNo] - workTema[r - 1][_tema2 + instanceNo]);
      workTema[r][_tema3 + instanceNo] = workTema[r - 1][_tema3 + instanceNo] + alpha * (workTema[r][_tema2 + instanceNo] - workTema[r - 1][_tema3 + instanceNo]);
     }
   return(workTema[r][_tema3 + instanceNo] + 3.0 * (workTema[r][_tema1 + instanceNo] - workTema[r][_tema2 + instanceNo]));
  }

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, int period, int r, int bars, int instanceNo = 0)
  {
   if(ArrayRange(workLinr, 0) != bars)
      ArrayResize(workLinr, bars);
//
//
//
   period = MathMax(period, 1);
   workLinr[r][instanceNo] = price;
   if(r < period)
      return(price);
   double lwmw = period;
   double lwma = lwmw * price;
   double sma  = price;
   for(int k = 1; k < period && (r - k) >= 0; k++)
     {
      double weight = period - k;
      lwmw  += weight;
      lwma  += weight * workLinr[r - k][instanceNo];
      sma   +=        workLinr[r - k][instanceNo];
     }
   return(3.0 * lwma / lwmw - 2.0 * sma / period);
  }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------


string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int    iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if(tf == iTfTable[i])
         return(sTfTable[i]);
   return("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int timeFrameValue(int _tf)
  {
   int add  = (_tf >= 0) ? 0 : MathAbs(_tf);
   if(add != 0)
      _tf = _Period;
   int size = ArraySize(iTfTable);
   int i = 0;
   for(; i < size; i++)
      if(iTfTable[i] == _tf)
         break;
   if(i == size)
      return(_Period);
   return(iTfTable[(int)MathMin(i + add, size - 1)]);
  }
//+------------------------------------------------------------------+

bool alerted;
void checkAlert()
  {
  
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
       
   if(notificationsOn == 1 && !alerted)
     {
      if(ObjectFind(0, "arrU0") >= 0)
        {
         Notify(1);
         alerted = true;
        }
      if(ObjectFind(0, "arrD0") >= 0)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(ObjectFind(0, "arrU1") >= 0)
        {
         Notify(11);
        }
      if(ObjectFind(0, "arrD1") >= 0)
        {
         Notify(22);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsValue(double val)
  {
   return val > 0 && val != EMPTY_VALUE;
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
   string text = "Channels+arrow+alert: ";
   switch(type)
     {
      case 1:
         text += " Cross UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Cross DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Crossed UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Crossed DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
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
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 