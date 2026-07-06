//+------------------------------------------------------------------+
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 clrRed
#property indicator_color2 clrCrimson
#property indicator_color3 clrDarkViolet
#property indicator_color4 clrMediumBlue
#property indicator_color5 clrRoyalBlue
#property indicator_color6 clrDarkTurquoise
#property indicator_color7 clrLimeGreen
#property indicator_color8 clrGreen

extern int Length1=20;
extern double Deviation1=1.;
extern int Method1=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price1=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

extern int Length2=20;
extern double Deviation2=2.;
extern int Method2=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price2=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
					   
double U4[], U3[], U2[], U1[], L1[], L2[], L3[], L4[];

extern bool New_Bar_Only=false;
extern bool Play_Sound=false;
extern string MA_Cross_Over_Sound="";
extern string MA_Cross_Under_Sound="";
extern bool Send_Email=false;
extern bool Snow_Alert=true;
extern string Additional_Text="BB With Alert: ";

datetime LastTime0;
int LastCross0;
datetime LastTime1;
int LastCross1;
datetime LastTime2;
int LastCross2;
datetime LastTime3;
int LastCross3;

//int Initialization=0;

int init()
{
 IndicatorShortName("Multiple Bollinger Bands Deviation");
 IndicatorDigits(Digits);
 
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE);
  SetIndexStyle(2,DRAW_LINE);
  SetIndexStyle(3,DRAW_LINE); 
 

 SetIndexBuffer(0,U2);
 SetIndexBuffer(1,U1);
 SetIndexBuffer(2,L1);
 SetIndexBuffer(3,L2);
 
 
  
	 LastTime0=Time[0];
	 LastCross0=0;

	 LastTime1=Time[0];
	 LastCross1=0;
	 
	 LastTime2=Time[0];
	 LastCross2=0;
	 
	 LastTime3=Time[0];
	 LastCross3=0;
	 
   
 
 return(0);
}


void Cross(bool Over, string Message)
{
 if (Send_Email)
 {
  SendMail(Additional_Text, Message);
 }
 if (Play_Sound)
 {
  if (Over)
  {
   PlaySound(MA_Cross_Over_Sound);
  }
  else
  {
   PlaySound(MA_Cross_Under_Sound);
  }
 }
 if (Snow_Alert)
 {
  Alert(Message);
 }
 return;
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
 while(pos>=0)
 {
 
  U2[pos]=iBands(NULL,0,Length2,Deviation2,0,Price2,1,pos); // 0
  U1[pos]=iBands(NULL,0,Length1,Deviation1,0,Price1,1,pos); // 1 
  L1[pos]=iBands(NULL,0,Length1,Deviation1,0,Price1,2,pos); // 2  
  L2[pos]=iBands(NULL,0,Length2,Deviation2,0,Price2,2,pos); //3
  
  
  
	 
			 bool CheckCross0=true;
			 if (New_Bar_Only)
			 {
			  if (LastTime0!=Time[0])
			  {
			   LastTime0=Time[0];
			  }
			  else
			  {
			   CheckCross0=false;
			  }
			 }
			 
			 if (CheckCross0)
			 {
				  if (U2[1]<=Close[1] && U2[0]>Close[0] && LastCross0!=1)
				  {
				   LastCross0=1;
				   Cross(true, Additional_Text+" 2. Top Line Cross Under");
				  }
				  if (U2[1]>=Close[1] && U2[0]<Close[0] && LastCross0!=-1)
				  {
				   LastCross0=-1;
				   Cross(false, Additional_Text+" 2. Top Line Cross Over");
				  }
				  
				  
				  
			 }
			 
			 
			 
			 bool CheckCross3=true;
			 if (New_Bar_Only)
			 {
			  if (LastTime3!=Time[0])
			  {
			   LastTime3=Time[0];
			  }
			  else
			  {
			   CheckCross3=false;
			  }
			 }
			 
			 if (CheckCross3)
			 {
				  if (L2[1]<=Close[1] && L2[0]>Close[0] && LastCross3!=1)
				  {
				   LastCross3=1;
				   Cross(true, Additional_Text+" 2. Bottom Line Cross Under");
				  }
				  if (L2[1]>=Close[1] && L2[0]<Close[0] && LastCross3!=-1)
				  {
				   LastCross3=-1;
				   Cross(false, Additional_Text+" 2. Bottom Line Cross Over");
				  }
				  
				  
				  
			 }
			 
			 
			  bool CheckCross1=true;
			 if (New_Bar_Only)
			 {
			  if (LastTime1!=Time[0])
			  {
			   LastTime1=Time[0];
			  }
			  else
			  {
			   CheckCross1=false;
			  }
			 }
			 
			 if (CheckCross1)
			 {
				  if (U1[1]<=Close[1] && U1[0]>Close[0] && LastCross1!=1)
				  {
				   LastCross1=1;
				   Cross(true, Additional_Text+" 1. Top Line Cross Under");
				  }
				  if (U1[1]>=Close[1] && U1[0]<Close[0] && LastCross1!=-1)
				  {
				   LastCross1=-1;
				   Cross(false, Additional_Text+" 1. Top Line Cross Over");
				  }
				  
				  
				  
			 }
		 
				 bool CheckCross2=true;
			 if (New_Bar_Only)
			 {
			  if (LastTime2!=Time[0])
			  {
			   LastTime2=Time[0];
			  }
			  else
			  {
			   CheckCross2=false;
			  }
			 }
			 
			 if (CheckCross2)
			 {
				  if (L1[1]<=Close[1] && L1[0]>Close[0] && LastCross2!=1)
				  {
				   LastCross2=1;
				   Cross(true, Additional_Text+" 1. Bottom Line Cross Under");
				  }
				  if (L1[1]>=Close[1] && L1[0]<Close[0] && LastCross2!=-1)
				  {
				   LastCross2=-1;
				   Cross(false, Additional_Text+" 1. Bottom Line Cross Over");
				  }
				  
				  
				  
			 }
		  
   pos--;
 } 
 
 
     
 
	 
 
 return(0);
}

