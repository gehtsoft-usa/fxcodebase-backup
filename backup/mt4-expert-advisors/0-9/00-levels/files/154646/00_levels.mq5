// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74681

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
#property link "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window

input int   GridSpace   = 100;
input color Line_Colour = RoyalBlue;
input int   Line_Style  = 0;
input int   Line_Width  = 1;
input bool  print_info = false; // Print trend data

double      Gd_100      = 0.0;
double      Gd_108      = 0.0;
bool        Gi_116      = false;
double      Gd_120;
double      Gd_128 = 1.0;

int Digits = _Digits;

void OnInit() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  ObjectsDeleteAll(0, "Snorm Grid");
}

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
  double sprace_btween_levels;
  double round_price;
  string level_name;
  string com = "";

  if (!Gi_116) {
    if (Digits() % 2 == 1) {
      Gd_128 = 100;
      Gd_120 = 10.0 * Point();
    } else {
      Gd_128 = 1000;
      Gd_120 = 100.0 * Point();
    }
    sprace_btween_levels = GridSpace * Gd_120;
    Gd_108               = 0;
    Gd_100               = iClose(Symbol(), Period(), 0);
    Gd_100               = MathRound(Gd_100 * Gd_128) / Gd_128 + 5.0 * sprace_btween_levels;
    Gd_108               = MathRound(Gd_108 * Gd_128) / Gd_128 - 5.0 * sprace_btween_levels;
    
    StringConcatenate(com, (string)GridSpace, " ", (string)sprace_btween_levels, " ", (string)Gd_120, " ", (string)Digits); 
  
    round_price = Gd_108;
    while (round_price <= Gd_100) {
      round_price += sprace_btween_levels;
      level_name = "Snorm Grid" + DoubleToString(GridSpace, 0) + " " + DoubleToString(round_price, Digits);
      Hline(round_price, level_name);
    }
    Gi_116 = true;
  }

  // ------

  // ir hacia atrás vela por vela (con los close)
  // si el close actual es < a nivel y el close anterior > nivel ==> cut up
  // close actual > a nivel y close anterior < nivel ==> cut dn
  
  int    count  = 4;
  string prefix = "Snorm Grid";
  double levels[];

  for (int n = ObjectsTotal(0); n >= 0; n--) {
    string _name = ObjectName(0, n);
    if (StringSubstr(_name, 0, StringLen(prefix)) == prefix) {
      double price = ObjectGetDouble(0, _name, OBJPROP_PRICE);

      if (price > 0) {
        int t = ArraySize(levels);
        if (ArrayResize(levels, t + 1)) {
          levels[t] = price;
        }
      }
    }
  }

  int    pattern[5];
  int    pos       = 0;
  double lastLevel = 0;

  for (int b = 0; b < 500; b++) {
    double cl = iClose(NULL, 0, b);
    double op = iOpen(NULL, 0, b);
    double hi = iHigh(NULL,0,b);
    double lo = iLow(NULL,0,b);

    if (pos == ArraySize(pattern) - 1) break;

    for (int l = 0; l < ArraySize(levels); l++) {
      double level = levels[l];

      if (level != lastLevel) {
        
        if ((cl > op && cl > level && op < level)||(lo<level && cl>level)) {
          pattern[pos] = 1;
          pos++;
            if(print_info)Print("CutUp: ", level, " candle ", b);
          lastLevel = level;
          break;
        }
        
        if ((cl < op && cl < level && op > level)||(hi>level && cl<level)) {
          pattern[pos] = 0;
          pos++;
            if(print_info)Print("CutDN: ", level, " candle ", b);
          lastLevel = level;
          break;
        }
      }
    }
  }


string trend = "";
if(pattern[0] == 1 && pattern[1] == 1) trend = "UP";
if(pattern[0] == 0 && pattern[1] == 0) trend = "DN";
if(pattern[0] == 1 && pattern[1] == 0 && pattern[2] == 0) trend = "DN pullback";
if(pattern[0] == 0 && pattern[1] == 1 && pattern[2] == 1) trend = "UP pullback";

if(pattern[0] == 0 && pattern[1] == 1 && pattern[2] == 0 && pattern[3] == 0) trend = "DN pullback";
if(pattern[0] == 1 && pattern[1] == 0 && pattern[2] == 1 && pattern[3] == 1) trend = "UP pullback";
    
if(print_info)Print(trend);

  com += " // TREND: " + trend;
  Comment(com);

  return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Hline(double A_price_0, string A_name_8)
{
  ObjectCreate(0, A_name_8, OBJ_HLINE, 0, 0, A_price_0);
  ObjectSetInteger(0, A_name_8, OBJPROP_STYLE, Line_Style);
  ObjectSetInteger(0, A_name_8, OBJPROP_COLOR, Line_Colour);
  ObjectSetInteger(0, A_name_8, OBJPROP_WIDTH, Line_Width);
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
