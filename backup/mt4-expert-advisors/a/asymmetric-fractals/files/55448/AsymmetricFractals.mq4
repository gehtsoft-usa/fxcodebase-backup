//+------------------------------------------------------------------+
//|                                           AsymmetricFractals.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int FramesBefore=4;
extern int FramesAfter=2;

double ExtUpFractalsBuffer[];
double ExtDownFractalsBuffer[];

int init()
  {
    SetIndexBuffer(0,ExtUpFractalsBuffer);
    SetIndexBuffer(1,ExtDownFractalsBuffer);   
    SetIndexStyle(0,DRAW_ARROW,0,4);
    SetIndexArrow(0,119);
    SetIndexStyle(1,DRAW_ARROW,0,4);
    SetIndexArrow(1,119);
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
    SetIndexLabel(0,"Fractal Up");
    SetIndexLabel(1,"Fractal Down");
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   int    i,nCountedBars;
   bool   bFound;
   double dCurrent;
   nCountedBars=IndicatorCounted();
   if(nCountedBars<=2)
      i=Bars-nCountedBars-3;
   if(nCountedBars>2)
     {
      nCountedBars--;
      i=Bars-nCountedBars-1;
     }

   while(i>=0)
     {
      bool FrUp=true;
      bool FrDn=true;
      int ii;
      for (ii=1;ii<=FramesBefore;ii++)
      {
       if (High[i+FramesAfter+ii]>=High[i+FramesAfter]) FrUp=false;
       if (Low[i+FramesAfter+ii]<=Low[i+FramesAfter]) FrDn=false;
      }
      for (ii=1;ii<=FramesAfter;ii++)
      {
       if (High[i+FramesAfter-ii]>=High[i+FramesAfter]) FrUp=false;
       if (Low[i+FramesAfter-ii]<=Low[i+FramesAfter]) FrDn=false;
      }
     
      if (FrUp)
        {
         ExtUpFractalsBuffer[i+FramesAfter]=High[i+FramesAfter];
        }
        else
        {
         ExtUpFractalsBuffer[i+FramesAfter]=EMPTY;
        }
      if (FrDn)
        {
         ExtDownFractalsBuffer[i+FramesAfter]=Low[i+FramesAfter];
        }
        else
        {
         ExtDownFractalsBuffer[i+FramesAfter]=EMPTY;
        }
      i--;
     }

   return(0);
  }

