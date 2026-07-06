// Id: 19179
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65018

//+------------------------------------------------------------------+
//|                                         MTF_MCP_ADX_DMI_List.mq4 |
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

extern int      ADX_Period             = 14;
extern int      ADX_Level              = 20;
extern string   Comment1               = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                  = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M5             = true;
extern bool     Include_M15            = true;
extern bool     Include_M30            = true;
extern bool     Include_H1             = true;
extern bool     Include_H4             = true;
extern bool     Include_D1             = true;
extern bool     Include_W1             = true;
extern bool     Include_MN1            = true;
extern color    Labels_Color           = clrWhite;
extern color    Up_Arrow_Color         = clrLime;
extern color    Dn_Arrow_Color         = clrRed;
extern color    Neutral_Arrow_Color    = clrDarkGray;
extern color    All_Sync_Color         = clrYellow;
extern bool     Alert_ON               = true;
extern int      Alert_Minutes_Interval = 15;

int      i;
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
   
   WindowName = "MTF_MCP_ADX_DMI_List";
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
   
   WindowNumber = WindowFind(WindowName);
   
   int Pair_y = 50;
   int TF_x   =  1000;
   int Original_x = TF_x;
   
   if (Include_M5){
      int M5_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M5_Label", M5_x-20, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M15){
      int M15_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M15_Label", M15_x-30, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M30){
      int M30_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M30_Label", M30_x-30, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H1){
      int H1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H1_Label", H1_x-20, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H4){
      int H4_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H4_Label", H4_x-20, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_D1){
      int D1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("D1_Label", D1_x-20, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_W1){
      int W1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("W1_Label", W1_x-20, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_MN1){
      int MN1_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("MN1_Label", MN1_x-30, 20, "MN1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   int  TFs, Ups, Dns;
   bool Alerts_Found=false;
   
   double adx0, adx1, dmip, dmim;
   
   for (i=0; i < Sym_count; i++) {
   
      TFs = 0;
      Ups = 0;
      Dns = 0;
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+50, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         adx0 = iADX(Sym_arr[i],PERIOD_M5,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_M5,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_M5,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_M5,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_M5plus", M5_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_M5sep", M5_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_M5minus", M5_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      if (Include_M15){
         adx0 = iADX(Sym_arr[i],PERIOD_M15,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_M15,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_M15,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_M15,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_M15plus", M15_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_M15sep", M15_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_M15minus", M15_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_M15-", M15_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      if (Include_M30){
         adx0 = iADX(Sym_arr[i],PERIOD_M30,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_M30,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_M30,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_M30,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_M30plus", M30_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_M30sep", M30_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_M30minus", M30_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      if (Include_H1){
         adx0 = iADX(Sym_arr[i],PERIOD_H1,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_H1,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_H1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_H1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_H1plus", H1_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_H1sep", H1_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_H1minus", H1_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      if (Include_H4){
         adx0 = iADX(Sym_arr[i],PERIOD_H4,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_H4,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_H4,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_H4,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_H4plus", H4_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_H4sep", H4_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_H4minus", H4_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      if (Include_D1){
         adx0 = iADX(Sym_arr[i],PERIOD_D1,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_D1,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_D1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_D1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_D1plus", D1_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_D1sep", D1_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_D1minus", D1_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      if (Include_W1){
         adx0 = iADX(Sym_arr[i],PERIOD_W1,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_W1,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_W1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_W1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_W1plus", W1_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_W1sep", W1_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_W1minus", W1_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      if (Include_MN1){
         adx0 = iADX(Sym_arr[i],PERIOD_MN1,ADX_Period,PRICE_CLOSE,MODE_MAIN,0);
         adx1 = iADX(Sym_arr[i],PERIOD_MN1,ADX_Period,PRICE_CLOSE,MODE_MAIN,1);
         dmip = iADX(Sym_arr[i],PERIOD_MN1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_MN1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         ObjectMakeLabel(Sym_arr[i]+"_MN1plus", MN1_x, Pair_y, DoubleToStr(dmip,2), Up_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_MN1sep", MN1_x-8, Pair_y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9 );
         ObjectMakeLabel(Sym_arr[i]+"_MN1minus", MN1_x-43, Pair_y, DoubleToStr(dmim,2), Dn_Arrow_Color, 1, WindowNumber, "Arial", 9 );
         if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim){
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x-60, Pair_y, "é", Up_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim){
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x-60, Pair_y, "ê", Dn_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x-60, Pair_y, "û", Neutral_Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         TFs++;
      }
      
      // All Sync Mark
      if (Ups==TFs || Dns==TFs)
         ObjectMakeLabel(Sym_arr[i]+"_Sync", Original_x+130, Pair_y, "è", All_Sync_Color, 1, WindowNumber, "Wingdings", 12 );
      else
         ObjectDelete(Sym_arr[i]+"_Sync");
      
      if (Alert_ON && (TimeCurrent()-LastAlert) > (Alert_Minutes_Interval*60)){
         
         if (Ups==TFs || Dns==TFs){
            if (Ups==TFs)
               Alert(Sym_arr[i] + " All TFs in Sync for the Up - ADX/DMI");
            else
               Alert(Sym_arr[i] + " All TFs in Sync for the Down - ADX/DMI");
            Alerts_Found = true;
         }
      }
      
      Pair_y = Pair_y+30;
      
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