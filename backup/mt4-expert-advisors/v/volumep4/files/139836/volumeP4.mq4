// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70756

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
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Yellow

string IndicatorName;
string IndicatorObjPrefix;

enum ProfilePeriod
{
   ProfilePeriodD1, // Daily
   ProfilePeriodW1, // Weekly
   ProfilePeriodM1 // Monthly
};

input ProfilePeriod Method1 = ProfilePeriodD1; // Profile Period
input int box_count = 5; // Number of section
input int Value = 70; // Value Area Percentage
input bool Hide = false; // Hide TPO
input bool HideCom = true; // Hide TPO Comments
input bool LAST = false; // Show Only Last Period
input int Multi = 10; // Coeff profile Lenght
input color POC_color = Red; // POC Color
input int Size = 3; // Font Size
input color VA_color = Gray; // VA Color
input color label_color = Gray; // Label Color
input color profile_color = Pink; // Profile Color
input bool Rainbow = true; // Rainbow Effect
input color Pen_color = Black; // Pen Profile Color
input string StartTime = "09:00:00"; // Start Time for Trading
input string EndTime = "19:00:00"; // End Time for Trading

double VAH[], VAL[];
double BOX;
ENUM_TIMEFRAMES btf;

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

int ParseTime(const string time, string &error)
{
   int hours;
   int minutes;
   int seconds;
   if (StringFind(time, ":") == -1)
   {
      //hh:mm:ss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      hours = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      seconds = time_parsed % 100;
   }
   if (hours > 24)
   {
      error = "Incorrect number of hours in " + time;
      return -1;
   }
   if (minutes > 59)
   {
      error = "Incorrect number of minutes in " + time;
      return -1;
   }
   if (seconds > 59)
   {
      error = "Incorrect number of seconds in " + time;
      return -1;
   }
   if (hours == 24 && (minutes != 0 || seconds != 0))
   {
      error = "Incorrect date";
      return -1;
   }
   return (hours * 60 + minutes) * 60 + seconds;
}

int OpenTime, CloseTime;
int time_diff;
int init()
{
   IndicatorName = GenerateIndicatorName("volumeP4");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VAH);
   SetIndexLabel(0, "VAH");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, VAL);
   SetIndexLabel(1, "VAL");

   switch (Method1)
   {
      case ProfilePeriodD1:
         btf = PERIOD_D1;
         break;
      case ProfilePeriodW1:
         btf = PERIOD_W1;
         break;
      case ProfilePeriodM1:
         btf = PERIOD_MN1;
         break;
   }

   string error = "";
   OpenTime = ParseTime(StartTime, error);
   CloseTime = ParseTime(EndTime, error);
   if (error != "")
   {
      Print(error);
      return INIT_FAILED;
   }
   time_diff = CloseTime - OpenTime;
   if (time_diff < 0)
      time_diff += 86400;

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

datetime FixStartTime(datetime date)
{
   return (int)MathFloor(date / 86400) * 86400 + OpenTime;
}

datetime GetDate(int period)
{
   int index = iBarShift(_Symbol, btf, Time[period], false);
   datetime s = FixStartTime(iTime(_Symbol, btf, index));
   datetime e = FixStartTime(index == 0 ? Time[period] : iTime(_Symbol, btf, index - 1));
   if (Time[period] > e)
      s += 86400;
   else if (Time[period] < s)
      s -= 86400;
   return s;
}

class Data
{
public:
   datetime id;
   datetime start;
   datetime finish;
   double min;
   double max;
   int Total;
   int Profile[];
   int POC;
   double ValueArea;

   void ClearProfile()
   {
      ArrayResize(Profile, 0);
   }

   void EnsureProfileExists(int count)
   {
      int size = ArraySize(Profile);
      if (size < count)
         ArrayResize(Profile, count);
   }
};

class DataStorage
{
   Data* _data[];
public:
   ~DataStorage()
   {
      for (int i = 0; i < ArraySize(_data); ++i)
      {
         Data* item = _data[i];
         delete item;
      }
   }

   Data* FindOrCreate(datetime id)
   {
      int size = ArraySize(_data);
      for (int i = 0; i < size; ++i)
      {
         Data* item = _data[i];
         if (item.id == id)
            return item;
      }
      ArrayResize(_data, size + 1);
      Data* item = new Data();
      item.id = id;
      item.start = 0;
      item.finish = 0;
      _data[size] = item;
      return item;
   }
};

DataStorage storage;

