//+------------------------------------------------------------------+
//|                                                           AC.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property indicator_separate_window
#property indicator_buffers 3

#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red


extern int  Fast_MA_periods=5;
extern int  Slow_MA_periods=35;
extern int  Acceleration_Deceleration=5;

extern int  MA_Mode = 0;
extern int  Price_Mode = 4;

int MAX=0;
double AO[],AC[], UP[],DOWN[];

 

int init()
  {
  
   
   IndicatorShortName("AC");
   IndicatorDigits(Digits);
   
   IndicatorBuffers(4);
      
   if(! (Price_Mode >= 0 && Price_Mode <= 5  )  ) 
   {
   Alert("Permitted Price_Modes are between 0 and 5");

   return(-1);
   }
   
   if(! (MA_Mode >= 0 && MA_Mode <= 3  )  ) 
   {
   Alert("Permitted MA_Modes are between 0 and 3");

   return(-1);
   }
   
    
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,AC);
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,UP);

    SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,DOWN);
   
   
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,AO);
 
   
   MAX =MathMax( MAX,Fast_MA_periods);
   MAX =MathMax( MAX,Slow_MA_periods);
   MAX =MathMax( MAX,Acceleration_Deceleration);
   return(0);
  }

int deinit()
  {
    int Window=WindowFind("AC");
	
   if (Window!=-1)
   {
    ObjectsDeleteAll(Window, OBJ_TREND);
   }


   return(0);
  }

 int ACC(int i)
{ 
   
  AC[i] = AO[i] - iMAOnArray(AO,0,Acceleration_Deceleration,0,MA_Mode,i);
  
 
 }
 
  
  
int AOC(int i)
{

 double Fast = iMA (NULL,0,Fast_MA_periods,0,MA_Mode,Price_Mode,i);
 double Slow = iMA (NULL,0,Slow_MA_periods,0,MA_Mode,Price_Mode,i);
 
 AO[i]= Fast-Slow;
 
  return(0);
}

  
  
int start()
{
 if(Bars<=MAX) return(0); 
 
 

 int pos;
 int limit=Bars-MAX;
 
 pos=limit;
 
 while(pos>=0)
 {
 
    
   AOC(pos);     
   
   pos--;
 } 
 
 
  pos=limit;
 
 while(pos>=0)
 {
 
 ACC(pos); 
 
    pos--;
 } 
 
 
  pos=limit;
 
 while(pos>=0)
 {
 
   if (AC[pos]>AC[pos+1])
  {   
   UP[pos]=AC[pos];
   DOWN[pos]=EMPTY_VALUE;
  }
  else
  {  			 
	DOWN[pos]=AC[pos];
	UP[pos]=EMPTY_VALUE;   
  }
   
   pos--;
 } 
   
 

 return(0);
}


 
