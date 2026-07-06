// More information about this indicator can be found at:
// https://fxcodebase.com/code/posting.php?mode=reply&f=17&t=74425

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2023, Gehtsoft USA LLC"
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
#property indicator_label3 "Hour"
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_width3 1

//--- indicator buffers
double LineUp [];
double LineDn [];
double Hour [];

input int daysCalc = 100; // Days Back to make stadistic:
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
  SetIndexBuffer(2, Hour, INDICATOR_DATA);
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

  int n = 23;
  double maxValue = fmax(countMaxByHour[ArrayMaximum(countMaxByHour)], countMinByHour[ArrayMaximum(countMinByHour)]) * 1.10;
  IndicatorSetDouble(INDICATOR_MAXIMUM, maxValue);
  IndicatorSetDouble(INDICATOR_MINIMUM, -2);
  SetLevels(maxValue);

  for(int i = 72+vela_derecha; i >= vela_derecha && n>=0; i -= 3)
  {

    Hour[i] = maxValue;
    CreateLabel("lbl" + (string) fabs(n - 23), iTime(NULL, 0, i - 2), -1, (string) fabs(n - 23), clrSep);

    LineUp[i - 1] = countMaxByHour[n];
    LineDn[i - 2] = countMinByHour[n];
    n--;
  }

  if(newCandle.IsNewCandle())
  {
    for(int i = 73+vela_derecha; i >=0; i--){
      LineUp[i] = 0;
      LineDn[i] = 0;
      Hour[i] = 0;
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




int hoursBack = daysCalc * 24;
double countMaxByHour[24];
double countMinByHour[24];

int shiftDays [];
int maxHourPositions [];
int minHourPositions [];

void RefreshData()
{

  ArrayResize(shiftDays, daysCalc);
  ArrayResize(maxHourPositions, daysCalc);
  ArrayResize(minHourPositions, daysCalc);
  MqlDateTime dt;
  MqlDateTime dtNext;

  int days = 0;
  int n = 0;
  while(days < daysCalc)
  {
    TimeToStruct(iTime(NULL, PERIOD_H1, n), dt);
    TimeToStruct(iTime(NULL, PERIOD_H1, n + 1), dtNext);


    // cambiar a que cuente los días cuando cambie el día
    // v2.00
    
    int day = dt.day;
    int nextday = dtNext.day;
    if(day != nextday)
    {
      shiftDays[days] = n;
      days++;
    }
    n++;
  }

  for(int i = 0; i < ArraySize(shiftDays); i++)
  {

    MqlDateTime horaMax;
    MqlDateTime horaMin;
    TimeToStruct(iTime(NULL, PERIOD_H1, MaxPosDay(shiftDays[i])), horaMax);
    TimeToStruct(iTime(NULL, PERIOD_H1, MinPosDay(shiftDays[i])), horaMin);
    // Print(__FUNCTION__, " hora Max: ", horaMax.day, "-", horaMax.mon, "-", horaMax.year, "// hora: ", horaMax.hour);
    // Print(__FUNCTION__, " hora Min: ", horaMin.day, "-", horaMin.mon, "-", horaMin.year, "// hora: ", horaMin.hour);

    maxHourPositions[i] = horaMax.hour;
    minHourPositions[i] = horaMin.hour;
  }

  for(int i = 0; i < ArraySize(countMaxByHour); i++)
  {

    double countmax = 0;
    double countmin = 0;

    for(int p = 0; p < ArraySize(maxHourPositions); p++) {
      if(maxHourPositions[p] == i)
        countmax++;
    }
    for(int p = 0; p < ArraySize(minHourPositions); p++) {
      if(minHourPositions[p] == i)
        countmin++;
    }
    countMaxByHour[i] = countmax;
    countMinByHour[i] = countmin;
  }

  for(int i = 0; i < ArraySize(countMaxByHour); i++) {

    countMaxByHour[i] *= 100;
    countMinByHour[i] *= 100;
    countMaxByHour[i] /= daysCalc;
    countMinByHour[i] /= daysCalc;

    //   Print("hora: ", i, " Maximos: ", countMaxByHour[i]);
    //   Print("hora: ", i, " Minimos: ", countMinByHour[i]);
  }



}


int MaxPosDay(int iniPos)
{
  return iHighest(Symbol(), PERIOD_H1, MODE_HIGH, 24, iniPos);
}
int MinPosDay(int iniPos)
{
  return iLowest(Symbol(), PERIOD_H1, MODE_LOW, 24, iniPos);
}


bool haveSignalUp(int i)
{
  // TODO: signal up
  return iOpen(NULL, 0, i) > iClose(NULL, 0, i + 1);
}

bool haveSignalDown(int i)
{
  // TODO: signal down
  return iOpen(NULL, 0, i) < iClose(NULL, 0, i + 1);
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