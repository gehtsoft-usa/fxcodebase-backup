// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68836

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

input color   BidColor  = Red; // Bid color
input color   AskColor  = Green; // Ask color
input int     LineStyle  = 0;
input int     LineLength = 5;
input bool    ShowAsk    = false;
input bool    ShowBid    = true;
input int     TextSize   = 2;

string IndiName = "Bid Ask Line";

int OnInit(void)
{
   del_obj();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   del_obj();
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
   double bidp = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double askp = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   del_obj();
   double currentTime = time[rates_total - 1];
   ObjectCreate(0, IndiName+"-Ask",OBJ_TREND,0,currentTime,askp,currentTime+LineLength*60*Period(),askp);
   ObjectSetInteger(0, IndiName+"-Ask", OBJPROP_COLOR, AskColor);
   ObjectSetInteger(0, IndiName+"-Ask",OBJPROP_STYLE,LineStyle);
   ObjectSetInteger(0, IndiName+"-Ask",OBJPROP_RAY,0);
   ObjectCreate(0, IndiName+"-Bid",OBJ_TREND,0,currentTime,bidp,currentTime+LineLength*60*Period(),bidp);
   ObjectSetInteger(0, IndiName+"-Bid",OBJPROP_COLOR,BidColor);
   ObjectSetInteger(0, IndiName+"-Bid",OBJPROP_STYLE,LineStyle);
   ObjectSetInteger(0, IndiName+"-Bid",OBJPROP_RAY,0);
   if (ShowAsk)
   {
      ObjectCreate(0, IndiName+"-AskL",OBJ_ARROW,0,currentTime+(LineLength+1)*60*Period(),askp);
      ObjectSetInteger(0, IndiName+"-AskL",OBJPROP_COLOR,AskColor);
      ObjectSetInteger(0, IndiName+"-AskL",OBJPROP_WIDTH,TextSize);
      ObjectSetInteger(0, IndiName+"-AskL",OBJPROP_ARROWCODE,6);
   }  
   if (ShowBid)
   {
      ObjectCreate(0, IndiName+"-BidL",OBJ_ARROW,0,currentTime+(LineLength+1)*60*Period(),bidp);
      ObjectSetInteger(0, IndiName+"-BidL",OBJPROP_COLOR,BidColor);
      ObjectSetInteger(0, IndiName+"-BidL",OBJPROP_WIDTH,TextSize);
      ObjectSetInteger(0, IndiName+"-BidL",OBJPROP_ARROWCODE,6);
   }  
   return(0);
}

//+------------------------------------------------------------------+
int del_obj()  {
//+------------------------------------------------------------------+
   ObjectDelete(0,IndiName+"-Ask");
   ObjectDelete(0,IndiName+"-Bid");
   if (ShowAsk)   ObjectDelete(0,IndiName+"-AskL");
   if (ShowBid)   ObjectDelete(0,IndiName+"-BidL");
   return(0);
}