color GetColor(int profile)
{
   if (profile > 60)
      return C'255, 0, 0';
   if (profile > 50)
      return C'128, 128, 255';
   if (profile > 30)
      return C'128, 128, 128';
   if (profile > 20)
      return C'28, 255, 255';
   if (profile > 10)
      return C'28, 255, 128';
   if (profile > 5)
      return C'43, 226, 240';
   return profile_color;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = 100; pos >= 0; --pos)
   {
      datetime s = GetDate(pos);
      if (LAST && s != GetDate(0))
         continue;

      Data* data = storage.FindOrCreate(s);
      if (data.start == 0)
      {
         data.start = Time[pos];
         data.finish = Time[pos];
      }
      else
      {
         datetime e = s + time_diff;
         if (e <= Time[pos])
            continue;

         data.finish = MathMax(data.finish, Time[pos]);
      }
      int start = iBarShift(_Symbol, _Period, data.start, false);
      int finish = iBarShift(_Symbol, _Period, data.finish, false);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, start - finish + 1, start);
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, start - finish + 1, start);
      data.min = iLow(_Symbol, _Period, lowestIndex);
      data.max = iHigh(_Symbol, _Period, highestIndex);
      
      lowestIndex = iLowest(_Symbol, _Period, MODE_VOLUME, start - finish + 1, start);
      highestIndex = iHighest(_Symbol, _Period, MODE_VOLUME, start - finish + 1, start);
      double min = iVolume(_Symbol, _Period, lowestIndex);
      double max = iVolume(_Symbol, _Period, highestIndex);
      data.Total = 0;
      data.ClearProfile();
      double BOX = (max - min) == 0 ? 1 : (max - min) / box_count;

      for (int j = finish; j <= start; ++j)
      {
         int Count = 0;
         for (double price = min; price <= max; price += BOX)
         {
            ++Count;
            data.EnsureProfileExists(Count);
            if ((price >= Volume[j] && price + BOX <= Volume[j]) || 
               (price <= Volume[j] && price + BOX >= Volume[j]) ||
               (price <= Volume[j] && price + BOX >= Volume[j]))
            {
               data.Profile[Count - 1] = data.Profile[Count - 1] + 1;
               data.Total = data.Total + 1;
            }
            if (price == min)
               data.POC = Count;
            else if (data.Profile[data.POC - 1] < data.Profile[Count - 1])
               data.POC = Count;
            data.ValueArea = Value * (data.Total / 100.0);
         }
         int va_min, va_max;
         CalcVAMinMax(data, va_min, va_max);
         VAH[j] = data.min + (data.max - data.min) * (va_max / box_count) * BOX;
         VAL[j] = data.min + (data.max - data.min) * (va_min / box_count) * BOX;
      }
      BOX = (data.max - data.min) / box_count;
      int size = ArraySize(data.Profile);
      for (int i = 0; i < size; ++i)
      {
         int profile = data.Profile[i];
         string text = i == data.POC - 1 ? "(" + IntegerToString(profile) + ")" : IntegerToString(profile);
         string id = IndicatorObjPrefix + "mainValue" + TimeToString(data.start);
         ObjectCreate(0, id, OBJ_TEXT, 0, data.start, data.max + 2 * BOX);
         ObjectSetString(0, id, OBJPROP_TEXT, text);
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, label_color);
         if (!Hide)
         {
            double coeff = (double)profile * Multi / data.Total;
            id = IndicatorObjPrefix + IntegerToString(i) + "Value" + TimeToString(data.start);
            datetime finishDate = data.start + (int)((data.finish - data.start) * coeff);
            ObjectCreate(0, id, OBJ_RECTANGLE, 0, data.start, data.min + i * BOX, finishDate, data.min + (i + 1) * BOX);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, data.min + i * BOX);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, data.min + (i + 1) * BOX);
            ObjectSetInteger(0, id, OBJPROP_TIME2, finishDate);
            ObjectSetInteger(0, id, OBJPROP_COLOR, Rainbow ? GetColor(profile) : profile_color);
            ObjectSetInteger(0, id, OBJPROP_FILL, true);
         }
      }
      if (!HideCom)
      {
         string text = " TSO Count (" + IntegerToString(data.Total) + "), Value Area(" +
            DoubleToString(data.ValueArea) + "), Last TSO (.), POC (" + DoubleToString(data.min + data.POC * BOX) + ")";
         string id = IndicatorObjPrefix + "comValue" + TimeToString(data.start);
         ObjectCreate(0, id, OBJ_TEXT, 0, data.start, data.max + 2 * BOX);
         ObjectSetString(0, id, OBJPROP_TEXT, text);
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, label_color);
      }
   } 
   return 0;
}

void CalcVAMinMax(Data* data, int& min, int& max)
{
   max = data.POC;
   min = data.POC;
   int size = ArraySize(data.Profile);
   int summ = data.Profile[data.POC - 1];
   while (summ < data.ValueArea)
   {
      int up = max == size ? 0 : data.Profile[max];
      int down = min < 2 ? 0 : data.Profile[min - 2];
      if (up == 0 && down == 0)
         return;
      if (up > down)
      {
         summ += up;
         ++max;
      }
      else
      {
         summ += down;
         --min;
      }
   }
}
