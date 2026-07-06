// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65322

//+------------------------------------------------------------------+
//|                                             MTF_MCP_TDI_List.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window

extern int      RSI_Period               = 13;
extern int      Volatility_Band          = 34;
extern int      RSI_Price_Line           = 2;
extern int      Trade_Signal_Line        = 7;
extern double   Buy_Exit_Level           = 70;
extern double   Sell_Exit_Level          = 30;
extern double   Buy_Entry_Level          = 50;
extern double   Sell_Entry_Level          = 50;
extern string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M5               = true;
extern bool     Include_M15              = true;
extern bool     Include_M30              = true;
extern bool     Include_H1               = true;
extern bool     Include_H4               = true;
extern bool     Include_D1               = true;
extern bool     Include_W1               = true;
extern bool     Include_MN1              = true;
extern color    Labels_Color             = clrWhite;
extern color    Up_Color                 = clrLime;
extern color    Dn_Color                 = clrRed;
extern color    Neutral_Color            = clrDarkGray;

int      i;
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
   
       double temp = iCustom(NULL, 0, "Traders_Dynamic_Index", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Traders_Dynamic_Index' indicator");
       return INIT_FAILED;
   }
   WindowName = "MTF_MCP_TDI_List";
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
   
   WindowNumber = WindowFind(IndicatorName);
   
   int Pair_y = 50;
   int TF_x   =  1000;
   int Original_x = TF_x;
   
   if (Include_M5){
      int M5_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M5_Label", M5_x, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M15){
      int M15_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M15_Label", M15_x, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M30){
      int M30_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M30_Label", M30_x, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H1){
      int H1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H1_Label", H1_x, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H4){
      int H4_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H4_Label", H4_x, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_D1){
      int D1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("D1_Label", D1_x, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_W1){
      int W1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("W1_Label", W1_x, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_MN1){
      int MN1_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("MN1_Label", MN1_x, 20, "MN1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   double divisor;
      
   string arrow;
   color  diff_color;
   
   double price_line, signal_line, base_line, upper_band, lower_band;
   
   for (i=0; i < Sym_count; i++) {
   
      if (MarketInfo(Sym_arr[i],MODE_DIGITS)==3||MarketInfo(Sym_arr[i],MODE_DIGITS)==5)
         divisor = 10;
      else
         divisor = 1;
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+80, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         price_line = iCustom(Sym_arr[i],PERIOD_M5,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_M5,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_M5,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_M5,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_M15){
         price_line = iCustom(Sym_arr[i],PERIOD_M15,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_M15,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_M15,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_M15,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_M30){
         price_line = iCustom(Sym_arr[i],PERIOD_M30,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_M30,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_M30,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_M30,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_H1){
         price_line = iCustom(Sym_arr[i],PERIOD_H1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_H1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_H1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_H1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_H4){
         price_line = iCustom(Sym_arr[i],PERIOD_H4,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_H4,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_H4,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_H4,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_D1){
         price_line = iCustom(Sym_arr[i],PERIOD_D1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_D1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_D1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_D1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_W1){
         price_line = iCustom(Sym_arr[i],PERIOD_W1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_W1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_W1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_W1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_MN1){
         price_line = iCustom(Sym_arr[i],PERIOD_MN1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,4,0);
         signal_line = iCustom(Sym_arr[i],PERIOD_MN1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,5,0);
         upper_band = iCustom(Sym_arr[i],PERIOD_MN1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,1,0);
         lower_band = iCustom(Sym_arr[i],PERIOD_MN1,"Traders_Dynamic_Index",RSI_Period,Volatility_Band,RSI_Price_Line,Trade_Signal_Line,100,3,0);
         base_line   = (upper_band+lower_band)/2;        
         if (price_line > signal_line && signal_line > base_line && base_line > Buy_Entry_Level && price_line < upper_band && price_line < Buy_Exit_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (price_line < signal_line && signal_line < base_line && base_line < Sell_Entry_Level && price_line > lower_band && price_line > Sell_Exit_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      
      Pair_y = Pair_y+30;
      
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

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (i=0; i < len;) {
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