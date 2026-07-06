// Id: 18211
//+------------------------------------------------------------------+
//|                                                   MTF_CCI_MA.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "This indicator analyzed the position of price with a determined moving average"
#property description "in a multi time frame mode and also the position of the CCI in regards of"
#property description "buying and selling levels also in MTF mode."
#property description "Colored slope and arrows for position of price/MA and CCI/Levels"

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern string   Comment0               = "<< Moving Average Parameters: >>";
extern int      MA_Period              = 100;
input  e_method MA_Method              = EMA;
input  e_price  MA_Price               = CLOSE;
extern string   Comment1               = "<< CCI Parameters: >>";
extern int      CCI_Period             = 100;
extern double   CCI_BuyLevel           = 0.0;
extern double   CCI_SellLevel          = 0.0;
extern bool     Include_M5             = true;
extern bool     Include_M15            = true;
extern bool     Include_M30            = true;
extern bool     Include_H1             = true;
extern bool     Include_H4             = true;
extern bool     Include_D1             = true;
extern bool     Include_W1             = true;
extern bool     Include_MN1            = true;
extern color    Labels_Color           = clrWhite;
extern color    Up_Slope_Color         = clrLime;
extern color    Dn_Slope_Color         = clrRed;
extern color    All_Sync_Color         = clrYellow;
extern bool     Alert_ON               = true;
extern int      Alert_Minutes_Interval = 15;

int      i, j;
datetime LastAlert;
string   WindowName;
int      WindowNumber;

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

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
   
   WindowName = "MTF_CCI_MA";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
  {
   
   //WindowNumber = WindowFind(WindowName);
   WindowNumber = 0;
   
   int Pair_y = 50;
   int TF_x   =  600;
   int Original_x = TF_x;
   
   if (Include_M5){
      int M5_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("M5_Label", M5_x, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M15){
      int M15_x = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("M15_Label", M15_x, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M30){
      int M30_x = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("M30_Label", M30_x, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H1){
      int H1_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("H1_Label", H1_x, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H4){
      int H4_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("H4_Label", H4_x, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_D1){
      int D1_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("D1_Label", D1_x, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_W1){
      int W1_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("W1_Label", W1_x, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_MN1){
      int MN1_x = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("MN1_Label", MN1_x, 20, "MN1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   
   int  TFs, Ups, Dns;
   bool Alerts_Found=false;
   
   TFs = 0;
   Ups = 0;
   Dns = 0;
   
   ObjectMakeLabel("MA_Name",  Original_x+50, 50, "Price/MA", Labels_Color, 1, WindowNumber, "Arial", 12 );
   ObjectMakeLabel("CCI_Name", Original_x+50, 80, "CCI", Labels_Color, 1, WindowNumber, "Arial", 12 );
   
   color cci_color, ma_color;
   string cci_arrow, ma_arrow;
   
   if (Include_M5){
      if (Close[0] > iMA(NULL ,PERIOD_M5, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_M5, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_M5, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_M5, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_M5, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_M5, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_M5, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_M5", M5_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_M5", M5_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   if (Include_M15){
      if (Close[0] > iMA(NULL ,PERIOD_M15, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_M15, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_M15, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_M15, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_M15, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_M15, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_M15, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_M15", M15_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_M15", M15_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   if (Include_M30){
      if (Close[0] > iMA(NULL ,PERIOD_M30, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_M30, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_M30, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_M30, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_M30, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_M30, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_M30, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_M30", M30_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_M30", M30_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   if (Include_H1){
      if (Close[0] > iMA(NULL ,PERIOD_H1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_H1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_H1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_H1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_H1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_H1, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_H1, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_H1", H1_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_H1", H1_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   if (Include_H4){
      if (Close[0] > iMA(NULL ,PERIOD_H4, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_H4, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_H4, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_H4, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_H4, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_H4, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_H4, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_H4", H4_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_H4", H4_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   if (Include_D1){
      if (Close[0] > iMA(NULL ,PERIOD_D1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_D1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_D1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_D1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_D1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_D1, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_D1, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_D1", D1_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_D1", D1_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   if (Include_W1){
      if (Close[0] > iMA(NULL ,PERIOD_W1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_W1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_W1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_W1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_W1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_W1, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_W1, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_W1", W1_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_W1", W1_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   if (Include_MN1){
      if (Close[0] > iMA(NULL ,PERIOD_MN1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0)) ma_arrow = "é"; else ma_arrow = "ê";
      if (CCI_BuyLevel < iCCI(NULL ,PERIOD_MN1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "é";
      else if (CCI_SellLevel > iCCI(NULL ,PERIOD_MN1, CCI_Period,PRICE_TYPICAL,0)) cci_arrow = "ê";
      else cci_arrow = "l";
      if (iMA(NULL ,PERIOD_MN1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 0) > iMA(NULL ,PERIOD_MN1, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price), 1)) ma_color = Up_Slope_Color; else ma_color = Dn_Slope_Color;
      if (iCCI(NULL ,PERIOD_MN1, CCI_Period,PRICE_TYPICAL,0) > iCCI(NULL ,PERIOD_MN1, CCI_Period,PRICE_TYPICAL,1)) cci_color = Up_Slope_Color; else cci_color = Dn_Slope_Color;
      ObjectMakeLabel("MA_MN1", MN1_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("CCI_MN1", MN1_x, 80, cci_arrow, cci_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && cci_arrow=="é") Ups++;
      if (ma_arrow=="ê" && cci_arrow=="ê") Dns++;
      TFs++;
   }
   
   // All Sync Mark
   if (Ups==TFs || Dns==TFs)
      ObjectMakeLabel("All_Sync", Original_x+130, Pair_y, "è", All_Sync_Color, 1, WindowNumber, "Wingdings", 12 );
   else
      ObjectDelete("All_Sync");
   
   if (Alert_ON && (TimeCurrent()-LastAlert) > (Alert_Minutes_Interval*60)){
      
      if (Ups==TFs || Dns==TFs){
         if (Ups==TFs)
            Alert(Sym_arr[i] + " All TFs in Sync for the Up - Price Above MA and CCI Above Zero");
         else
            Alert(Sym_arr[i] + " All TFs in Sync for the Down - Price Below MA and CCI Below Zero");
         Alerts_Found = true;
      }
   }
   
   if (Alerts_Found){
      LastAlert = TimeCurrent();
   }
   
//----
   return(0);
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
