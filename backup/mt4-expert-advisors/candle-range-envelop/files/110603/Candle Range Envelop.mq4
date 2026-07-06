//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_color3 clrSilver 
#property indicator_color4 clrSilver
#property indicator_color5 clrSilver
#property indicator_color6 clrSilver
 
extern int Range_Period=1;
extern int Signal_Period=14;
extern int Deviation_Period=14;
extern double Deviation_Multiplier=2; 
extern double Top_Envelop_Percentage=20; 
extern double Bottom_Envelop_Percentage=20;  

 
 
enum Method { Deviation=1, Percentage=2 };
input Method EnvelopMethod = Deviation;

enum Mode { High_Low=1, Open_Close=2 };
input Mode Price_Mode = High_Low;

double Up[];
double Down[];
double Neutral[]; 
double Signal[];
double Top[];
double Bottom[];
double Range[];


int init()
{
 IndicatorShortName("Candle Range Envelop");
 IndicatorDigits(Digits);
 IndicatorBuffers(7);
 
  
  SetIndexBuffer(0,Up);
  SetIndexBuffer(1,Down); 
  SetIndexBuffer(2,Neutral); 
  SetIndexBuffer(3,Signal);
  SetIndexBuffer(4,Top);
  SetIndexBuffer(5,Bottom);      
  SetIndexBuffer(6,Range); 

  
  SetIndexStyle(0,DRAW_HISTOGRAM); 
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexStyle(2,DRAW_HISTOGRAM);
   
  SetIndexStyle(3,DRAW_LINE); 
  SetIndexStyle(4,DRAW_LINE); 
  SetIndexStyle(5,DRAW_LINE); 
  
   
   SetIndexStyle(6,DRAW_NONE);
  
 
 return(0);
}



int deinit()
{

 return(0);
}

int start()
{


 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 
 //if (limit < Range_Period)
 //{
 //return(0);
 //}
 
  double DeltaT;
  double DeltaB;
  double StdDev;

 while(pos>=0)
 { 
  
      if (Price_Mode==1)
	  {
   	  int High_index=iHighest(NULL,0,MODE_HIGH,Range_Period,pos);
	  int Low_index=iLowest(NULL,0,MODE_LOW,Range_Period,pos); 
        Range[pos] =( High[High_index]-Low[Low_index])/Point;
	  }
      else
      {
	  Range[pos] = MathAbs( Open[pos+Range_Period]-Close[pos])/Point;  
	  }	 

     pos--;
 } 	  
	

 
 //if (limit < Range_Period + Signal_Period )
 //{
 //return(0);
 //}
 
        pos=limit;
         while(pos>=0)
       { 
 
		Signal[pos]=iMAOnArray(Range,0,Signal_Period,0,MODE_SMA,pos); 
	   
	        pos--;
         } 	  
	
 //if (limit < Range_Period + Signal_Period+Deviation_Period )
 //{
 //return(0);
 //}
 
	  pos=limit;
         while(pos>=0)
       {    
	 
	   if (EnvelopMethod ==1 )
	   {
       StdDev= iStdDevOnArray(Signal,0,Deviation_Period,0,MODE_SMA,pos);
       DeltaT=StdDev*Deviation_Multiplier;
       DeltaB=StdDev*Deviation_Multiplier;
	   }
	   else
	   {	   
	   DeltaT =( Signal[pos]/100) *Top_Envelop_Percentage;
	   DeltaB =( Signal[pos]/100) *Bottom_Envelop_Percentage;
	   }
	   
	   
	   
			  Top[pos]=Signal[pos]+DeltaT;
			  Bottom[pos]=Signal[pos]-DeltaB;
			  
			 if (Range[pos] > Top[pos])
			 {
			 Up[pos]= Range[pos];
			 Down[pos]= 0;
			 Neutral[pos]= 0;
			 }
			else if  (Range[pos] < Bottom[pos])
			 {
			  Up[pos]= 0;
			 Down[pos]= Range[pos];
			 Neutral[pos]= 0;
			 }
			else
			{
			Up[pos]= 0;
			 Down[pos]= 0;
			 Neutral[pos]= Range[pos];
			}
 
   pos--;
 } 
 
 
     
 
	 
 
 return(0);
}

