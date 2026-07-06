// More information about this indicator can be found at:
// http://fxcodebase.com/

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

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

input int x = 50;
input int y = 50;
input int font_size = 12; // Font size
input string day_start = "000000"; // Start time in hhmmss format

double RF[], RF_Dn[], RF_N[];

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

int TimeToInt(const MqlDateTime &current_time)
{
   return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
}

int start_time;
datetime GetStartTime(const datetime date)
{
   MqlDateTime current_time;
   if (!TimeToStruct(date, current_time))
      return date;

   current_time.hour = 0;
   current_time.min = 0;
   current_time.sec = 0;
   return StructToTime(current_time) + start_time;
}

int init()
{
   string error;
   start_time = ParseTime(day_start, error);
   if (start_time == -1)
   {
      Print(error);
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("Cumulative Rotation Factor");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,RF);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,RF_Dn);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2,RF_N);

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if(Bars<=3) 
      return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) 
      limit=Bars-ExtCountedBars-1;

   int pos = limit;
   while(pos>=0)
   {
      bool NewDay = GetStartTime(Time[pos]) != GetStartTime(Time[pos+1]);
      if (pos==Bars-2)
         RF[pos]=0.;
      else
      {
         RF[pos]=RF[pos+1];
         if (NewDay)
            RF[pos]=0.;
         
         if (High[pos]>High[pos+1] && Low[pos]>Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1]+2.;
         
         if (High[pos]<High[pos+1] && Low[pos]<Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1]-2.;

         if (High[pos]>High[pos+1] && Low[pos]<Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1];
         
         if (High[pos]<High[pos+1] && Low[pos]>Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1];

         if (High[pos]==High[pos+1] && Low[pos]>Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1]+1.;

         if (High[pos]>High[pos+1] && Low[pos]==Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1]+1.;

         if (High[pos]<High[pos+1] && Low[pos]==Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1]-1.;

         if (High[pos]==High[pos+1] && Low[pos]<Low[pos+1] && !NewDay)
            RF[pos]=RF[pos+1]-1.;
         
         RF_Dn[pos]=0.;
         RF_N[pos]=0.;
         
         if (RF[pos]<RF[pos+1])
            RF_Dn[pos]=RF[pos];
         else if (RF[pos]==RF[pos+1])
            RF_N[pos]=RF[pos];
      }

      pos--;
   }

   ResetLastError();
   string id = IndicatorObjPrefix + "idValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetString(0, id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
      ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
      ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   }
   ObjectSetString(0, id, OBJPROP_TEXT, "RF: " + IntegerToString((int) RF[0]));
   return(0);
}

