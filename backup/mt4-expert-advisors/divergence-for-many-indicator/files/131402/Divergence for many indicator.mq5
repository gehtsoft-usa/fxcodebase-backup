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
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 0

input int lb = 5; // Left Bars
input int rb = 5; // Right Bars
input bool shownum = true; // Show Divergence Number
input bool showindis = false; // Show Indicator Names
input bool showpivot = false; // Show Pivot Points
input bool calcmacd = true; // MACD
input bool calcmacda = true; // MACD Histogram
input bool calcrsi = true; // RSI
input bool calcstoc = true; // Stochastic
input bool calccci = true; // CCI
input bool calcmom = true; // Momentum
input bool calcobv = true; // OBV
input bool calccmf = true; // Chaikin Money Flow

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

double closeChange[], Cmfm[], lastHigh[], obv[], lastLow[], Cmfv[];

void OnInit()
{
   IndicatorName = GenerateIndicatorName("Divergence for many indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, closeChange, INDICATOR_CALCULATIONS);
   SetIndexBuffer(1, Cmfm, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, lastHigh, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, obv, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, lastLow, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, Cmfv, INDICATOR_CALCULATIONS);
   rsi = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   macd = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
   momentum = iMomentum(_Symbol, _Period, 10, PRICE_CLOSE);
   cci = iCCI(_Symbol, _Period, 10, PRICE_CLOSE);
   stoch = iStochastic(_Symbol, _Period, 14, 3, 3, MODE_SMA, STO_CLOSECLOSE);
}

int rsi;
int macd;
int momentum;
int cci;
int stoch;

void OnDeinit(const int reason)
{
   IndicatorRelease(rsi);
   IndicatorRelease(macd);
   IndicatorRelease(momentum);
   IndicatorRelease(cci);
   IndicatorRelease(stoch);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

bool Isemptyh(int i, int oldI, const double& high[], const double& close[])
{
   int newtopIndex = iHighest(_Symbol, _Period, MODE_HIGH, lb, oldI);
   double newtop = iHigh(_Symbol, _Period, newtopIndex);
   int lastHighI = (int)lastHigh[i];
   if (lastHighI < 0)
   {
      return false;
   }
   if (newtop > high[lastHighI])
   {
      double diff = (newtop - high[lastHighI]) / (i - lastHigh[i]);
      double hline = newtop - diff;
      for (int x = 1; x < i - lastHigh[i] - 1; ++x)
      {
         if (close[i - x] > hline)
         {
            return false;
         }
         hline = hline - diff;
      }
      return true;
   }
   return false;
}

bool Isemptyl(int i, int oldI, const double& low[], const double& close[])
{
   int newtopIndex = iLowest(_Symbol, _Period, MODE_LOW, lb, oldI);
   double newtop = iLow(_Symbol, _Period, newtopIndex);
   int lastLowI = (int)lastLow[i];
   if (lastLowI < 0)
   {
      return false;
   }
   if (newtop < low[lastLowI])
   {
      double diff = (newtop - low[lastLowI]) / (i - lastLow[i]);
      double hline = newtop - diff;
      for (int x = 1; x < (i - lastLow[i]) - 1; ++x)
      {
         if (close[i - x] < hline)
         {
            return false;
         }
         hline = hline - diff;
      }
      return true;
   }
   return false;
}

void ProcessUp(int i, int oldI, int rates_total, const double& open[], const double& high[], const double& low[], const double& close[], const datetime& time[], const long& tick_volume[])
{
   int highestIndex = rates_total - 1 - iHighest(_Symbol, _Period, MODE_HIGH, lb + rb, oldI - rb);
   if (highestIndex == i)
   {
      lastHigh[i] = i - lb;
   }
   else
   {
      lastHigh[i] = lastHigh[i - 1];
   }
   int lastHighI = (int)lastHigh[i];
   int negdivergence = 0;
   string negdivtxt = "";
   if (Isemptyh(i, oldI, high, close))
   {
      if (calcrsi && rsi(rates_total - 1 - lastHighI) > rsi(rates_total - 1 - i))
      {
         negdivergence = negdivergence + 1;
         negdivtxt = "RSI ";
      }
      if (calcmacd && macdMacd(rates_total - 1 - lastHighI) > macdMacd(rates_total - 1 - i))
      {
         negdivergence = negdivergence + 1;
         negdivtxt = negdivtxt + "MACD ";
      }
      if (calcmacda && deltamacd(rates_total - 1 - lastHighI) > deltamacd(rates_total - 1 - i))
      {
         negdivergence = negdivergence + 1;
         negdivtxt = negdivtxt + "MACD Hist ";
      }
      if (calcmom && moment(rates_total - 1 - lastHighI) > moment(rates_total - 1 - i))
      {
         negdivergence = negdivergence + 1;
         negdivtxt = negdivtxt + "Momentum ";
      }
      if (calccci && cci(rates_total - 1 - lastHighI) > cci(rates_total - 1 - i))
      {
         negdivergence = negdivergence + 1;
         negdivtxt = negdivtxt + "CCI ";
      }
      if (calcobv && obv[lastHighI] > obv[i])
      {
         negdivergence = negdivergence + 1;
         negdivtxt = negdivtxt + "OBV ";
      }
      if (calcstoc && stk(rates_total - 1 - lastHighI) > stk(rates_total - 1 - i))
      {
         negdivergence = negdivergence + 1;
         negdivtxt = negdivtxt + "Stoch ";
      }
      if (calccmf && cmf(lastHighI, tick_volume) > cmf(i, tick_volume))
      {
         negdivergence = negdivergence + 1;
         negdivtxt = negdivtxt + "CMF ";
      }
   }
   if (negdivergence > 0)
   {
      ResetLastError();
      string trend = IndicatorObjPrefix + TimeToString(time[i]) + "uptrendidValue";
      if (ObjectFind(0, trend) == -1)
      {
         if (!ObjectCreate(0, trend, OBJ_TREND, 0, time[lastHighI], high[lastHighI], time[i], high[i]))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetInteger(0, trend, OBJPROP_COLOR, Red);
         ObjectSetInteger(0, trend, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, trend, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, trend, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, trend, OBJPROP_PRICE, 0, high[lastHighI]);
      ObjectSetDouble(0, trend, OBJPROP_PRICE, 1, high[i]);
      ObjectSetInteger(0, trend, OBJPROP_TIME, 0, time[lastHighI]);
      ObjectSetInteger(0, trend, OBJPROP_TIME, 1, time[i]);
      if (shownum || showindis)
      {
         string txt = showindis ? negdivtxt : "";
         txt = txt + (shownum ? IntegerToString(negdivergence) : "");
         ResetLastError();
         string id = IndicatorObjPrefix + TimeToString(time[i]) + "upLabelidValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TEXT, 0, time[i], high[i]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               return ;
            }
            ObjectSetString(0, id, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 10);
            ObjectSetInteger(0, id, OBJPROP_COLOR, White);
            ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LOWER);
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, time[i]);
         ObjectSetDouble(0, id, OBJPROP_PRICE, high[i]);
         ObjectSetString(0, id, OBJPROP_TEXT, txt);
      }
   }
}

