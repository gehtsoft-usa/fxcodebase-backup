// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65487

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Bullish Change: Current Close > Previous Low"
#property description "Bearish Change: Current Close < Previous High"
#property indicator_chart_window

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

int init(){
   IndicatorName = GenerateIndicatorName("Price Action Colored Candle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
    return(0);
}
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start(){
   
   WindowRedraw();
   
   int limit, i, j;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars - 1;
   
   for(i=limit; i>=0; i--){
      if (ObjectFind(IndicatorObjPrefix + "Bearish_"+i)==0) ObjectDelete(IndicatorObjPrefix + "Bearish_"+i);
      if (ObjectFind(IndicatorObjPrefix + "Bullish_"+i)==0) ObjectDelete(IndicatorObjPrefix + "Bullish_"+i);
   }   
   
   int previous_change = 0;
   double high, low;
   
   for(i=limit-2; i>=0; i--){
   
      // Bullish Change:
      if (Close[i] > Low[i+1]){
      
         if (Close[i+1] > Low[i+2]){
         
            // do nothing
         
         }else{
         if (previous_change > 0){
         
            for (j=previous_change; j>=i+1; j--){
               if (j==previous_change){ high = High[j]; low = Low[j]; }
               else{
                  if (High[j] > high) high = High[j];
                  if (Low[j]  < low)  low  = Low[j];
               }
            }
            Zone_Area("Bearish_"+previous_change, Time[previous_change], high, Time[i+1], low, clrRed, false);
         }
         previous_change = i;
         }
      
      }
      // Bearich Change:
      if (Close[i] < High[i+1]){
      
         if (Close[i+1] < High[i+2]){
         
            // do nothing
         
         }else{
         if (previous_change > 0){
         
            for (j=previous_change; j>=i+1; j--){
               if (j==previous_change){ high = High[j]; low = Low[j]; }
               else{
                  if (High[j] > high) high = High[j];
                  if (Low[j]  < low)  low  = Low[j];
               }
            }
            Zone_Area("Bullish_"+previous_change, Time[previous_change], low, Time[i+1], high, clrLime, false);
         }
         previous_change = i;
         }
      }
   }
   
//----
   return(0);
}

void Zone_Area(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, double precio2, color zcolor, bool backobj = true){
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre,OBJ_RECTANGLE,0,tiempo1,precio1,tiempo2,precio2);
   ObjectSet(IndicatorObjPrefix + Nombre,OBJPROP_COLOR,zcolor);
   ObjectSet(IndicatorObjPrefix + Nombre,OBJPROP_BACK,backobj);
   return;
}