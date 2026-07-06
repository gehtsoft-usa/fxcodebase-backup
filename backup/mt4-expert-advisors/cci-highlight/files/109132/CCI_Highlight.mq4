//+------------------------------------------------------------------+
//|                                                CCI_Highlight.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 7
#property indicator_separate_window
#property indicator_width1 3
#property indicator_color1 clrGreen
#property indicator_width2 3
#property indicator_color2 clrMaroon
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 2
#property indicator_color5 clrYellow
#property indicator_width6 2
#property indicator_color6 clrLime
#property indicator_width7 2
#property indicator_color7 clrRed
#property indicator_levelcolor clrDarkGray
#property indicator_levelwidth 0
#property indicator_levelstyle STYLE_DOT

extern int CCI_Period     = 17;
extern int CCI_OverBought = 100;
extern int CCI_OverSold   = -100;

double CCI[];
double CCI_Up[];
double CCI_Dn[];
double CCI_HistoUp[];
double CCI_HistoDn[];
double CCI_HistoUp_BG[];
double CCI_HistoDn_BG[];

int init(){
   
   IndicatorShortName("CCI Highlight");
   
   color BGColor = BackgroundColor();
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,CCI_HistoUp);
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,CCI_HistoDn);
   
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,BGColor);
   SetIndexBuffer(2,CCI_HistoUp_BG);
   
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,BGColor);
   SetIndexBuffer(3,CCI_HistoDn_BG);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,CCI);
   SetIndexLabel(4,"CCI");
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,CCI_Up);
   SetIndexLabel(5,"CCI Up");
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,CCI_Dn);
   SetIndexLabel(6,"CCI Down");
   
   
   
   
   SetLevelValue(0,CCI_OverBought);
   SetLevelValue(1,CCI_OverSold);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int cci_color = 0;
   
   for(i=limit; i>=0; i--){

      CCI[i] = iCCI(NULL,0,CCI_Period,PRICE_TYPICAL,i);
      
      if (CCI[i] > CCI_OverBought && CCI[i+1] < CCI_OverBought) cci_color = 1;
      if (CCI[i] < CCI_OverSold   && CCI[i+1] > CCI_OverSold)   cci_color = 0;
      
      if (cci_color==1){
         CCI_Up[i] = CCI[i];
         CCI_Dn[i] = EMPTY_VALUE;
      }
      else{
         CCI_Dn[i] = CCI[i];
         CCI_Up[i] = EMPTY_VALUE;
      }
      
      if (CCI[i] > CCI_OverBought){
         CCI_HistoUp[i] = CCI[i];
         CCI_HistoUp_BG[i] = CCI_OverBought;
      }
      
      if (CCI[i] < CCI_OverSold){
         CCI_HistoDn[i] = CCI[i];
         CCI_HistoDn_BG[i] = CCI_OverSold;
      }
         
   }
   
//----
   return(0);
}
  
color BackgroundColor(){
   long bgcolor=clrNONE;
   ResetLastError();
   if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,bgcolor)){
      Print(__FUNCTION__+", Error_Code = ",GetLastError());
   }
   return((color)bgcolor);
}