// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67183&start=10

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

#property tester_indicator "2 bar supply and demand"
#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots 10
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  Green, Red

#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_color8 Red
#property indicator_color9 Green

input bool OutputSD = false; // Output supply/demand values
input bool ShowAlerts = false; // Show alerts
input bool FillArea = false; // Fill area
input color FreshDemandColor = clrRed; // Color of the fresh demand levels
input color FreshSupplyColor = clrGreen; // Color of the fresh supply levels
input color RetestedDemandColor = clrPink; // Color of the retested demand levels
input color RetestedSupplyColor = clrLime; // Color of the retested supply levels
input int bars_limit = 1000; // Bars limit

class SDLevel
{
   double _low;
   double _high;
   bool _tested;
   bool _isSupply;
   datetime _date;
   datetime _dateEnd;
   string _idLow;
   string _idHigh;
public:
   SDLevel(const double low, const double high, const double isSupply, const datetime date, const datetime dateEnd, string id)
   {
      _low = low;
      _high = high;
      _isSupply = isSupply;
      _tested = false;
      _date = date;
      _dateEnd = dateEnd;
      _idLow = id + "_low";
      _idHigh = id + "_high";
   }

   void Test(const int period, const double &high[], const double &low[], const datetime &time[], int rates_total)
   {
      if (_tested || _dateEnd == time[period])
         return;

      if ((!_isSupply && low[period] <= _high) || (_isSupply && high[period] >= _low))
      {
         _tested = true;
         if (FillArea)
         {
            ObjectCreate(0, _idLow, OBJ_RECTANGLE, 0, _date, _low, time[period], _high);
            ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? RetestedSupplyColor : RetestedDemandColor);
            ObjectMove(0, _idHigh, 1, time[period], _high);
         }
         else
         {
            ObjectCreate(0, _idLow, OBJ_TREND, 0, _date, _low, time[period], _low);
            ObjectCreate(0, _idHigh, OBJ_TREND, 0, _date, _high, time[period], _high);
            ObjectSetInteger(0, _idLow, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _idHigh, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? RetestedSupplyColor : RetestedDemandColor);
            ObjectSetInteger(0, _idHigh, OBJPROP_COLOR, _isSupply ? RetestedSupplyColor : RetestedDemandColor);
            ObjectMove(0, _idLow, 1, time[period], _low);
            ObjectMove(0, _idHigh, 1, time[period], _high);
         }
      }
   }

   void Draw(const datetime &time[], int rates_total)
   {
      if (_tested)
         return;

      if (FillArea)
      {
         ObjectCreate(0, _idLow, OBJ_RECTANGLE, 0, _date, _low, time[rates_total - 1], _high);
         ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? FreshSupplyColor : FreshDemandColor);
         ObjectMove(0, _idHigh, 1, time[rates_total - 1], _high);
      }
      else
      {
         ObjectCreate(0, _idLow, OBJ_TREND, 0, _date, _low, time[rates_total - 1], _low);
         ObjectCreate(0, _idHigh, OBJ_TREND, 0, _date, _high, time[rates_total - 1], _high);
         ObjectSetInteger(0, _idLow, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, _idHigh, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? FreshSupplyColor : FreshDemandColor);
         ObjectSetInteger(0, _idHigh, OBJPROP_COLOR, _isSupply ? FreshSupplyColor : FreshDemandColor);
         ObjectMove(0, _idLow, 1, time[rates_total - 1], _low);
         ObjectMove(0, _idHigh, 1, time[rates_total - 1], _high);
      }
   }
};

class SDLevelStreams
{
   double _low[];
   double _high[];
public:
   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id + 0, _high, INDICATOR_DATA);
      SetIndexBuffer(id + 1, _low, INDICATOR_DATA);
      return id + 2;
   }

   void Clear(const int pos)
   {
      _low[pos] = EMPTY_VALUE;
      _high[pos] = EMPTY_VALUE;
   }

   void Set(const int pos, const double low, const double high)
   {
      _high[pos] = high;
      _low[pos] = low;
   }
};


SDLevel *levels[];
SDLevelStreams out_supply;
SDLevelStreams out_supply_wide;
SDLevelStreams out_demand;
SDLevelStreams out_demand_wide;

