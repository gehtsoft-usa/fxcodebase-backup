// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65760

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property description "Indicator colors the candle according to:"
#property description "- ADX trend given by the DIP and DIM"
#property description "- Close position in regards of the SAR"

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1  clrLime
#property indicator_color2  clrLime
#property indicator_color3  clrLime
#property indicator_color4  clrLime
#property indicator_color5  clrRed
#property indicator_color6  clrRed
#property indicator_color7  clrRed
#property indicator_color8  clrRed
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  3
#property indicator_width8  3

extern int    ADX_Periods = 14;
extern double SAR_Step    = 0.02;
extern double SAR_Maximum = 0.2;

double Up_High[];
double Up_Low[];
double Up_Open[];
double Up_Close[];
double Dn_High[];
double Dn_Low[];
double Dn_Open[];
double Dn_Close[];

string   WindowName;
int      WindowNumber;

string TimeFrames = "5,15,30,60,240,1440,10080";
string TF_arr[]; // TimeFrames
int    TF_count; // Number of TFs

color Up_Color                 = clrLime;
color Dn_Color                 = clrRed;
color Neutral_Color            = clrDarkGray;

int Bullish = 1;
int Bearish = -1;
int Neutral = 0;

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
 
   WindowName = "MTF_TrendBar";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
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
   
   double dip, dim, sar;
   
   for(i=limit; i>=0; i--){
   
      ResetBuffers(i);
   
      dip = iADX(NULL,0,ADX_Periods,PRICE_CLOSE,MODE_PLUSDI,i);
      dim = iADX(NULL,0,ADX_Periods,PRICE_CLOSE,MODE_MINUSDI,i);
      sar = iSAR(NULL,0,SAR_Step,SAR_Maximum,i);
      
      bias=ColorCandle(dip, dim, sar, Close[i]);
   
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

   }
   
   // MTF
   int period;
   WindowNumber = WindowFind(IndicatorName);   
   int Pair_y = 50;
   string TF_Label;
   split(TF_arr, TimeFrames, ",");
   TF_count = ArraySize(TF_arr);
   color  diff_color;
   string diff_string;
   
   ObjectMakeLabel("Trendbar_Label", 20, 20, "MTF Trend Bar:", clrYellow, 1, 0, "Arial", 15 );
   
   for (i=0; i < TF_count; i++) {
            
      TF_Label = Get_TimeFrame_Label(StringToInteger(TF_arr[i]));
      period = StringToInteger(TF_arr[i]);
      
      dip = iADX(NULL,period,ADX_Periods,PRICE_CLOSE,MODE_PLUSDI,0);
      dim = iADX(NULL,period,ADX_Periods,PRICE_CLOSE,MODE_MINUSDI,0);
      sar = iSAR(NULL,period,SAR_Step,SAR_Maximum,0);
      
      bias=ColorCandle(dip, dim, sar, Close[0]);
      
      if(bias>0){
         diff_color = Up_Color;
         diff_string = "é";
      }
      else if(bias<0){
         diff_color = Dn_Color;
         diff_string = "ê";
      }
      else{
         diff_color = Neutral_Color;
         diff_string = "û";
      }
      
      ObjectMakeLabel(TF_Label+"_Label", 100, Pair_y, TF_Label, clrWhite, 1, 0, "Arial", 12 );
      ObjectMakeLabel(Symbol()+"_"+TF_Label, 50, Pair_y, diff_string, diff_color, 1, 0, "Wingdings", 10 );
      /**/
      Pair_y = Pair_y+30;
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

int ColorCandle(double dip, double dim, double sar, double price){
   
   if (dip > dim && sar < price)
      return(Bullish);
   else if (dip < dim && sar > price)
      return (Bearish);
   else
      return (Neutral);

}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
   return;
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