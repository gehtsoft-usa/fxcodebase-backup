// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=27&p=153278#p153278

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property indicator_chart_window

#property indicator_buffers 17
#property indicator_plots 17

// NOTE: Inputs
// ------------------------------------------------------------------
//---- input parameters
int    Length    = 2;     // Bollinger Bands Period
input int    Deviation = 4;     // Deviation 
input double MoneyRisk = 1.00;  // Offset Factor
int    Signal    = 2;     // Display signals mode: 1-Signals & Stops; 0-only Stops; 2-only Signals;
int    Line      = 0;     // Display line mode: 0-no,1-yes
int    Nbars     = 1000;

int    inpPeriod                = 10;                     // Indicator Periods
input string T0                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrGreen;                // Arrow Up Color:
input color  ArrowDnClr            = clrGold;                 // Arrow Down Color:
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

input string             button_note1          = "------------------------------";
input ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER; // chart btn_corner for anchoring
input string             btn_text              = "Alzig";
input string             btn_Font              = "Impact";
input int                btn_FontSize          = 10;                             //btn__font size
input color              btn_text_color        = clrWhite;
input color              btn_background_color  = clrDarkRed;
input color              btn_border_color      = clrBlack;
input int                button_x              = 240;                                     //btn__x
input int                button_y              = 20;                                     //btn__y
input int                btn_Width             = 60;                                 //btn__width
input int                btn_Height            = 20;                                //btn__height
input string             button_note2          = "------------------------------";

bool show_data = true;
string IndicatorName, IndicatorObjPrefix;
string buttonId;
bool recalc = true;

// NOTE: Buffers
//--- indicator buffers
double smax[];
double smin[];
double bsmax[];
double bsmin[];

double UpTrendLine[];
double DownTrendLine[];

double UpTrendBuffer[];
double DownTrendBuffer[];
double UpTrendSignal[];
double DownTrendSignal[];

bool TurnedUp = false;
bool TurnedDown = false;


// NOTE: TRENDLORD
// ------------------------------------------------------------------

#property indicator_label13  "ColorCandles" 
#property  indicator_type13   DRAW_COLOR_CANDLES 
#property indicator_color13  RoyalBlue, Crimson
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1

//--- indicator buffers
double line[];

//--- búfers indicadores 
double    buf_open[]; 
double    buf_high[]; 
double    buf_low[]; 
double    buf_close[]; 
double    buf_color[]; 
double    buf_ma[]; 
double    Array1[]; 


input int                maPeriod       = 12;                            // Period
ENUM_MA_METHOD     maMethod       = MODE_SMMA;                     // Method
input ENUM_APPLIED_PRICE maAppliedPrice = PRICE_CLOSE;                   // Applied Price

int hma; // handle MA
int SqLength;


class CNewCandle
{
 private:
  int             _initialCandles;
  string          _symbol;
  ENUM_TIMEFRAMES _tf;

 public:
  CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles) {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

int bb;

string GenerateIndicatorName(const string target)
   {
    string name = target;
    int try
            = 2;
    while(ChartWindowFind(0, name) != -1)
       {
        name = target + " #" + IntegerToString(try++);
       }
    return name;
   }

void handleButtonClicks()
   {
    if(ObjectGetInteger(0, buttonId, OBJPROP_STATE))
       {
        ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
        show_data = !show_data;
        GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
        recalc = true;
        if(!show_data)
    {
      ArrayInitialize(UpTrendBuffer, 0);
      ArrayInitialize(DownTrendBuffer, 0);
      ArrayInitialize(UpTrendSignal, 0);
      ArrayInitialize(DownTrendSignal, 0);
      ArrayInitialize(buf_close, EMPTY_VALUE);
      ArrayInitialize(buf_open, EMPTY_VALUE);
      ArrayInitialize(buf_high, EMPTY_VALUE);
      ArrayInitialize(buf_low, EMPTY_VALUE);
      ArrayInitialize(UpTrendLine, 0);
      ArrayInitialize(DownTrendLine, 0);
    }
        start(0);
        ChartRedraw();
       }
   }

void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
   {
    ObjectDelete(0, buttonID);
    ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
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

// ------------------------------------------------------------------
void OnInit()
{
  IndicatorName = GenerateIndicatorName(btn_text);
    IndicatorObjPrefix = "__" + IndicatorName + "__";
IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    double val;
    if(GlobalVariableGet(IndicatorName + "_visibility", val))
        show_data = val != 0;
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
    buttonId = IndicatorObjPrefix + "CloseButton";
    createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
    ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
    ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
  //--- indicator short name
  string short_name = "AIzig + TrendLord MT5";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, 2);

  SetIndexBuffer(0, UpTrendBuffer);
  SetIndexBuffer(1, DownTrendBuffer);
  SetIndexBuffer(2, UpTrendSignal);
  SetIndexBuffer(3, DownTrendSignal);
  SetIndexBuffer(4, UpTrendLine);
  SetIndexBuffer(5, DownTrendLine);

  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Length);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Length);

  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
  PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
  PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
  PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);

  PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
  PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);

  PlotIndexSetInteger(2, PLOT_ARROW, 233);
  PlotIndexSetInteger(3, PLOT_ARROW, 234);

  PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);
  PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);


  SetIndexBuffer(6, smax, INDICATOR_CALCULATIONS);
  SetIndexBuffer(7, smin, INDICATOR_CALCULATIONS);
  SetIndexBuffer(8, bsmax, INDICATOR_CALCULATIONS);
  SetIndexBuffer(9, bsmin, INDICATOR_CALCULATIONS);


