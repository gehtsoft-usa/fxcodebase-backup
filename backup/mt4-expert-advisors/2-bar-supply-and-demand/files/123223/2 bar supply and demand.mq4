// Id: 23436
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67183

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_color8 Red
#property indicator_color9 Green
#property indicator_color10 Red
#property indicator_color11 Green
#property indicator_color12 Red
#property indicator_color13 Green
#property indicator_color14 Red
#property indicator_color15 Green

extern bool OutputSD = false; // Output supply/demand values
extern bool ShowAlerts = false; // Show alerts
extern bool FillArea = false; // Fill area
extern color FreshDemandColor = clrRed; // Color of the fresh demand levels
extern color FreshSupplyColor = clrGreen; // Color of the fresh supply levels
extern color RetestedDemandColor = clrPink; // Color of the retested demand levels
extern color RetestedSupplyColor = clrLime; // Color of the retested supply levels
extern color DemandBarsColor = clrRed; // Color for demand bars
extern color SupplyBarsColor = clrGreen; // Color for supply bars

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

//Signaler v 1.5
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const int direction)
   {
      if (direction == 0)
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case 1:
            alert_Subject = "Supply bars on " + _symbol + "/" + tf;
            alert_Body = "Supply bars on " + _symbol + "/" + tf;
            break;
         case -1:
            alert_Subject = "Demand bars on " + _symbol + "/" + tf;
            alert_Body = "Demand bars on " + _symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      if (Advanced_Alert && Advanced_Key != "" && !IsTesting())
         AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

private:
   string GetTimeframe()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 3, LowStream);
      return id + 4;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

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

   void Test(const int period)
   {
      if (_tested || _dateEnd == Time[period])
         return;

      if ((!_isSupply && Low[period] <= _high) || (_isSupply && High[period] >= _low))
      {
         _tested = true;
         if (FillArea)
         {
            ObjectCreate(0, _idLow, OBJ_RECTANGLE, 0, _date, _low, Time[period], _high);
            ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? RetestedSupplyColor : RetestedDemandColor);
            ObjectMove(0, _idHigh, 1, Time[period], _high);
         }
         else
         {
            ObjectCreate(0, _idLow, OBJ_TREND, 0, _date, _low, Time[period], _low);
            ObjectCreate(0, _idHigh, OBJ_TREND, 0, _date, _high, Time[period], _high);
            ObjectSetInteger(0, _idLow, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _idHigh, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? RetestedSupplyColor : RetestedDemandColor);
            ObjectSetInteger(0, _idHigh, OBJPROP_COLOR, _isSupply ? RetestedSupplyColor : RetestedDemandColor);
            ObjectMove(0, _idLow, 1, Time[period], _low);
            ObjectMove(0, _idHigh, 1, Time[period], _high);
         }
      }
   }

   void Draw()
   {
      if (_tested)
         return;

      if (FillArea)
      {
         ObjectCreate(0, _idLow, OBJ_RECTANGLE, 0, _date, _low, Time[0], _high);
         ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? FreshSupplyColor : FreshDemandColor);
         ObjectMove(0, _idHigh, 1, Time[0], _high);
      }
      else
      {
         ObjectCreate(0, _idLow, OBJ_TREND, 0, _date, _low, Time[0], _low);
         ObjectCreate(0, _idHigh, OBJ_TREND, 0, _date, _high, Time[0], _high);
         ObjectSetInteger(0, _idLow, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, _idHigh, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, _idLow, OBJPROP_COLOR, _isSupply ? FreshSupplyColor : FreshDemandColor);
         ObjectSetInteger(0, _idHigh, OBJPROP_COLOR, _isSupply ? FreshSupplyColor : FreshDemandColor);
         ObjectMove(0, _idLow, 1, Time[0], _low);
         ObjectMove(0, _idHigh, 1, Time[0], _high);
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
      SetIndexBuffer(id + 0, _high);
      SetIndexBuffer(id + 1, _low);
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
Signaler *signaler;
CandleStreams supply;
CandleStreams demand;
SDLevelStreams out_supply;
SDLevelStreams out_supply_wide;
SDLevelStreams out_demand;
SDLevelStreams out_demand_wide;

int init()
{
   IndicatorName = GenerateIndicatorName("...");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   int id = supply.RegisterStreams(0, SupplyBarsColor);
   id = demand.RegisterStreams(id, DemandBarsColor);
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = out_supply.RegisterStreams(id);
   id = out_supply_wide.RegisterStreams(id);
   id = out_demand.RegisterStreams(id);
   id = out_demand_wide.RegisterStreams(id);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   int i_count = ArraySize(levels);
   for (int i = 0; i < i_count; ++i)
   {
      delete levels[i];
   }
   delete signaler;
   return 0;
}

datetime lastCheck;

int start()
{
   if (Bars <= 3)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return -1;
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars;

   int pos = limit;
   while (pos >= 0)
   {
      supply.Clear(pos);
      demand.Clear(pos);
      out_demand.Clear(pos);
      out_demand_wide.Clear(pos);
      out_supply.Clear(pos);
      out_supply_wide.Clear(pos);
      if (pos > 0 && lastCheck != Time[pos])
      {
         lastCheck = Time[pos];
         double rangePrev = High[pos + 1] - Low[pos + 1];
         double prev50Pr = High[pos + 1] - rangePrev / 2;
         double rangeCurrent = High[pos] - Low[pos];
         double curr50Pr = High[pos] - rangeCurrent / 2;

         bool supplyRule1 = Close[pos + 1] < prev50Pr;
         bool supplyRule2 = High[pos] <= prev50Pr;
         bool supplyRule3 = rangeCurrent > rangePrev;
         bool supplyRule4 = Close[pos] < curr50Pr; 
         if (supplyRule1 && supplyRule2 && supplyRule3 && supplyRule4)
         {
            int levelsCount = ArraySize(levels);
            ArrayResize(levels, levelsCount + 2);
            levels[levelsCount] = new SDLevel(Low[pos + 1], High[pos], true, Time[pos + 1], Time[pos],
               IndicatorObjPrefix + "Supply_" + TimeToStr(Time[pos + 1]));
            levels[levelsCount + 1] = new SDLevel(Low[pos + 1], High[pos + 1], true, Time[pos + 1], Time[pos],
               IndicatorObjPrefix + "Supply_wide_" + TimeToStr(Time[pos + 1]));

            if (OutputSD)
            {
               out_supply.Set(pos, Low[pos + 1], High[pos]);
               out_supply_wide.Set(pos, Low[pos + 1], High[pos + 1]);
            }
            if (pos == 1 && ShowAlerts)
               signaler.SendNotifications(1);
            supply.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
            supply.Set(pos + 1, Open[pos + 1], High[pos + 1], Low[pos + 1], Close[pos + 1]);
         }

         bool demandRule1 = Close[pos + 1] > prev50Pr;
         bool demandRule2 = Low[pos] >= prev50Pr;
         bool demandRule3 = rangeCurrent > rangePrev;
         bool demandRule4 = Close[pos] > curr50Pr;
         if (demandRule1 && demandRule2 && demandRule3 && demandRule4)
         {
            int levelsCount = ArraySize(levels);
            ArrayResize(levels, levelsCount + 2);
            levels[levelsCount] = new SDLevel(Low[pos], High[pos + 1], false, Time[pos + 1], Time[pos],
               IndicatorObjPrefix + "Demand_" + TimeToStr(Time[pos + 1]));
            levels[levelsCount + 1] = new SDLevel(Low[pos + 1], High[pos + 1], false, Time[pos + 1], Time[pos],
               IndicatorObjPrefix + "Demand_wide_" + TimeToStr(Time[pos + 1]));

            if (OutputSD)
            {
               out_demand.Set(pos, Low[pos], High[pos + 1]);
               out_demand_wide.Set(pos, Low[pos + 1], High[pos + 1]);
            }
            if (pos == 1 && ShowAlerts)
               signaler.SendNotifications(-1);
            demand.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
            demand.Set(pos + 1, Open[pos + 1], High[pos + 1], Low[pos + 1], Close[pos + 1]);
         }
      }
      int levelsCount = ArraySize(levels);
      for (int i = 0; i < levelsCount; ++i)
      {
         levels[i].Test(pos);
      }
      pos--;
   }
   
   int levelsCount = ArraySize(levels);
   for (int i = 0; i < levelsCount; ++i)
   {
      levels[i].Draw();
   }
   
   return 0;
}
