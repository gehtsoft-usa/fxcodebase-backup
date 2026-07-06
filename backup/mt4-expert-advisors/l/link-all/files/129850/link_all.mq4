// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69146

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

input int magic_number = 42; // Magic number

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
string _filename;

string ReadSymbol()
{
   int handle = FileOpen(_filename, FILE_READ);
   if (handle == INVALID_HANDLE)
      return "";

   string symbol = FileReadString(handle);
   FileClose(handle);
   return symbol;
}

void WriteSymbol(string symbol)
{
   int handle = FileOpen(_filename, FILE_WRITE);
   if (handle != INVALID_HANDLE)
   {
      FileWriteString(handle, symbol);
      FileClose(handle);
   }
}

int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("Link All");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   EventSetTimer(1);
   _filename = "link_all_" + IntegerToString(magic_number) + ".data";
   if (ReadSymbol() != _Symbol)
      WriteSymbol(_Symbol);

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   return rates_total;
}

void OnTimer()
{
   string newSymbol = ReadSymbol();
   if (newSymbol != "" && newSymbol != NULL && newSymbol != _Symbol)
   {
      ChartSetSymbolPeriod(ChartID(), newSymbol, _Period);
   }
}