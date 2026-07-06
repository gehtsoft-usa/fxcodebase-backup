//+------------------------------------------------------------------+
//|                                           Divergence Candles.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern int ArrowSize=2;

double UpArrow[], DnArrow[];


int init()
  {
    IndicatorBuffers(2);
    IndicatorShortName("Divergence Candles");
   
    SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
    SetIndexArrow(0,233);
    SetIndexBuffer(0,UpArrow);
    SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
    SetIndexArrow(1,234);
    SetIndexBuffer(1,DnArrow);

   return(0);
  }


void DrawARROW(int pos,int Flag ,double Price)
{
 
   
     if(Flag==1) UpArrow[pos]=Price ;
      
    if(Flag==-1)  DnArrow[pos]=Price ;
    
    
    
 return;
}  

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit-1;
 
 
//N high > high N-1 and N close =< close N-1
//N low < low N-1 and N close >= close N-1
 
 while(pos>=0)
 {
  
	  if (High[pos]>High[pos+1] &&  Close[pos]<= Close[pos+1] )
	  {
	  
	   DrawARROW(pos,-1, High[pos]);
	  }
	  
	  if (Low[pos]<Low[pos+1] &&  Close[pos]>= Close[pos+1] )
	  {
	  
	   DrawARROW(pos,1, Low[pos]);
	  }
	  


     pos--;
  
 } 

 return(0);
}


