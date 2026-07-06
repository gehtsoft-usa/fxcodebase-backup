// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=17&t=74425

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Bar Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Bar Down"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Day"
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_width3 1

//--- indicator buffers
double LineUp [];
double LineDn [];
double Day [];

input int weeksBack = 10; // Weeks Back to make stadistic:
input int vela_derecha = 3; // Candles in the rigth side of histogram
// ------------------------------------------------------------------
string       T1 = "== Notifications ==";  // ————————————
bool         notifications = false;                  // Notifications On?
bool         desktop_notifications = false;                  // Desktop MT4 Notifications
bool         email_notifications = false;                  // Email Notifications
bool         push_notifications = false;                  // Push Mobile Notifications
input string T2 = "== Set Lines ==";      // ————————————
input bool   LinesOn = true;                   // Line On?
input color  LineUpClr = clrBlue;                // Line Up Color:
input color  LineDnClr = clrRed;                 // Line Down Color:

input bool   SepOn = true;       // Separators On?
input color clrSep = clrDimGray; // Separator Linea color
// ------------------------------------------------------------------

class CNewCandle
{
  private:
  int    _initialCandles;
  string _symbol;
  int    _tf;

  public:
  CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol = Symbol();
    _tf = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if(_currentCandles > _initialCandles)
    {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, LineUp, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 5, LineUpClr);
  SetIndexBuffer(1, LineDn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 5, LineDnClr);
  SetIndexBuffer(2, Day, INDICATOR_DATA);
  SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_DOT, 1, clrSep);

  if(!LinesOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }
  if(!SepOn)
    SetIndexStyle(2, DRAW_NONE);

  RefreshData();

  // ---
  IndicatorSetInteger(INDICATOR_LEVELS, 3);
  IndicatorSetInteger(INDICATOR_LEVELCOLOR, clrSep);
  IndicatorSetInteger(INDICATOR_LEVELSTYLE, STYLE_DOT);

  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
  ObjectsDeleteAll(0, "lbl");
}
// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{

  int n = 6;
  double maxValue = fmax(countMaxByDay[ArrayMaximum(countMaxByDay)], countMinByDay[ArrayMaximum(countMinByDay)]) * 1.10;
  IndicatorSetDouble(INDICATOR_MAXIMUM, maxValue);
  IndicatorSetDouble(INDICATOR_MINIMUM, -5);
  SetLevels(maxValue);

  for(int i = 21+vela_derecha; i >= vela_derecha && n>=0; i -= 3)
  {
    Day[i] = maxValue;  

    CreateLabel("lbl" + (string) fabs(n - 6), iTime(NULL, 0, i - 2), -1, dayName(fabs(n - 6)), clrSep);

    
    LineUp[i - 1] = countMaxByDay[n];
    LineDn[i - 2] = countMinByDay[n];
    n--;
  }

  if(newCandle.IsNewCandle())
  {
    for(int i = 22+vela_derecha; i >=0; i--){
      LineUp[i] = 0;
      LineDn[i] = 0;
      Day[i] = 0;
    }
    ObjectsDeleteAll(0, "lbl");
    RefreshData();
  }

  return (rates_total);
}
// ------------------------------------------------------------------
void SetLevels(double max)
{
  double gap = MathCeil(max / 4);
  double lvl = 1;
  IndicatorSetDouble(INDICATOR_LEVELVALUE, lvl, gap * lvl); lvl += 1;
  IndicatorSetDouble(INDICATOR_LEVELVALUE, lvl, gap * lvl); lvl += 1;
  IndicatorSetDouble(INDICATOR_LEVELVALUE, lvl, gap * lvl); lvl += 1;

  // IndicatorSetDouble(INDICATOR_LEVELVALUE, lvl, lvlGap * lvl); lvl += 1;
  // IndicatorSetDouble(INDICATOR_LEVELVALUE, lvl, lvlGap * lvl); lvl += 1;
  // IndicatorSetDouble(INDICATOR_LEVELVALUE, lvl, lvlGap * lvl); lvl += 1;
}





// ------------------------------------------------------------------



#define byWeek
#ifdef byWeek

int daysBack = weeksBack*7;
double countMaxByDay[7];
double countMinByDay[7];

int shiftWeeks [];
int maxDayPositions []; // hora del precio max del día
int minDayPositions [];

