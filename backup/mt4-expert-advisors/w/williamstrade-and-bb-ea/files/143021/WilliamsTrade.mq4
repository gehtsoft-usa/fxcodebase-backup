// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71382

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 DodgerBlue
#property indicator_color3 Red
#property indicator_color4 Green

#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2

#property indicator_minimum -100
#property indicator_maximum 0

#property indicator_level1 -20
#property indicator_level2 -40
#property indicator_level3 -50
#property indicator_level4 -60
#property indicator_level5 -80

extern int       wperiod=2000;//williams percent
extern int       short_level=-60;//williams level to go short from
extern int       long_level=-40;//williams level to go long from
extern int       ma_period=21;//williams averaging curve
extern int       valid_bars_back=30;//Bars to look back as needed to be below or aabove trigger point
 
double ma[];
double maOnArray[];
double array[];
double arrow1[];
double arrow2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ma);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,maOnArray);


   
   //--------DRAW TWO ARROWS---+
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,234);//short arrow
   SetIndexBuffer(2,arrow1);
   SetIndexEmptyValue(2,0.0);
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,arrow2);
   SetIndexEmptyValue(3,0.0);
   //--name for DataWindow and indicator subwindow label---+
   IndicatorShortName("Williams_Trade");
   SetIndexLabel(0,"Williams_Trade");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
  //--------Tidies up after itself---+
      ObjectsDeleteAll(0,OBJ_ARROW);             
      ObjectDelete("highline");
      ObjectDelete("lowline");
      ObjectDelete("nowline");
      ObjectDelete("longit");
      ObjectDelete("shortit");
 return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   //--------Get the arrays ready for data and backward read---+
   ArrayResize(array, Bars);   
   ArraySetAsSeries(array, true);
   
   for(int i = Bars-1; i >= 0; i--){ 
          
      array[i] = iWPR(NULL,0,wperiod,i);
   }

   for( i = Bars-1-wperiod; i >= 0; i--)  
   {    
    ma[i]       =  iWPR(NULL,0,wperiod,i);
    maOnArray[i] = iMAOnArray(array, 0,ma_period, 0, 0, i);
   }
//--------Check for signals---+
for( i = Bars-1-wperiod; i >= 0; i--)
{
//short
      if(maOnArray[i]<maOnArray[i+1] && maOnArray[i]<short_level && maOnArray[i+1]>=short_level && maOnArray[i+valid_bars_back]> short_level+10)// 
      {
      arrow1[i]=ma[i];
       string name2 = "Dn"+i;
       ObjectCreate(name2,OBJ_ARROW, 0, Time[i], High[i]+20*Point); //draw a dn arrow
       ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
       ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
       ObjectSet(name2, OBJPROP_COLOR,Red);
      }
         else arrow1[i]=0.00;

//long
      if(maOnArray[i]>maOnArray[i+1] && maOnArray[i]>long_level && maOnArray[i+1]<=long_level && maOnArray[i+valid_bars_back]< long_level-10)//
      {
       arrow2[i]=ma[i];
       string name = "Up"+i;
       ObjectCreate(name, OBJ_ARROW, 0, Time[i], Low[i]-20*Point); //draw an up arrow
       ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
       ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
       ObjectSet(name, OBJPROP_COLOR,Blue);
      }
         else arrow2[i]=0.00;
  
}   
   
   
//---Trigger Visuals
   for( i = Bars-1-wperiod; i >= 0; i--)
   {
         
      ObjectDelete("nowline");
      ObjectDelete("highline");
      ObjectDelete("lowline");
      
      
      int windowIndex=WindowFind("Williams_Trade");  
      ObjectCreate("nowline",OBJ_HLINE,windowIndex,0,array[i]);
      ObjectSet("nowline",OBJPROP_COLOR,Orange);
      ObjectSet("nowline",OBJPROP_WIDTH,2);
      
      windowIndex=WindowFind("Williams_Trade");  
      ObjectCreate("highline",OBJ_HLINE,windowIndex,0,short_level);
      ObjectSet("highline",OBJPROP_COLOR,Crimson);
      ObjectSet("highline",OBJPROP_WIDTH,4);
      
      windowIndex=WindowFind("Williams_Trade");  
      ObjectCreate("lowline",OBJ_HLINE,windowIndex,0,long_level);
      ObjectSet("lowline",OBJPROP_COLOR,Green);
      ObjectSet("lowline",OBJPROP_WIDTH,4);
      WindowRedraw();
      }
   return(0);
  }//-------------Done Mum---------------------------------+