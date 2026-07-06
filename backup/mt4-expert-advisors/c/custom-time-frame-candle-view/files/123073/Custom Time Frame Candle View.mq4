// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67215

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
#property version   "1.0"
#property strict

#property indicator_chart_window
#include <WinUser32.mqh>
#include <stdlib.mqh>

//+------------------------------------------------------------------+
#import "user32.dll"
int RegisterWindowMessageW(string lpString);
#import
//+------------------------------------------------------------------+

enum BaseTimeframe
{
   Minute,
   Hour,
   Day,
   Week,
   Month
};

extern BaseTimeframe TF = Minute; // Base Time Frame
extern int Step = 1; // Number Of Elements

//+------------------------------------------------------------------+
int HstHandle = -1, LastFPos = 0, MT4InternalMsg = 0;
datetime dtSendTime;
double dSendOpen;
double dSendHigh;
double dSendLow;
double dSendClose;
double dSendVol;
bool bStopAll = false;
int iRcdCnt = 0;
int hwnd = 0;
double BoxPoints, UpWick, DnWick;
double PrevLow, PrevHigh, PrevOpen, PrevClose, CurVolume, CurLow, CurHigh, CurOpen, CurClose;
datetime PrevTime;

class CandleMerger
{
   MqlRates _candles[];
   int _count;
   int _size;
public:
   CandleMerger(const int count)
   {
      _count = count;
      ArrayResize(_candles, _count);
      _size = 0;
   }

   ~CandleMerger()
   {
   }

   void Clear()
   {
      _size = 0;
   }

   void GetCandle(MqlRates &candle)
   {
      candle.time = _candles[0].time;
      candle.open = _candles[0].open;
      candle.close = _candles[_size - 1].close;
      candle.high = _candles[0].high;
      candle.low = _candles[0].low;
      candle.tick_volume = _candles[0].tick_volume;
      candle.spread = 0;
      for (int i = 1; i < _size; ++i)
      {
         if (candle.high < _candles[i].high)
            candle.high = _candles[i].high;

         if (candle.low > _candles[i].low)
            candle.low = _candles[i].low;

         candle.tick_volume = candle.tick_volume + _candles[i].tick_volume;
      }
      candle.real_volume = candle.tick_volume;
   }

   bool Add(const datetime date, const double open, const double high, const double low, const double close, const long volume)
   {
      if (_size == _count)
         return false;
      bool replace = _size > 0 && _candles[_size - 1].time == date;
      int index = replace ? _size - 1 : _size;
      _candles[index].time = date;
      _candles[index].open = open;
      _candles[index].high = high;
      _candles[index].low = low;
      _candles[index].close = close;
      _candles[index].tick_volume = volume;
      if (!replace)
         _size++;
      return true;
   }
};

ENUM_TIMEFRAMES _basePeriod;
CandleMerger *merger;
string _filename;
int OnInit()
{
   string baseTFStr = "";
   switch (TF)
   {
      case Minute:
         baseTFStr = "M1";
         _basePeriod = PERIOD_M1;
         break;
      case Hour:
         baseTFStr = "H1";
         _basePeriod = PERIOD_H1;
         break;
      case Day:
         baseTFStr = "D1";
         _basePeriod = PERIOD_D1;
         break;
      case Week:
         baseTFStr = "W1";
         _basePeriod = PERIOD_W1;
         break;
      case Month:
         baseTFStr = "MN1";
         _basePeriod = PERIOD_MN1;
         break;
      default:
         return INIT_FAILED;
   }
   _filename = _Symbol + IntegerToString(GetTimeframe()) + ".hst";
   merger = new CandleMerger(Step);
   if (HstHandle > 0)
   {
      FileClose(HstHandle);
   }
   HstHandle = -1;
   EventSetTimer(1);

   return INIT_SUCCEEDED;
}
  
