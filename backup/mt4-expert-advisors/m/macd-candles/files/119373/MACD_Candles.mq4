// Id: 21458
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66152

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
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description ""

#property indicator_chart_window
#property indicator_buffers 10

#property indicator_color1 clrLime
#property indicator_color2 clrLime
#property indicator_color3 clrLime
#property indicator_color4 clrLime
#property indicator_color5 clrRed
#property indicator_color6 clrRed
#property indicator_color7 clrRed
#property indicator_color8 clrRed
#property indicator_color9 clrLime
#property indicator_color10 clrRed
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3
#property indicator_width9 1
#property indicator_width10 1

enum e_method{ MACD_Signal=1, MACD_Zero_Line=2, MACD_Compare=3 };

extern int      Fast_EMA    = 12;
extern int      Slow_EMA    = 26;
extern int      Signal_Line = 9;

int Method      = MACD_Zero_Line;

double Up_High[];
double Up_Low[];
double Up_Open[];
double Up_Close[];
double Dn_High[];
double Dn_Low[];
double Dn_Open[];
double Dn_Close[];

double MACD[];
double Signal[];

double UP[];
double DOWN[];

int Bullish = 1;
int Bearish = -1;
int Neutral = 0;

string   TimeFrames = "5,15,30,60,240,1440,10080,43200";
string TF_arr[]; // TimeFrames
int    TF_count; // Number of TFs

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
 
 IndicatorName = GenerateIndicatorName("MACD Candles");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(12);
   
   SetIndexBuffer(0,Up_High);
   SetIndexBuffer(1,Up_Low);
   SetIndexBuffer(2,Up_Open);
   SetIndexBuffer(3,Up_Close);
   SetIndexBuffer(4,Dn_High);
   SetIndexBuffer(5,Dn_Low);
   SetIndexBuffer(6,Dn_Open);
   SetIndexBuffer(7,Dn_Close);
   
   for (int i=0; i<8; i++){
      SetIndexStyle(i,DRAW_HISTOGRAM);
   }
   
   SetIndexBuffer(8,UP);
   SetIndexArrow(8,233);
   SetIndexStyle(8,DRAW_ARROW);
   SetIndexBuffer(9,DOWN);
   SetIndexArrow(9,234);
   SetIndexStyle(9,DRAW_ARROW);
   
   SetIndexBuffer(10,MACD);
   SetIndexBuffer(11,Signal);

   return(0);
   
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}
int start(){   

   int i, bias;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (Digits==3||Digits==5) pipSize=pipSize*10;
   
   split(TF_arr, TimeFrames, ",");
   TF_count = ArraySize(TF_arr);
   string TF_Label;
   int period;
   color macd_color;
   string macd_arrow;
   double macd, signal;
   int Pair_y = 50;
   int TF_x   =  800;
   int Original_x = TF_x;
   for (i=0; i < TF_count; i++) {
      TF_Label = Get_TimeFrame_Label(StringToInteger(TF_arr[i]));
      period = StringToInteger(TF_arr[i]);
      TF_x = TF_x-80;
      macd = iMACD(NULL,period,Fast_EMA,Slow_EMA,Signal_Line,PRICE_CLOSE,MODE_MAIN,0);
      signal = iMACD(NULL,period,Fast_EMA,Slow_EMA,Signal_Line,PRICE_CLOSE,MODE_SIGNAL,0);
      Comment(macd+" "+signal);
      if (macd>0){
         macd_arrow = "é";
         if (macd>signal)
            macd_color = clrLime;
         else
            macd_color = clrGreen;
      }else{
         macd_arrow = "ê";
         if (macd<signal)
            macd_color = clrRed;
         else
            macd_color = clrMaroon;
      }
      ObjectMakeLabel(IndicatorObjPrefix + TF_Label+"_Label", TF_x, 20, TF_Label, clrWhite, 1, 0, "Arial", 12 );
      ObjectMakeLabel(IndicatorObjPrefix + "MACD_"+TF_Label, TF_x, 50, macd_arrow, macd_color, 1, 0, "Wingdings", 12 );
   }

   for(i=limit; i>=0; i--){
   
      ResetBuffers(i);
   
      MACD[i]   = iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_Line,PRICE_CLOSE,MODE_MAIN,i);
      Signal[i] = iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_Line,PRICE_CLOSE,MODE_SIGNAL,i);
      
      bias=ColorCandle(MACD[i], Signal[i], MACD[i+1]);
   
      if(bias>0){
         
         Up_High[i]  = iHigh(NULL,0,i);
         Up_Low[i]   = iLow(NULL,0,i);  
         Up_Open[i]  = iOpen(NULL,0,i);
         Up_Close[i] = iClose(NULL,0,i);  
      
      }
      else if(bias<0){
         
         Dn_High[i]  = iHigh(NULL,0,i);
         Dn_Low[i]   = iLow(NULL,0,i);  
         Dn_Open[i]  = iOpen(NULL,0,i);
         Dn_Close[i] = iClose(NULL,0,i);
      
      }
      
      if (MACD[i] > Signal[i] && MACD[i+1] < Signal[i+1]){
         UP[i] = High[i]+(10*pipSize);
      }
      
      if (MACD[i] < Signal[i] && MACD[i+1] > Signal[i+1]){
         DOWN[i] = Low[i]-(10*pipSize);
      }

   }
 
   return(0);

}

void ResetBuffers(int shift){
 Up_High[shift]  = EMPTY_VALUE;
 Up_Low[shift]   = EMPTY_VALUE;
 Up_Open[shift]  = EMPTY_VALUE;
 Up_Close[shift] = EMPTY_VALUE;
 Dn_High[shift]  = EMPTY_VALUE;
 Dn_Low[shift]   = EMPTY_VALUE;
 Dn_Open[shift]  = EMPTY_VALUE;
 Dn_Close[shift] = EMPTY_VALUE;
 return;
}

int ColorCandle(double macd_value, double signal_value, double previous_macd){
 
   if (Method==1){
   
      if (macd_value >= signal_value)
         return(Bullish);
      else
         return (Bearish);
         
   }
   else if (Method==2){
      
      if (macd_value >= 0)
         return(Bullish);
      else
         return (Bearish);
      
   }
   else{
   
      if (macd_value >= previous_macd)
         return(Bullish);
      else
         return (Bearish);
   
   }

}

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (int i=0; i < len;) {
    pos = StringFind(str, sym, i);
    if (pos == -1) pos = len;
    
    item = StringSubstr(str, i, pos-i);
    item = StringTrimLeft(item);
    item = StringTrimRight(item);
    
    size = ArraySize(arr);
    ArrayResize(arr, size+1);
    arr[size] = item;
    
    i = pos+1;
  }
}

string Get_TimeFrame_Label(int TF){
   string Label;
   if (TF==5)     Label = "M5";
   if (TF==15)    Label = "M15";
   if (TF==30)    Label = "M30";
   if (TF==60)    Label = "H1";
   if (TF==240)   Label = "H4";
   if (TF==1440)  Label = "D1";
   if (TF==10080) Label = "W1";
   if (TF==43200) Label = "MN1";
   return(Label);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(nm);
   ObjectCreate( nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet( nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet( nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet( nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet( nm, OBJPROP_BACK, false );
   ObjectSetText( nm, LabelTexto, FSize, Font, LabelColor );
   return;
}