datetime lastCheck;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double ha_open[], ha_high[], ha_low[], ha_close[], colorBuffer[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("2bsad");
   IndicatorSetString(INDICATOR_SHORTNAME, "2 Bar Supply and Demand");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, ha_open, INDICATOR_DATA);
   SetIndexBuffer(1, ha_high, INDICATOR_DATA);
   SetIndexBuffer(2, ha_low, INDICATOR_DATA);
   SetIndexBuffer(3, ha_close, INDICATOR_DATA);
   SetIndexBuffer(4, colorBuffer, INDICATOR_COLOR_INDEX);

   int id = 5;
   id = out_supply.RegisterStreams(id);
   id = out_supply_wide.RegisterStreams(id);
   id = out_demand.RegisterStreams(id);
   id = out_demand_wide.RegisterStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   int i_count = ArraySize(levels);
   for (int i = 0; i < i_count; ++i)
   {
      delete levels[i];
   }
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
      ArrayInitialize(ha_open, EMPTY_VALUE);
      ArrayInitialize(ha_high, EMPTY_VALUE);
      ArrayInitialize(ha_low, EMPTY_VALUE);
      ArrayInitialize(ha_close, EMPTY_VALUE);
      ArrayInitialize(colorBuffer, EMPTY_VALUE);
   }
   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 2)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      out_demand.Clear(pos);
      out_demand_wide.Clear(pos);
      out_supply.Clear(pos);
      out_supply_wide.Clear(pos);
      if (lastCheck != time[pos])
      {
         lastCheck = time[pos];
         double rangePrev = high[pos - 1] - low[pos - 1];
         double prev50Pr = high[pos - 1] - rangePrev / 2;
         double rangeCurrent = high[pos] - low[pos];
         double curr50Pr = high[pos] - rangeCurrent / 2;

         bool supplyRule1 = close[pos - 1] < prev50Pr;
         bool supplyRule2 = high[pos] <= prev50Pr;
         bool supplyRule3 = rangeCurrent > rangePrev;
         bool supplyRule4 = close[pos] < curr50Pr; 
         if (supplyRule1 && supplyRule2 && supplyRule3 && supplyRule4)
         {
            int levelsCount = ArraySize(levels);
            ArrayResize(levels, levelsCount + 2);
            levels[levelsCount] = new SDLevel(low[pos - 1], high[pos], true, time[pos - 1], time[pos],
               IndicatorObjPrefix + "Supply_" + TimeToString(time[pos - 1]));
            levels[levelsCount + 1] = new SDLevel(low[pos - 1], high[pos - 1], true, time[pos - 1], time[pos],
               IndicatorObjPrefix + "Supply_wide_" + TimeToString(time[pos - 1]));

            if (OutputSD)
            {
               out_supply.Set(pos, low[pos - 1], high[pos]);
               out_supply_wide.Set(pos, low[pos - 1], high[pos - 1]);
            }
               
            ha_open[pos] = open[pos];
            ha_high[pos] = high[pos];
            ha_low[pos] = low[pos];
            ha_close[pos] = close[pos];
            colorBuffer[pos] = 0;

            ha_open[pos - 1] = open[pos - 1];
            ha_high[pos - 1] = high[pos - 1];
            ha_low[pos - 1] = low[pos - 1];
            ha_close[pos - 1] = close[pos - 1];
            colorBuffer[pos - 1] = 0;
         }

         bool demandRule1 = close[pos - 1] > prev50Pr;
         bool demandRule2 = low[pos] >= prev50Pr;
         bool demandRule3 = rangeCurrent > rangePrev;
         bool demandRule4 = close[pos] > curr50Pr;
         if (demandRule1 && demandRule2 && demandRule3 && demandRule4)
         {
            int levelsCount = ArraySize(levels);
            ArrayResize(levels, levelsCount + 2);
            levels[levelsCount] = new SDLevel(low[pos], high[pos - 1], false, time[pos - 1], time[pos],
               IndicatorObjPrefix + "Demand_" + TimeToString(time[pos - 1]));
            levels[levelsCount + 1] = new SDLevel(low[pos - 1], high[pos - 1], false, time[pos - 1], time[pos],
               IndicatorObjPrefix + "Demand_wide_" + TimeToString(time[pos - 1]));

            if (OutputSD)
            {
               out_demand.Set(pos, low[pos], high[pos - 1]);
               out_demand_wide.Set(pos, low[pos - 1], high[pos - 1]);
            }
            ha_open[pos] = open[pos];
            ha_high[pos] = high[pos];
            ha_low[pos] = low[pos];
            ha_close[pos] = close[pos];
            colorBuffer[pos] = 1;

            ha_open[pos - 1] = open[pos - 1];
            ha_high[pos - 1] = high[pos - 1];
            ha_low[pos - 1] = low[pos - 1];
            ha_close[pos - 1] = close[pos - 1];
            colorBuffer[pos - 1] = 1;
         }
      }
      int levelsCount = ArraySize(levels);
      for (int i = 0; i < levelsCount; ++i)
      {
         levels[i].Test(pos, high, low, time, rates_total);
      }
   }

   int levelsCount = ArraySize(levels);
   for (int i = 0; i < levelsCount; ++i)
   {
      levels[i].Draw(time, rates_total);
   }
   return rates_total;
}
