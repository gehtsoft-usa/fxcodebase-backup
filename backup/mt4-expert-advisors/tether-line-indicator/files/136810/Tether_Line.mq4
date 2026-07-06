 
#property copyright "Star"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrRed
#property indicator_color2 clrBlue
#property indicator_color3 clrRed
#property indicator_color4 clrBlue
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property strict

double Buf_0[];
double Buf_1[];
double Buf_2[];
double UpArrows[];
double DownArrows[];

extern int Length = 55;

int OnInit()
  {
   SetIndexBuffer(0,Buf_0);
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID,4);
   SetIndexBuffer(1,Buf_1);
   SetIndexStyle (1,DRAW_LINE,STYLE_SOLID,4);
   //---
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,UpArrows);
   SetIndexLabel(2,"Arrow Up");
//---
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,DownArrows);
   SetIndexLabel(3,"Arrow Down");
//---
   return(INIT_SUCCEEDED);
  }

double HighestCandle(int position)
  {
  double high[];
  CopyHigh(_Symbol,PERIOD_CURRENT,position,Length,high);
  return high[ArrayMaximum(high)];
  }
  
double LowestCandle(int position)
  {
  double  low[];
  CopyLow(_Symbol,PERIOD_CURRENT,position,Length,low);
  return low[ArrayMinimum(low)];   
  }

int start()
  {
  
   int i;                          
   int Counted_bars;                
   Counted_bars=IndicatorCounted(); 
   i=Bars-Counted_bars-1;  
           
   while(i>=0)                      
     {
      Buf_0[i]=EMPTY_VALUE;
      Buf_1[i]=EMPTY_VALUE;
      //Buf_2[i]=(HighestCandle(i)+LowestCandle(i))/2;
      UpArrows[i]=EMPTY_VALUE;
      DownArrows[i]=EMPTY_VALUE;
      if(iClose(_Symbol,PERIOD_CURRENT,i)>(HighestCandle(i)+LowestCandle(i))/2){
         Buf_0[i]=(HighestCandle(i)+LowestCandle(i))/2;
         //Buf_2[i]=Buf_0[i];
         //UpArrows[i]=NormalizeDouble(Low[i]-100*Point,Digits);
      }
      else if(iClose(_Symbol,PERIOD_CURRENT,i)<(HighestCandle(i)+LowestCandle(i))/2){
         Buf_1[i]=(HighestCandle(i)+LowestCandle(i))/2;
         //Buf_2[i]=Buf_1[i];
         //DownArrows[i]=NormalizeDouble(High[i]+100*Point,Digits);
      }
      /*
      if(iClose(_Symbol,PERIOD_CURRENT,i)>Buf_0[i] && iClose(_Symbol,PERIOD_CURRENT,i+1)<=Buf_0[i] && iClose(_Symbol,PERIOD_CURRENT,i+2)<=Buf_0[i] && iClose(_Symbol,PERIOD_CURRENT,i+3)<=Buf_0[i])
      //if(iClose(_Symbol,PERIOD_CURRENT,i)>Buf_0[i] && iClose(_Symbol,PERIOD_CURRENT,i+1)>Buf_0[i] && iClose(_Symbol,PERIOD_CURRENT,i+2)<=Buf_0[i])
      {
         UpArrows[i]=NormalizeDouble(Low[i]-100*Point,Digits);
         //DownArrows[i]=EMPTY_VALUE;
      }
      else if(iClose(_Symbol,PERIOD_CURRENT,i)<Buf_1[i] && iClose(_Symbol,PERIOD_CURRENT,i+1)>=Buf_1[i] && iClose(_Symbol,PERIOD_CURRENT,i+2)>=Buf_1[i] && iClose(_Symbol,PERIOD_CURRENT,i+3)>=Buf_1[i]){
      //else if(iClose(_Symbol,PERIOD_CURRENT,i)<Buf_1[i] && iClose(_Symbol,PERIOD_CURRENT,i+1)<Buf_1[i] && iClose(_Symbol,PERIOD_CURRENT,i+2)>=Buf_1[i]){
         DownArrows[i]=NormalizeDouble(High[i]+100*Point,Digits);
         //UpArrows[i]=EMPTY_VALUE;
      }
      */
      i--;                          
     }
     
   return 0;   
  }