// NOTE: TrendLord Init 
// ------------------------------------------------------------------
	SqLength = (int)MathSqrt(maPeriod);
  //--- indicator buffers mapping 
	 SetIndexBuffer(10,buf_ma,INDICATOR_DATA); 
   PlotIndexSetInteger(10, PLOT_DRAW_TYPE, DRAW_NONE);
	 
	 SetIndexBuffer(11,Array1,INDICATOR_DATA); 
   PlotIndexSetInteger(11, PLOT_DRAW_TYPE, DRAW_NONE);

   SetIndexBuffer(12,buf_open,INDICATOR_DATA); 
   SetIndexBuffer(13,buf_high,INDICATOR_DATA); 
   SetIndexBuffer(14,buf_low,INDICATOR_DATA); 
   SetIndexBuffer(15,buf_close,INDICATOR_DATA); 
   SetIndexBuffer(16,buf_color,INDICATOR_COLOR_INDEX); 

  //--- valor vacío 
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,0);

   hma = iMA(NULL, 0, maPeriod, 0, maMethod, maAppliedPrice);


  if (!ArrowsOn) {
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  bb = iBands(NULL, 0, Length, 0, Deviation, PRICE_CLOSE);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
  if (rates_total < Length) return (0);

  start(prev_calculated);
  return (rates_total);
}
void OnDeinit(const int reason)
   {
    ObjectsDeleteAll(0, IndicatorObjPrefix, -1, -1);
    ObjectsDeleteAll(0, 0, OBJ_LABEL);
   }
// ------------------------------------------------------------------
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
   {
    handleButtonClicks();
   }