void ProcessDown(int i, int oldI, int rates_total, const double& open[], const double& high[], const double& low[], const double& close[], const datetime& time[], const long& tick_volume[])
{
   int lowestIndex = rates_total - 1 - iLowest(_Symbol, _Period, MODE_LOW, lb + rb, oldI - rb);
   if (lowestIndex == i)
   {
      lastLow[i] = i - lb;
   }
   else
   {
      lastLow[i] = lastLow[i - 1];
   }
   int posdivergence = 0;
   string posdivtxt = "";
   int lastLowI = (int)lastLow[i];
   if (Isemptyl(i, oldI, low, close))
   {
      if (calcrsi && rsi(rates_total - 1 - lastLowI) < rsi(rates_total - 1 - i))
      {
         posdivergence = 1;
         posdivtxt = "RSI ";
      }
      if (calcmacd && macdMacd(rates_total - 1 - lastLowI) < macdMacd(rates_total - 1 - i))
      {
         posdivergence = posdivergence + 1;
         posdivtxt = posdivtxt + "MACD ";
      }
      if (calcmacda && deltamacd(rates_total - 1 - lastLowI) < deltamacd(rates_total - 1 - i))
      {
         posdivergence = posdivergence + 1;
         posdivtxt = posdivtxt + "MACD Hist ";
      }
      if (calcmom && moment(rates_total - 1 - lastLowI) < moment(rates_total - 1 - i))
      {
         posdivergence = posdivergence + 1;
         posdivtxt = posdivtxt + "Momentum ";
      }
      if (calccci && cci(rates_total - 1 - lastLowI) < cci(rates_total - 1 - i))
      {
         posdivergence = posdivergence + 1;
         posdivtxt = posdivtxt + "CCI ";
      }
      if (calcobv && obv[lastLowI] < obv[i])
      {
         posdivergence = posdivergence + 1;
         posdivtxt = posdivtxt + "OBV ";
      }
      if (calcstoc && stk(rates_total - 1 - lastLowI) < stk(rates_total - 1 - i))
      {
         posdivergence = posdivergence + 1;
         posdivtxt = posdivtxt + "Stoch ";
      }
      if (calccmf && cmf(lastLowI, tick_volume) < cmf(i, tick_volume))
      {
         posdivergence = posdivergence + 1;
         posdivtxt = posdivtxt + "CMF ";
      }
   }
   if (posdivergence > 0)
   {
      ResetLastError();
      string trend = IndicatorObjPrefix + TimeToString(time[i]) + "dnidValue";
      if (ObjectFind(0, trend) == -1)
      {
         if (!ObjectCreate(0, trend, OBJ_TREND, 0, time[lastLowI], low[lastLowI], time[i], low[i]))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetInteger(0, trend, OBJPROP_COLOR, Lime);
         ObjectSetInteger(0, trend, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, trend, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, trend, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, trend, OBJPROP_PRICE, 0, low[lastLowI]);
      ObjectSetDouble(0, trend, OBJPROP_PRICE, 1, low[i]);
      ObjectSetInteger(0, trend, OBJPROP_TIME, 0, time[lastLowI]);
      ObjectSetInteger(0, trend, OBJPROP_TIME, 1, time[i]);
      if (shownum || showindis)
      {
         string txt = showindis ? posdivtxt : "";
         txt = txt + (shownum ? IntegerToString(posdivergence) : "");
         ResetLastError();
         string id = IndicatorObjPrefix + TimeToString(time[i]) + "dnlidValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TEXT, 0, time[i], low[i]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               return ;
            }
            ObjectSetString(0, id, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 10);
            ObjectSetInteger(0, id, OBJPROP_COLOR, White);
            ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_UPPER);
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, time[i]);
         ObjectSetDouble(0, id, OBJPROP_PRICE, low[i]);
         ObjectSetString(0, id, OBJPROP_TEXT, txt);
      }
   }
}

