// Id: 21072
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65975

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

#property description "Information Dashboard showing the pips of Close Price in regards to different parameters"

#property indicator_buffers 8
#property indicator_chart_window
#property indicator_levelcolor clrDimGray
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_SOLID

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

input  e_method MA_Method   = EMA;
input  e_price  MA_Price    = CLOSE;
extern int      MA_Period_1 = 5;
extern int      MA_Period_2 = 10;
extern int      MA_Period_3 = 20;
extern int      MA_Period_4 = 30;
extern int      MA_Period_5 = 60;
extern int      MA_Period_6 = 120;
extern int      MA_Period_7 = 250;

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
   
   IndicatorName = GenerateIndicatorName("Data_Overlay");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int deinit(){
   
   Limpiar();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   
   return(0);
}

int start(){
   
   ObjectMakeLabel(IndicatorObjPrefix+"close_low_lbl",   120, 10, "Close/Low(0):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"close_low1_lbl",  120, 40, "Close/Low(1):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"close_high_lbl",  120, 70, "Close/High(0):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"close_high1_lbl", 120, 100, "Close/High(1):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva1_close_lbl",  120, 130, "Close/MVA("+MA_Period_1+"):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva2_close_lbl",  120, 160, "Close/MVA("+MA_Period_2+"):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva3_close_lbl",  120, 190, "Close/MVA("+MA_Period_3+"):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva4_close_lbl",  120, 220, "Close/MVA("+MA_Period_4+"):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva5_close_lbl",  120, 250, "Close/MVA("+MA_Period_5+"):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva6_close_lbl",  120, 280, "Close/MVA("+MA_Period_6+"):", clrWhite, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva7_close_lbl",  120, 310, "Close/MVA("+MA_Period_7+"):", clrWhite, 1, 0, "Arial", 13);
   
   double mva1 = iMA(NULL,0,MA_Period_1,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),0);
   double mva2 = iMA(NULL,0,MA_Period_2,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),0);
   double mva3 = iMA(NULL,0,MA_Period_3,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),0);
   double mva4 = iMA(NULL,0,MA_Period_4,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),0);
   double mva5 = iMA(NULL,0,MA_Period_5,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),0);
   double mva6 = iMA(NULL,0,MA_Period_6,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),0);
   double mva7 = iMA(NULL,0,MA_Period_7,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),0);
   
   double close_low_0_pips  = (1/Point)*(Close[0]-Low[0]);
   double close_low_1_pips  = (1/Point)*(Close[1]-Low[1]);
   double close_high_0_pips = (1/Point)*(High[0]-Close[0]);
   double close_high_1_pips = (1/Point)*(High[1]-Close[1]);
   double mva1_close_pips   = (1/Point)*(Close[0]-mva1);
   double mva2_close_pips   = (1/Point)*(Close[0]-mva2);
   double mva3_close_pips   = (1/Point)*(Close[0]-mva3);
   double mva4_close_pips   = (1/Point)*(Close[0]-mva4);
   double mva5_close_pips   = (1/Point)*(Close[0]-mva5);
   double mva6_close_pips   = (1/Point)*(Close[0]-mva6);
   double mva7_close_pips   = (1/Point)*(Close[0]-mva7);
   
   if (Digits==3||Digits==5){
      close_low_0_pips/=10;
      close_low_1_pips/=10;
      close_high_0_pips/=10;
      close_high_1_pips/=10;
      mva1_close_pips/=10;
      mva2_close_pips/=10;
      mva3_close_pips/=10;
      mva4_close_pips/=10;
      mva5_close_pips/=10;
      mva6_close_pips/=10;
      mva7_close_pips/=10;
   }
   
   ObjectMakeLabel(IndicatorObjPrefix+"close_low_value",   40, 10, NormalizeDouble(close_low_0_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"close_low1_value",  40, 40, NormalizeDouble(close_low_1_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"close_high_value",  40, 70, NormalizeDouble(close_high_0_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"close_high1_value", 40, 100, NormalizeDouble(close_high_1_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva1_close_value",  40, 130, NormalizeDouble(mva1_close_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva2_close_value",  40, 160, NormalizeDouble(mva2_close_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva3_close_value",  40, 190, NormalizeDouble(mva3_close_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva4_close_value",  40, 220, NormalizeDouble(mva4_close_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva5_close_value",  40, 250, NormalizeDouble(mva5_close_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva6_close_value",  40, 280, NormalizeDouble(mva6_close_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   ObjectMakeLabel(IndicatorObjPrefix+"mva7_close_value",  40, 310, NormalizeDouble(mva7_close_pips,1)+" pips", clrYellow, 1, 0, "Arial", 13);
   
   return(0);

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

void Limpiar(){
   ObjectDelete(IndicatorObjPrefix+"close_low_lbl");
   ObjectDelete(IndicatorObjPrefix+"close_low1_lbl");
   ObjectDelete(IndicatorObjPrefix+"close_high_lbl");
   ObjectDelete(IndicatorObjPrefix+"close_high1_lbl");
   ObjectDelete(IndicatorObjPrefix+"mva1_close_lbl");
   ObjectDelete(IndicatorObjPrefix+"mva2_close_lbl");
   ObjectDelete(IndicatorObjPrefix+"mva3_close_lbl");
   ObjectDelete(IndicatorObjPrefix+"mva4_close_lbl");
   ObjectDelete(IndicatorObjPrefix+"mva5_close_lbl");
   ObjectDelete(IndicatorObjPrefix+"mva6_close_lbl");
   ObjectDelete(IndicatorObjPrefix+"mva7_close_lbl");
   ObjectDelete(IndicatorObjPrefix+"close_low_value");
   ObjectDelete(IndicatorObjPrefix+"close_low1_value");
   ObjectDelete(IndicatorObjPrefix+"close_high_value");
   ObjectDelete(IndicatorObjPrefix+"close_high1_value");
   ObjectDelete(IndicatorObjPrefix+"mva1_close_value");
   ObjectDelete(IndicatorObjPrefix+"mva2_close_value");
   ObjectDelete(IndicatorObjPrefix+"mva3_close_value");
   ObjectDelete(IndicatorObjPrefix+"mva4_close_value");
   ObjectDelete(IndicatorObjPrefix+"mva5_close_value");
   ObjectDelete(IndicatorObjPrefix+"mva6_close_value");
   ObjectDelete(IndicatorObjPrefix+"mva7_close_value");
}