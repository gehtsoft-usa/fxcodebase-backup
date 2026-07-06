// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65679

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

#property indicator_separate_window

extern string   Comment0                 = "- Parameters -";
extern int      Smooth1                  = 7;
extern int      Smooth2                  = 14;
extern string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern string   TimeFrames               = "5,15,30,60,240,1440,10080,43200";
extern color    Labels_Color             = clrWhite;
extern color    Up_Color                 = clrLime;
extern color    Dn_Color                 = clrRed;
extern color    Neutral_Color            = clrDarkGray;
extern int      Update_History_Every_Seconds   = 60;

int      i;
string   WindowName;
int      WindowNumber;

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

string TF_arr[]; // TimeFrames
int    TF_count; // Number of TFs

datetime Last_History_Process;

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
   
       double temp = iCustom(NULL, 0, "TSI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TSI' indicator");
       return INIT_FAILED;
   }
   WindowName = "MTF_MCP_TSI_List";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){
   
   if ( TimeCurrent()-Last_History_Process > Update_History_Every_Seconds ){
   
      WindowNumber = WindowFind(IndicatorName);
      
      int Pair_y = 50;
      int TF_x   =  1000;
      int Original_x = TF_x;
      
      split(Sym_arr, Pairs, ",");
      Sym_count = ArraySize(Sym_arr);
      split(TF_arr, TimeFrames, ",");
      TF_count = ArraySize(TF_arr);
      
      string TF_Label;
      
      for (i=0; i < TF_count; i++) {
         TF_Label = Get_TimeFrame_Label(StringToInteger(TF_arr[i]));
         ObjectMakeLabel(TF_Label+"_Label", TF_x, 20, TF_Label, Labels_Color, 1, WindowNumber, "Arial", 12 );
         TF_x = TF_x-120;
      }
      
      color  diff_color, slope_color;
      string slope;
      
      int j,period;
      double TSI0, TSI1;
      
      for (i=0; i < Sym_count; i++) {
         
         ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+120, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
         
         TF_x = Original_x;
         
         for (j=0; j < TF_count; j++) {
            
            TF_Label = Get_TimeFrame_Label(StringToInteger(TF_arr[j]));
            period = StringToInteger(TF_arr[j]);
            /**/       
            // TSI
            TSI0 = iCustom(Sym_arr[i],period,"TSI",Smooth1,Smooth2,0,0);
            TSI1 = iCustom(Sym_arr[i],period,"TSI",Smooth1,Smooth2,0,1);
            
            if (TSI0 > TSI1) diff_color = Up_Color;
            else if (TSI0 < TSI1) diff_color = Dn_Color;
            else diff_color = Neutral_Color;
            
            if (TSI0 > TSI1){
               slope_color = Up_Color;
               slope = "é";
            }else{
               slope_color = Dn_Color;
               slope = "ê";
            }          
            
            ObjectMakeLabel(Sym_arr[i]+"_"+TF_Label, TF_x, Pair_y, DoubleToStr(TSI0,2), diff_color, 1, WindowNumber, "Arial", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_slope_"+TF_Label, TF_x-30, Pair_y, slope, slope_color, 1, WindowNumber, "Wingdings", 10 );
            /**/
            TF_x = TF_x-120;
         }
         
         Pair_y = Pair_y+30;
         
      }
      
      Last_History_Process = TimeCurrent();
   
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