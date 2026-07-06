//+------------------------------------------------------------------+
//|                                           Rubicons_CCI_Cross.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_separate_window

#property indicator_buffers    4
#property indicator_levelcolor clrMagenta

extern int    CCI_Period   = 10;
extern int    EMA_Period   = 3;
extern double CCI_OB_Level = 100;
extern double CCI_OS_Level = -100;
extern color  CCI_Color    = clrDodgerBlue;
extern color  EMA_Color    = clrYellow;
extern color  Up_Signal    = clrLime;
extern color  Dn_Signal    = clrRed;

double CCI[];
double EMA[];
double up[];
double dn[];

int init(){
   
   IndicatorShortName("Rubicons_CCI_Cross");
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,CCI_Color);
   SetIndexBuffer(0,CCI);
   SetIndexLabel(0,"CCI");
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,EMA_Color);
   SetIndexBuffer(1,EMA);
   SetIndexLabel(1,"EMA");
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,Up_Signal);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,up);
   SetIndexLabel(2,"Up Signal");
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,Dn_Signal);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,dn);
   SetIndexLabel(3,"Dn Signal");
   
   SetLevelValue(0,CCI_OB_Level);
   SetLevelValue(1,CCI_OS_Level);
   SetLevelStyle(STYLE_SOLID,1);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      
      CCI[i] = iCCI(NULL,0,CCI_Period,PRICE_TYPICAL,i);
      EMA[i] = iMAOnArray(CCI,WHOLE_ARRAY,EMA_Period,0,MODE_EMA,i);
      
      if (CCI[i+1] < CCI_OS_Level && CCI[i] > CCI_OS_Level && EMA[i] < CCI[i]) up[i] = CCI_OS_Level-20;
      if (CCI[i+1] > CCI_OB_Level && CCI[i] < CCI_OB_Level && EMA[i] > CCI[i]) dn[i] = CCI_OB_Level+20;
         
   }
   
//----
   return(0);
}
  