void RefreshData()
{

  ArrayResize(shiftWeeks, weeksBack);
  ArrayResize(maxDayPositions, weeksBack);
  ArrayResize(minDayPositions, weeksBack);
  MqlDateTime dt;
  MqlDateTime dtNext;

  int weeks = 0;
  int n = 0;
  
  while(weeks < weeksBack)
  {
    TimeToStruct(iTime(NULL, PERIOD_D1, n), dt);
    TimeToStruct(iTime(NULL, PERIOD_D1, n + 1), dtNext);

    int week = dt.day_of_year/7;
    int nextWeek = dtNext.day_of_year/7;
    if(week != nextWeek)
    {
      shiftWeeks[weeks] = n;
      weeks++;
    }
    n++;
  }

  for(int i = 0; i < ArraySize(shiftWeeks); i++)
  {
    MqlDateTime tmMax;
    MqlDateTime tmMin;
    TimeToStruct(iTime(NULL, PERIOD_D1, MaxPosWeek(shiftWeeks[i])), tmMax);
    TimeToStruct(iTime(NULL, PERIOD_D1, MinPosWeek(shiftWeeks[i])), tmMin);

    // Print(__FUNCTION__, " hora Max: ", tmMax.day, "-", tmMax.mon, "-", tmMax.year, "// hora: ", tmMax.hour);
    // Print(__FUNCTION__, " hora Min: ", tmMin.day, "-", tmMin.mon, "-", tmMin.year, "// hora: ", tmMin.hour);

    maxDayPositions[i] = tmMax.day_of_week;
    minDayPositions[i] = tmMin.day_of_week;
  }

  for(int i = 0; i < ArraySize(countMaxByDay); i++)
  {

    double countmax = 0;
    double countmin = 0;

    for(int p = 0; p < ArraySize(maxDayPositions); p++) {
      if(maxDayPositions[p] == i)
        countmax++;
    }
    for(int p = 0; p < ArraySize(minDayPositions); p++) {
      if(minDayPositions[p] == i)
        countmin++;
    }
    countMaxByDay[i] = countmax;
    countMinByDay[i] = countmin;
  }

  for(int i = 0; i < ArraySize(countMaxByDay); i++) {

    countMaxByDay[i] *= 100;
    countMinByDay[i] *= 100;
    countMaxByDay[i] /= weeksBack;
    countMinByDay[i] /= weeksBack;

    //   Print("hora: ", i, " Maximos: ", countMaxByDay[i]);
    //   Print("hora: ", i, " Minimos: ", countMinByDay[i]);
  }
}


int MaxPosWeek(int iniPos)
{
  return iHighest(Symbol(), PERIOD_D1, MODE_HIGH, 7, iniPos);
}
int MinPosWeek(int iniPos)
{
  return iLowest(Symbol(), PERIOD_D1, MODE_LOW, 7, iniPos);
}

#endif



string dayName(int dayNr)
{
  if(dayNr == 0)return "sun";
  if(dayNr == 1)return "mon";
  if(dayNr == 2)return "tue";
  if(dayNr == 3)return "wed";
  if(dayNr == 4)return "thu";
  if(dayNr == 5)return "fri";
  
  return "";
}


void CreateLabel(string nm, datetime tm, double pr, string tx, color cl)
{
  ObjectCreate(0, nm, OBJ_TEXT, 1, tm, pr);
  ObjectSetString(0, nm, OBJPROP_TEXT, tx);
  // ObjectSetString(0, nm, OBJPROP_FONT, "Arial Black");
  ObjectSetString(0, nm, OBJPROP_FONT, "Arial");
  ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 10);
  ObjectSetInteger(0, nm, OBJPROP_COLOR, cl);

  // ENUM_ANCHOR_POINT anchor = cl == Green ? ANCHOR_LOWER : ANCHOR_UPPER;
  ENUM_ANCHOR_POINT anchor = ANCHOR_RIGHT;
  ObjectSetInteger(0, nm, OBJPROP_ANCHOR, anchor);

}


void Notifications(int type)
{
  string text = "";
  if(type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

  text += " ";

  if(!notifications)
    return;
  if(desktop_notifications)
    Alert(text);
  if(push_notifications)
    SendNotification(text);
  if(email_notifications)
    SendMail("MetaTrader Notification", text);
}

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

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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