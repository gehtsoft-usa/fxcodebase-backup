// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69239

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
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

input int adx_period = 14; // ADX period
input int dmi_period = 14; // DMI period

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

double adx[], dmip[], dmim[];

int init()
{
   IndicatorName = GenerateIndicatorName("ADX DMI");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, adx);
   SetIndexLabel(0, "ADX");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, dmip);
   SetIndexLabel(1, "DMI+");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, dmim);
   SetIndexLabel(2, "DMI-");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
   for (int i = limit; i >= 0; i--)
   {
      adx[i] = iADX(_Symbol, _Period, adx_period, PRICE_CLOSE, MODE_MAIN, i);
      dmip[i] = iADX(_Symbol, _Period, dmi_period, PRICE_CLOSE, MODE_PLUSDI, i);
      dmim[i] = iADX(_Symbol, _Period, dmi_period, PRICE_CLOSE, MODE_MINUSDI, i);
   }
   return 0;
}