void OnDeinit(const int reason)
{
   delete merger;
   if (HstHandle >= 0)
   {
      FileClose(HstHandle);
      HstHandle = -1;
   }
   Comment("");
   return;
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   if (bStopAll)
      return(0);

   //+------------------------------------------------------------------+
   // This is only executed once, then the first tick arives.
   if (HstHandle < 0)
   {
      // Init
      // Error checking
      if (!IsConnected())
      {
         Print("Waiting for connection...");
         return(0);
      }
      if (!IsDllsAllowed())
      {
         Print("Error: Dll calls must be allowed!");
         bStopAll = true;
         return(0);
      }

      // create / open hst file
      HstHandle = FileOpenHistory(_filename, FILE_BIN | FILE_WRITE | FILE_ANSI);
      if (HstHandle < 0)
      {
         Print("Error: can\'t create / open history file: " + ErrorDescription(GetLastError()) + ": " + _filename);
         bStopAll = true;
         return(0);
      }
      else
      {
         Print("History file opened for write, handle: " + IntegerToString(HstHandle));
         FileSeek(HstHandle, 0, SEEK_SET);
         // Hist file opened as write zero length to create
      }
      // the file is created empty, now re-open it read write shared
      DoOpenHistoryReadWrite();
      FileSeek(HstHandle, 0, SEEK_SET);
      //Hist file opened as read write for adding to

      // write hst file header  -  does anyone have a structure for this heading?
      int HstUnused[13];
      FileWriteInteger(HstHandle, 401, LONG_VALUE); // Version  // was 400
      FileWriteString(HstHandle, "", 64); // Copyright
      FileWriteString(HstHandle, _Symbol, 12); // Symbol
      FileWriteInteger(HstHandle, GetTimeframe(), LONG_VALUE); // Period
      FileWriteInteger(HstHandle, Digits, LONG_VALUE); // Digits
      FileWriteInteger(HstHandle, 0, LONG_VALUE); // Time Sign
      FileWriteInteger(HstHandle, 0, LONG_VALUE); // Last Sync
      FileWriteArray(HstHandle, HstUnused, 0, 13); // Unused

      // process historical data
      int i = iBars(NULL, _basePeriod) - 2;
      while(i >= 0)
      {
         if (!merger.Add(iTime(NULL, _basePeriod, i), iOpen(NULL, _basePeriod, i), iHigh(NULL, _basePeriod, i), iLow(NULL, _basePeriod, i), iClose(NULL, _basePeriod, i), iVolume(NULL, _basePeriod, i)))
         {
            MqlRates candle;
            merger.GetCandle(candle);
            merger.Clear();
            merger.Add(iTime(NULL, _basePeriod, i), iOpen(NULL, _basePeriod, i), iHigh(NULL, _basePeriod, i), iLow(NULL, _basePeriod, i), iClose(NULL, _basePeriod, i), iVolume(NULL, _basePeriod, i));
            DoWriteStruct(candle);
         }
         i--;
      }
      LastFPos = (int)FileTell(HstHandle); // Remember Last pos in file
      MqlRates candle;
      merger.GetCandle(candle);
      DoWriteStruct(candle);
      FileFlush(HstHandle);

      if (bStopAll)
         return(0);
      Comment("Custom Time Frame Candle View: Open Offline ", _Symbol, ",M", GetTimeframe(), " To View Chart");
      UpdateChartWindow();
      return(0);
      // End historical data / Init
   }
   //----------------------------------------------------------------------------
   // HstHandle not < 0 so we always enter here after history done
   // Begin live data feed
   if (bStopAll)
      return(0);

   FileSeek(HstHandle, LastFPos, SEEK_SET);

   if (!merger.Add(iTime(NULL, _basePeriod, 0), iOpen(NULL, _basePeriod, 0), iHigh(NULL, _basePeriod, 0), iLow(NULL, _basePeriod, 0), iClose(NULL, _basePeriod, 0), iVolume(NULL, _basePeriod, 0)))
   {
      MqlRates candle;
      merger.GetCandle(candle);
      merger.Clear();
      merger.Add(iTime(NULL, _basePeriod, 0), iOpen(NULL, _basePeriod, 0), iHigh(NULL, _basePeriod, 0), iLow(NULL, _basePeriod, 0), iClose(NULL, _basePeriod, 0), iVolume(NULL, _basePeriod, 0));
      DoWriteStruct(candle);
      FileFlush(HstHandle);
      LastFPos = (int)FileTell(HstHandle); // Remeber Last pos in file   
   }
   return rates_total;
}

int GetTimeframe()
{
   switch (TF)
   {
      case Minute:
         return PERIOD_M1 * Step;
      case Hour:
         return PERIOD_H1 * Step;
      case Day:
         return PERIOD_D1 * Step;
      case Week:
         return PERIOD_W1 * Step;
      case Month:
         return PERIOD_MN1 * Step;
   }
   return 0;
}

void UpdateChartWindow()
{
   if (hwnd == 0)
   {
      hwnd = WindowHandle(_Symbol, GetTimeframe());
      if (hwnd != 0)
         Print("Chart window detected");
   }
   if (MT4InternalMsg == 0)
      MT4InternalMsg = RegisterWindowMessageW("MetaTrader4_Internal_Message");
   if (hwnd != 0 && PostMessageW(hwnd, WM_COMMAND, 0x822c, 0) == 0)
      hwnd = 0;
   if (hwnd != 0 && MT4InternalMsg != 0)
      PostMessageW(hwnd, MT4InternalMsg, 2, 1);
}

void DoWriteStruct(MqlRates &rate)
{
   iRcdCnt++;
   static int iErr = 0;
   static int iBWritn = 0;
   iBWritn = (int)FileWriteStruct(HstHandle, rate);
   if (iBWritn == 0)
   {
      iErr = GetLastError();
      Print("Error on write struct at cntr: " + IntegerToString(iRcdCnt) + ", errdesc: " + ErrorDescription(iErr));//W4
      bStopAll = true;
   }
}

void DoOpenHistoryReadWrite()
{
   if (HstHandle >= 0)
   {
      int iSz = (int)FileSize(HstHandle);
      Print("fl sz " + IntegerToString(iSz));
      FileClose(HstHandle);
      HstHandle = -1;
   }
   HstHandle = FileOpenHistory(_filename, FILE_BIN | FILE_READ | FILE_WRITE | FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_ANSI);
   // this combination is critical to unlock the file and still allow read write and opening a chart on it
   if (HstHandle < 0)
   {
      Print("Error: cant open history file read write: " + ErrorDescription(GetLastError()) + ": " + _filename);
      bStopAll = true;
   }
   else
   {
      Print("Hist file opened for read write, handle: " + IntegerToString(HstHandle));
   }
}