double rsi(int i)
{
   double buffer[1];
   if (CopyBuffer(rsi, 0, i, 1, buffer) == 1)
   {
      return buffer[0];
   }
   return 0;
}

double macdMacd(int i)
{
   double buffer[1];
   if (CopyBuffer(rsi, 0, i, 1, buffer) == 1)
   {
      return buffer[0];
   }
   return 0;
}

double macdSignal(int i)
{
   double buffer[1];
   if (CopyBuffer(rsi, 1, i, 1, buffer) == 1)
   {
      return buffer[0];
   }
   return 0;
}

double deltamacd(int i)
{
   return macdMacd(i) + macdSignal(i);
}

double moment(int i)
{
   double buffer[1];
   if (CopyBuffer(momentum, 0, i, 1, buffer) == 1)
   {
      return buffer[0];
   }
   return 0;
}

double cci(int i)
{
   double buffer[1];
   if (CopyBuffer(cci, 0, i, 1, buffer) == 1)
   {
      return buffer[0];
   }
   return 0;
}

double stk(int i)
{
   double buffer[1];
   if (CopyBuffer(stoch, 0, i, 1, buffer) == 1)
   {
      return buffer[0];
   }
   return 0;
}

double cmf(int i, const long &tick_volume[])
{
   Cmfv[i] = Cmfm[i] * tick_volume[i];
   double volumeMA = 0;
   double Cmfv_val = 0;
   for (int index = MathMax(0, i - 21); index <= i; ++index)
   {
      volumeMA += tick_volume[index];
      Cmfv_val += Cmfv[index];
   }
   if (volumeMA == 0)
   {
      return 0;
   }
   return Cmfv_val / volumeMA;
}

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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(closeChange, EMPTY_VALUE);
      ArrayInitialize(Cmfm, EMPTY_VALUE);
      ArrayInitialize(lastHigh, EMPTY_VALUE);
      ArrayInitialize(obv, EMPTY_VALUE);
      ArrayInitialize(lastLow, EMPTY_VALUE);
      ArrayInitialize(Cmfv, EMPTY_VALUE);
   }
   for (int i = MathMax(1, prev_calculated); i < rates_total; ++i)
   {
      double obvValue = 0;
      if ((close[i] - close[i - 1]) > 0)
      {
         obvValue = tick_volume[i];
      }
      else if ((close[i] - close[i - 1]) > 0)
      {
         obvValue = -tick_volume[i];
      }
      obv[i] = i == 0 ? obvValue : obv[i - 1] + obvValue;
      if (high[i] - low[i] > 0)
      {
         Cmfm[i] = ((close[i] - low[i]) - (high[i] - close[i])) / (high[i] - low[i]);
      }
      else
      {
         Cmfm[i] = 0;
      }
      ProcessUp(i, rates_total - 1 - i, rates_total, open, high, low, close, time, tick_volume);
      ProcessDown(i, rates_total - 1 - i, rates_total, open, high, low, close, time, tick_volume);
   }
   return rates_total;
}