void start(int prev_calculated)
{     
  if(!show_data)
    {
      ArrayInitialize(UpTrendBuffer, 0);
      ArrayInitialize(DownTrendBuffer, 0);
      ArrayInitialize(UpTrendSignal, 0);
      ArrayInitialize(DownTrendSignal, 0);
      ArrayInitialize(buf_close, EMPTY_VALUE);
      ArrayInitialize(buf_open, EMPTY_VALUE);
      ArrayInitialize(buf_high, EMPTY_VALUE);
      ArrayInitialize(buf_low, EMPTY_VALUE);
      ArrayInitialize(UpTrendLine, 0);
      ArrayInitialize(DownTrendLine, 0);
      return;
    }
      handleButtonClicks();
    recalc = false;
    
  int start=0, trend=0;
  double Close[];
  ArrayResize(Close, iBars(Symbol(), Period())+1);
 
    if (prev_calculated > 1) start = prev_calculated - 1; else { start = Length + 1; }


  for (int i = 0; i < iBars(Symbol(),Period()) && !IsStopped(); i++) {
    Close[i] = iClose(Symbol(), Period(), i);
  }
 ArraySetAsSeries(Close, true);
  for (int i = start; i < iBars(Symbol(),Period()) && !IsStopped(); i++) {
    
	// NOTE: trendLord calculation	
	// ------------------------------------------------------------------
		buf_ma[i] = SmoothedMA(i, maPeriod, buf_ma[i - 1], Close);
    Array1[i] = SmoothedMA(i, SqLength, Array1[i - 1], buf_ma);

		buf_open[i]  = SmoothedMA(i, maPeriod, buf_ma[i - 1], Close);
    buf_high[i]  = buf_open[i];
    buf_low[i]   = SmoothedMA(i, SqLength, Array1[i - 1], buf_ma);
    buf_close[i] = buf_low[i];

    // NOTE: set color
    if (buf_open[i] > buf_close[i]) { buf_color[i] = 0;
    } else { buf_color[i] = 1; }
		
	// ------------------------------------------------------------------


		UpTrendBuffer[i]   = 0;
    DownTrendBuffer[i] = 0;
    UpTrendSignal[i]   = 0;
    DownTrendSignal[i] = 0;
    UpTrendLine[i]     = EMPTY_VALUE;
    DownTrendLine[i]   = EMPTY_VALUE;

    smax[i] = index(bb, 1, i);
    smin[i] = index(bb, 2, i);

    if (Close[i] > smax[i - 1]) trend = 1;
    if (Close[i] < smin[i - 1]) trend = -1;

    if (trend > 0 && smin[i] < smin[i - 1]) smin[i] = smin[i - 1];
    if (trend < 0 && smax[i] > smax[i - 1]) smax[i] = smax[i - 1];

    bsmax[i] = smax[i] + 0.5 * (MoneyRisk - 1) * (smax[i] - smin[i]);
    bsmin[i] = smin[i] - 0.5 * (MoneyRisk - 1) * (smax[i] - smin[i]);

    if (trend > 0 && bsmin[i] < bsmin[i - 1]) bsmin[i] = bsmin[i - 1];
    if (trend < 0 && bsmax[i] > bsmax[i - 1]) bsmax[i] = bsmax[i - 1];

		
    if (trend > 0) {
      if (Signal > 0 && UpTrendBuffer[i - 1] == -1.0) {
        if(buf_color[i]==0)UpTrendSignal[i] = bsmin[i];
        UpTrendBuffer[i] = bsmin[i];
        if (Line > 0) UpTrendLine[i] = bsmin[i];

        if (newCandle.IsNewCandle() && !TurnedUp) {
          Notifications(0);
          TurnedUp   = true;
          TurnedDown = false;
        }

      } else {
        UpTrendBuffer[i] = bsmin[i];
        if (Line > 0) UpTrendLine[i] = bsmin[i];
        UpTrendSignal[i] = -1;
      }
      if (Signal == 2) UpTrendBuffer[i] = 0;
      
			DownTrendSignal[i] = -1;
      DownTrendBuffer[i] = -1.0;
      DownTrendLine[i]   = EMPTY_VALUE;
    }

		
    if (trend < 0) {
      if (Signal > 0 && DownTrendBuffer[i - 1] == -1.0) {
        if(buf_color[i]==1)DownTrendSignal[i] = bsmax[i];
        DownTrendBuffer[i] = bsmax[i];
        if (Line > 0) DownTrendLine[i] = bsmax[i];

        if (newCandle.IsNewCandle() && !TurnedDown) {
          Notifications(0);
          TurnedUp   = false;
          TurnedDown = true;
        }

      } else {
        DownTrendBuffer[i] = bsmax[i];
        if (Line > 0) DownTrendLine[i] = bsmax[i];
        	DownTrendSignal[i] = -1;
      }
      if (Signal == 2)
        DownTrendBuffer[i] = 0;

      UpTrendSignal[i] = -1;
      UpTrendBuffer[i] = -1.0;
      UpTrendLine[i]   = EMPTY_VALUE;
    }
  }
}

double index(int handle, int buffer, int shift)
{
  int    bars   = iBars(NULL, 0);
  int    _shift = bars - shift -1;
  double value[1];
  int    qnt = CopyBuffer(handle, buffer, _shift, 1, value);

  if (qnt > 0) { return value[0]; }
  return -1;
}

void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

  text += " ";

  if (!notifications)
    return;
  if (desktop_notifications)
    Alert(text);
  if (push_notifications)
    SendNotification(text);
  if (email_notifications)
    SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
  switch (lPeriod) {
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

//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
double SmoothedMA(const int position,const int period,const double prev_value,const double &price[])
  {
   double result=0.0;
//--- check period
   if(period>0 && period<=(position+1))
     {
      if(position==period-1)
        {
         for(int i=0; i<period; i++)
            result+=price[position-i];

         result/=period;
        }

      result=(prev_value*(period-1)+price[position])/period;
     }

   return(result);
  }


// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=27&p=153278#p153278

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+
