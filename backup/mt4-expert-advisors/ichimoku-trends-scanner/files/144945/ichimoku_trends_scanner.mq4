// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71855

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
extern string  comment1   =  "-Comma Seprated Pairs -Ex:EURUSD, EURJPY, GBPUSD";
extern  string Pairs    = "EURUSD,EURJPY,USDJPY,GBPUSD";
extern  bool  Include_M1  =  true;
extern  bool  Include_M5  =   true;
extern  bool  Include_M15  =  true;
extern  bool  Include_M30  =  true;
extern  bool  Include_H1  =  true;
extern  bool  Include_H4  =  true;
extern  bool  Include_D1  =  true;
extern  bool  Include_W1  =  true;
extern  bool  Include_MN1  =  true;
extern  color Labels_color  =  clrRed ;
extern  color  Labels_Background_Color    =  clrPurple;
extern   color Up_Color   =  clrGreen;
extern   color Down_Color   =  clrRed;
extern  color   Neutral_Color   = clrBlue;
int    time_array[]  ;
string    time_array_label[]  ;
string  currency_pair_mapping [ ]  ;
extern  string s1   =  "Indicator Propery Setting"  ;
extern  int    Tenken_Sen  =  9;
extern   int Kijun_Sen   =  26;
extern  int SenkouSpanB  =  52;
int  index   = 0 ;
datetime  NewCandleTimeCurrent   ;
extern int XOffset=2;                  //Horizontal offset (pixels)
extern int YOffset=20;                  //Vertical offset (pixels)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   XOffset=2;
   YOffset=20;
   ArrayResize(time_array, 0);
   ArrayResize(time_array_label, 0);
   ArrayResize(currency_pair_mapping,   0) ;
   if(Include_M1   ==  true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_M1;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="M1";
     }
   if(Include_M5   ==   true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_M5;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="M5";
     }

   if(Include_M15   ==   true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_M15;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="M15";
     }

   if(Include_M30    == true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_M30;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="M30";
     }


   if(Include_H1    == true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_H1;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="H1";
     }

   if(Include_H4    ==  true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_H4;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="H4";
     }

   if(Include_D1    == true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_D1;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="D1";
     }

   if(Include_W1     ==   true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_W1;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="W1";
     }

   if(Include_MN1    ==  true)
     {
      ArrayResize(time_array,ArraySize(time_array)+1);
      time_array[ArraySize(time_array) -1]  =PERIOD_MN1;
      ArrayResize(time_array_label,ArraySize(time_array_label)+1);
      time_array_label[ArraySize(time_array_label) -1]  ="MN1";
     }
   string output[];
   int i;
   int k = StringSplit(Pairs, StringGetCharacter(",", 0), output);
   if(k > 1)
     {
      for(int   k=    0 ;   k <   ArraySize(output)  ;   k++)
        {
         ArrayResize(currency_pair_mapping,ArraySize(currency_pair_mapping)+1);
         currency_pair_mapping[ArraySize(currency_pair_mapping) -1]  =output[k];
        }
     }
   fX_ui_handle();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
   if(IsNewCandleCurrent())
     {
      fX_ui_handle() ;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandleCurrent()
  {
   if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 0))
      return false;
   else
     {
      NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 0);
      return true;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fX_ui_handle()
  {
   for(int   i  =    0  ;   i  <    ArraySize(time_array)   ;  i++)
     {
      ObjectDelete("PanelLabel"   +time_array[i]);
      int        x_size    =   40 ;
      int    y_size  =     19;
      ObjectCreate(0,"PanelLabel"+  time_array[i],OBJ_EDIT,0,0,0);
      ObjectSet("PanelLabel"+  time_array[i],OBJPROP_XDISTANCE,XOffset+2   +   40*i  +   3*i);
      ObjectSet("PanelLabel"+  time_array[i],OBJPROP_YDISTANCE,YOffset+2);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_XSIZE,x_size);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_YSIZE,y_size);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_STATE,false);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_HIDDEN,false);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_READONLY,true);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_ALIGN,ALIGN_CENTER);
      ObjectSetString(0,"PanelLabel"+  time_array[i],OBJPROP_TEXT,   time_array_label[i]);
      ObjectSetString(0,"PanelLabel"+  time_array[i],OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_FONTSIZE,12);
      ObjectSet("PanelLabel"+  time_array[i],OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_COLOR,Labels_color);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_BGCOLOR,Labels_Background_Color);
      ObjectSetInteger(0,"PanelLabel"+  time_array[i],OBJPROP_BORDER_COLOR,clrBlack);
     }
   for(int   j  =    0  ;   j  <   ArraySize(currency_pair_mapping)   ;  j++)
     {
      for(int   i  =    0  ;   i  <    ArraySize(time_array)   ;  i++)
        {
         ObjectDelete("PanelLabel"   +time_array[i] +   currency_pair_mapping[j]);
         int        x_size    =   40       ;
         int    y_size  =     19    ;

         ObjectCreate(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJ_EDIT,0,0,0);
         ObjectSet("PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_XDISTANCE,XOffset+2   +   40*i  +   3*i);
         ObjectSet("PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_YDISTANCE,YOffset+2   + (j ==   0  ?   1 :  j +1)   *20);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_XSIZE,x_size);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_YSIZE,y_size);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_STATE,false);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_HIDDEN,false);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_READONLY,true);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_ALIGN,ALIGN_CENTER);
         ObjectSetString(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_TEXT,  fx_mapping_data(time_array[i],   currency_pair_mapping[j]));
         ObjectSetString(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_FONT,"Consolas");
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_FONTSIZE,12);
         ObjectSet("PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_COLOR,   fx_mapping_data(time_array[i],   currency_pair_mapping[j])   ==  "SELL" ?   Down_Color  : (fx_mapping_data(time_array[i],   currency_pair_mapping[j]) == "BUY" ?  Up_Color  : Neutral_Color));
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_BGCOLOR,clrWhite);
         ObjectSetInteger(0,"PanelLabel"+  time_array[i] +   currency_pair_mapping[j],OBJPROP_BORDER_COLOR,clrBlack);

         // if  ( j){
         int    x_size_data    =   90       ;
         int    y_size_data  =     19    ;

         ObjectCreate(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJ_EDIT,0,0,0);
         ObjectSet("PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_XDISTANCE,XOffset+2   +   40*i  +  50  +   3*i  +  10);
         ObjectSet("PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_YDISTANCE,YOffset+2   + (j ==   0  ?   1 :  j +1)   *20);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_XSIZE,x_size_data);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_YSIZE,y_size_data);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_STATE,false);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_HIDDEN,false);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_READONLY,true);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_ALIGN,ALIGN_CENTER);
         ObjectSetString(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_TEXT,   currency_pair_mapping[j]);
         ObjectSetString(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_FONT,"Consolas");
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_FONTSIZE,12);
         ObjectSet("PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_COLOR,clrBlack);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_BGCOLOR,clrWhite);
         ObjectSetInteger(0,"PanelLabelPair"+  currency_pair_mapping[j],OBJPROP_BORDER_COLOR,clrBlack);


        }

     }

   return   0 ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   fx_mapping_data(string   timeframe, string   currency_mapping)
  {
   return  fx_handling_ichimoku(currency_mapping,   timeframe);


   return   0   ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   fx_delete_ui()
  {
   for(int   i  =    0  ;   i  <    ArraySize(time_array)   ;  i++)
     {
      ObjectDelete("PanelLabel"   +time_array[i]);
     }
   return     0 ;
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int   i    =0    ;  i <    ArraySize(time_array)  ;     i++)
     {
      ObjectDelete("PanelLabel"   +time_array[i]);
     }
   for(int   j  =    0  ;   j  <   ArraySize(currency_pair_mapping)   ;  j++)
     {
      for(int   i  =    0  ;   i  <    ArraySize(time_array)   ;  i++)
        {
         ObjectDelete("PanelLabel"   +time_array[i] +   currency_pair_mapping[j]);
         ObjectDelete("PanelLabelPair"   +time_array[i] +   currency_pair_mapping[j]);
         ObjectDelete("PanelLabelPair"   +   currency_pair_mapping[j]);
        }
     }
   ArrayResize(time_array, 0);
   ArrayResize(time_array_label, 0);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fx_handling_ichimoku(string  symbol_mapping,  int   timeframe)
  {
   double CURRENT_SENKOUSPANA=iIchimoku(symbol_mapping,timeframe,Tenken_Sen,Kijun_Sen,SenkouSpanB,MODE_SENKOUSPANA,1);
   double CURRENT_SENKOUSPANB=iIchimoku(symbol_mapping,timeframe,Tenken_Sen,Kijun_Sen,SenkouSpanB,MODE_SENKOUSPANB,1);
   double TENKANSEN=iIchimoku(symbol_mapping,timeframe,Tenken_Sen,Kijun_Sen,SenkouSpanB,MODE_TENKANSEN,1);
   double KIJUNSEN=iIchimoku(symbol_mapping,timeframe,Tenken_Sen,Kijun_Sen,SenkouSpanB,MODE_KIJUNSEN,1);
   double CHIKOUSPAN  =iIchimoku(symbol_mapping,timeframe,Tenken_Sen,Kijun_Sen,SenkouSpanB,MODE_CHIKOUSPAN,Kijun_Sen);
   if(fx_l1(CURRENT_SENKOUSPANA, CURRENT_SENKOUSPANB, symbol_mapping) ==  true  &&   fx_l2(TENKANSEN,   KIJUNSEN, CURRENT_SENKOUSPANA, CURRENT_SENKOUSPANB, symbol_mapping)   &&   fx_l3(TENKANSEN,   KIJUNSEN, symbol_mapping)      &&    fx_l4(CHIKOUSPAN,    CURRENT_SENKOUSPANA,  CURRENT_SENKOUSPANB, symbol_mapping, timeframe))
     {
      return  "BUY";
     }
   if(fx_l1_sell(CURRENT_SENKOUSPANA, CURRENT_SENKOUSPANB, symbol_mapping) ==  true  &&   fx_l2_sell(TENKANSEN,   KIJUNSEN, CURRENT_SENKOUSPANA, CURRENT_SENKOUSPANB,  symbol_mapping)  &&   fx_l3_sell(TENKANSEN,   KIJUNSEN, symbol_mapping)      &&    fx_l4_sell(CHIKOUSPAN,    CURRENT_SENKOUSPANA,  CURRENT_SENKOUSPANB,  symbol_mapping, timeframe))
     {
      return  "SELL";
     }
   return  "N" ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double    fx_bidder(string symbol_mapping)
  {
   return  MarketInfo(symbol_mapping, MODE_BID);
   return   0 ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   fx_l1(double SpanA,  double  SpanB,    string    symbol_mapping)
  {
   if(fx_bidder(symbol_mapping)    >  SpanA     &&   fx_bidder(symbol_mapping)    >    SpanB)
     {
      return  true;
     }
   return   false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  fx_l2(double  tensen,    double      kijusen,  double SpanA,  double  SpanB,    string   symbol_mapping)
  {
   if(tensen  >=  SpanA   &&  tensen    >= SpanB   &&    kijusen >=   SpanA   &&  kijusen >=  SpanB)
     {
      return    true  ;
     }
   return      false  ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  fx_l3(double  tensen,    double      kijusen,  string    symbol_mapping)
  {
   if(fx_bidder(symbol_mapping)   >      tensen  &&   tensen  >   kijusen)
     {
      return   true  ;

     }

   return    false  ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool    fx_l4(double    chiku,  double   SpanA,  double  SpanB,    string  symbol_mapping, string timeframe)
  {
   if(chiku      >  iHigh(symbol_mapping,timeframe,Kijun_Sen))
     {
      return   true  ;
     }
   return   false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  fx_l1_sell(double  SpanA,  double   SpanB,  string  symbol_mapping)
  {

   if(fx_bidder(symbol_mapping)    <  SpanA      &&   fx_bidder(symbol_mapping)    <   SpanB)
     {

      return  true  ;
     }

   return  false ;


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  fx_l2_sell(double  tensen,    double      kijusen,  double SpanA,  double  SpanB, string  symbol_mapping)
  {
   if(tensen  <=  SpanA   &&  tensen    <= SpanB   &&    kijusen <=   SpanA   &&  kijusen <=  SpanB)
     {
      return    true  ;
     }
   return      false  ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  fx_l3_sell(double  tensen,    double      kijusen, string  symbol_mapping)
  {
   if(fx_bidder(symbol_mapping)   <     tensen  &&   tensen <   kijusen)
     {
      return   true  ;
     }
   return    false  ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool    fx_l4_sell(double    chiku,  double   SpanA,  double  SpanB,  string symbol_mapping, string timeframe)
  {
   if(chiku     <   iLow(symbol_mapping,timeframe,Kijun_Sen))
     {
      return   true  ;
     }
   return   false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double    fx_asker(string symbol_mapping)
  {
   return  MarketInfo(symbol_mapping, MODE_ASK);
   return   0 ;
  }

//+------------------------------------------------------------------+
