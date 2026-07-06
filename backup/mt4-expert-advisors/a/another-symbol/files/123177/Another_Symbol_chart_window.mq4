// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67234


//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property description   " Displays the quotes of another symbol"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrBlue

#property indicator_width1 1




input    string               i_symbol                   = "EURUSD";                               // Symbol  
input    ENUM_TIMEFRAMES      i_tf                       = PERIOD_CURRENT;                         // Timeframe  
input    ENUM_APPLIED_PRICE   i_priceType                = PRICE_CLOSE;                            // Price  
input    int                  i_indBarsCount             = 10000;                                  // Number of bars to display  
input    bool Inverse=false;
bool g_activate;

double   g_point,
         g_delta;

#define ERROR_UNKNOWN_SYMBOL                       4301
#define ERROR_SYMBOL_NOT_SELECT                    4302
#define ERROR_SYMBOL_PARAMETER                     4303
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MESSAGE_CODE
  {
   MESSAGE_CODE_WRONG_SYMBOL,
   MESSAGE_CODE_TERMINAL_FATAL_ERROR1,
   MESSAGE_CODE_BIND_ERROR
  };


double g_buffer[];
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   g_activate=false;

   if(!TuningParameters())
      return INIT_FAILED;

   if(!BuffersBind())
      return INIT_FAILED;

   g_activate=true;

   return INIT_SUCCEEDED;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the correctness of values of tuning parameters                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool TuningParameters()
  {
   string name=WindowExpertName();

   SymbolInfoDouble(i_symbol,SYMBOL_BID);
   int error = GetLastError();
   if(error >= ERROR_UNKNOWN_SYMBOL && error <= ERROR_SYMBOL_PARAMETER)
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_WRONG_SYMBOL));
      return false;
     }

   g_point = Point;
   g_delta = -g_point / 10;
   if(g_point==0)
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_TERMINAL_FATAL_ERROR1));
      return false;
     }

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Binding of array and the indicator buffers                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool BuffersBind()
  {
   string name=WindowExpertName();

 
   if(!SetIndexBuffer(0,g_buffer))
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_BIND_ERROR),GetLastError());
      return false;
     }

 
   SetIndexStyle(0,DRAW_LINE);

   SetIndexLabel(0,i_symbol+" price");

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Initialize of all indicator buffers                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void BuffersInitializeAll()
  {
   ArrayInitialize(g_buffer,EMPTY_VALUE);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determination of bar index which needed to recalculate                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int &total,const int ratesTotal,const int prevCalculated)
  {
   total=ratesTotal-2;

   if(i_indBarsCount>0 && i_indBarsCount<total)
      total=MathMin(i_indBarsCount,total);

   if(prevCalculated<ratesTotal-1)
     {
      BuffersInitializeAll();
      return total;
     }

   return (MathMin(ratesTotal - prevCalculated, total));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculation of indicators values                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CalcIndicatorData(int limit,int total)
  {
   for(int i=limit; i>=0; i--)
   
   {
   
       g_buffer[i]=iMA(i_symbol,i_tf,1,0,MODE_SMA,i_priceType,i);
	   
	   if (Inverse && g_buffer[i] != 0 )
	   {
	   g_buffer[i]=1/g_buffer[i];
	   }
	}   
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
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
   iTime(i_symbol,i_tf,1);
   if(GetLastError()!=ERR_NO_ERROR)
      return prev_calculated;

   int total;
   int limit=GetRecalcIndex(total,rates_total,prev_calculated);

   CalcIndicatorData(limit,total);

   return rates_total;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message and terminal language                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetStringByMessageCode(ENUM_MESSAGE_CODE messageCode)
  {
   

   return GetEnglishMessage(messageCode);
  }
 
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message for english language                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetEnglishMessage(ENUM_MESSAGE_CODE messageCode)
  {
   switch(messageCode)
     {
      case MESSAGE_CODE_WRONG_SYMBOL:                      return ": unable to find data for specified symbol. The indicator is turned off.";
      case MESSAGE_CODE_TERMINAL_FATAL_ERROR1:             return ": terminal fatal error - point equals to zero. The indicator is turned off.";
      case MESSAGE_CODE_BIND_ERROR:                        return ": error of binding of the arrays and the indicator buffers. Error N";
     }

   return "";
  }
//+------------------------------------------------------------------+
