// Id: 23991
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67368

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC" 
#property link      "http://fxcodebase.com"
#property version   "2.2"
#property strict


#property  indicator_chart_window
#property  indicator_buffers 1


#property  indicator_width1  1
#property  indicator_minimum 0
//---- indicator parameters

extern int Start =0;           
extern int BarAnaliz=400;      
extern double k_shirina=4;     
extern int tochnost =50;       
extern double filtr = 0.55;    
extern double MinShirina = 0;  
extern double MaxShirina = 10000;  
extern bool luch =  true;      
extern bool maxmin =  true;    
extern bool color_fill =  true;
extern int button_x = 20;
extern int button_y = 30;

//---- indicator buffers

double     Canals[];

double     Shirina[3000];
double     ShirinaU[3000];
double     ShirinaD[3000];
double     CanalR[3000];
double     CanalL[3000];
double     Kanals[20][9];

int preBars=0;  
int p[9]={43200,10080,1440,240,60,30,15,5,1};
int FinishL;
int tick=0;
int bar=0;
int b=0;
double sumPlus=0;
double sumMinus=0;
double yOptR,yOptL;
int prexL=0;
int prexR=0;
double ma=0;
int  prevxR=-5;
int  prevp=0;
int prevper=-5;
double sum1=0;
double sum2=0;  
double curdeltaMax=-10000;
double curdeltaMin=10000;

void Clear()
{
   for (int i =0;i<20;i++)
   {
      ObjectDelete("LineCanal9_"+DoubleToStr(i,0));
      ObjectDelete("LineCanal9_"+DoubleToStr(i,0)+" UP");
      ObjectDelete("LineCanal9_"+DoubleToStr(i,0)+" DOWN");
      ObjectDelete("LineCanal9_"+DoubleToStr(i,0)+" TRIUP");
      ObjectDelete("LineCanal9_"+DoubleToStr(i,0)+" TRIDown");
      ObjectDelete("Vertical_9_"+DoubleToStr(i,0));
   }
}

void deinit()
{
   Comment("");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

bool show_data = true;
string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
   IndicatorName = GenerateIndicatorName("channels");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   show_data = GlobalVariableGet("channels") != 0.0;
   IndicatorDigits(Digits+1);
   LoadHist();

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   createButton(IndicatorObjPrefix + "CloseButton", "Channels", 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
   ObjectSetInteger(0, IndicatorObjPrefix + "CloseButton", OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, IndicatorObjPrefix + "CloseButton", OBJPROP_XDISTANCE, button_x);
   
   return(0);
}

void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
   ObjectDelete(0,buttonID);
   ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
   ObjectSetString(0,buttonID,OBJPROP_FONT,font);
   ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
   ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
   ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
}

void handleButtonClicks()
{
   if (ObjectGetInteger(0, IndicatorObjPrefix + "CloseButton", OBJPROP_STATE))
   {
      ObjectSetInteger(0, IndicatorObjPrefix + "CloseButton", OBJPROP_STATE, false);
      show_data = !show_data;
      if (!show_data)
         Clear();
      else
      {
         preBars = 0;
         start();
      }
      GlobalVariableSet("channels", show_data);
   }
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
}

int start()
{
   Comment("");
   handleButtonClicks();
   if (!show_data)
      return 0;

   RefreshRates();
   if (preBars == Bars)
      return 0;
   preBars = Bars;
    
   int j = AllCanals();
   ArrayResize(Canals, 7 * (j - 1) + 10);
   Canals[0] = j;                                     

   if (j > 0)
   {
      for (int i = 0; i<j; i++)
      {
         Canals[7*i+1] = Kanals[i][0];                
         Canals[7*i+2] = Kanals[i][1];               
         Canals[7*i+3] = Kanals[i][2];                
         Canals[7*i+4] = Kanals[i][3];                
         Canals[7*i+5] = Kanals[i][4];                
         Canals[7*i+6] = Kanals[i][5]/Point;          
         Canals[7*i+7] = Kanals[i][6];                
         Canals[7*i+8] = Kanals[i][7];                
         Canals[7*i+9] = Kanals[i][8];                
      }
      BildCanals(j);
   }
   return(0);
}

int BildCanals( int j)
{
   string name;
   datetime x1,x2;
   double y1,y2;
   int  color_i[]={C'200,0,0',C'200,100,0',C'160,160,0',C'100,200,0',C'0,200,0',C'0,200,100',C'0,180,180',C'0,60,120',C'0,0,200',C'100,0,200',C'160,0,160',C'160,80,120'};
   int color_i2[]={C'80,0,0', C'80,40,0',  C'60,60,0',  C'40,80,0',  C'0,60,0', C'0,70,50',  C'0,50,50',  C'0,20,40', C'0,0,80', C'40,0,80',  C'50,0,60',  C'60,20,50'};
   for (int i = j; i < 20; i++)
   {
      ObjectDelete(IndicatorObjPrefix + "LineCanal9_"+DoubleToStr(i,0));
      ObjectDelete(IndicatorObjPrefix + "LineCanal9_"+DoubleToStr(i,0)+" UP");
      ObjectDelete(IndicatorObjPrefix + "LineCanal9_"+DoubleToStr(i,0)+" DOWN");
      ObjectDelete(IndicatorObjPrefix + "Vertical_9_"+DoubleToStr(i,0));
      ObjectDelete(IndicatorObjPrefix + "LineCanal9_"+DoubleToStr(i,0)+" TRIUP");
      ObjectDelete(IndicatorObjPrefix + "LineCanal9_"+DoubleToStr(i,0)+" TRIDown");
      Kanals[i][2]=0;
      Kanals[i][1]=0;
      Kanals[i][0]=0;
   }
  
   string comm = "Number of channels = " + IntegerToString(j);
   for (int i=0; i<j; i++) 
   { 
      comm=comm+"\n"+"Channel ¹ "+DoubleToStr((i+1),0)+" : width - "+DoubleToStr(Kanals[i][0],0)+", channel length -  "+DoubleToStr(Kanals[i][6],0)+" bars on period "+DoubleToStr(Kanals[i][2],0);
   }
  
   for (int i=0; i<j; i++) 
   {
      x1 = iTime(NULL,0,Start);
      y1 = Kanals[i][3];
      if (iTime(NULL,0,(Bars-1))<=iTime(NULL, (int)Kanals[i][2], (int)Kanals[i][1]))
      {
         x2 = iTime(NULL, (int)Kanals[i][2], (int)Kanals[i][1]);
         y2 = Kanals[i][4];
      }
      else   
      {
         x2 = iTime(NULL,0,(Bars-1));
         if (Kanals[i][6]!=0) 
            y2 = y1-((iBarShift(NULL, (int)Kanals[i][2], (int)x2, FALSE) - iBarShift(NULL, (int)Kanals[i][2], (int)x1, FALSE)) / Kanals[i][6])*(y1-Kanals[i][4]);
      }
       
      name = IndicatorObjPrefix + "LineCanal9_"+DoubleToStr(i,0);
      if (ObjectFind(name)==-1)
      {
         if (!ObjectCreate(name, OBJ_TREND, 0,x2,y2,x1,y1))
            Comment("Error 0 = ",GetLastError());
         ObjectSet(name, OBJPROP_RAY, FALSE);
         ObjectSet(name, OBJPROP_COLOR, color_i[i]);
         ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet(name, OBJPROP_RAY, luch);
         
         if (maxmin==true)
            ObjectCreate(name+" UP",   OBJ_TREND, 0, x2,(y2+Point*Kanals[i][7]),x1,(y1+Point*Kanals[i][7]));
         else
            ObjectCreate(name+" UP",   OBJ_TREND, 0, x2,(y2+k_shirina*Point*Kanals[i][0]), x1,(y1+k_shirina*Point*Kanals[i][0]));
         ObjectSet(name+" UP", OBJPROP_RAY, FALSE);
         ObjectSet(name+" UP", OBJPROP_COLOR, color_i[i]);
         ObjectSet(name+" UP", OBJPROP_STYLE, STYLE_DASH);
         ObjectSet(name+" UP", OBJPROP_RAY, luch);
         
         if (maxmin==true)
            ObjectCreate(name+" DOWN", OBJ_TREND, 0, x2,(y2+Point*Kanals[i][8]),x1,(y1+Point*Kanals[i][8]));
         else 
            ObjectCreate(name+" DOWN", OBJ_TREND, 0, x2,(y2-k_shirina*Point*Kanals[i][0]), x1,(y1-k_shirina*Point*Kanals[i][0]));
         ObjectSet(name+" DOWN", OBJPROP_RAY, FALSE);
         ObjectSet(name+" DOWN", OBJPROP_COLOR, color_i[i]);
         ObjectSet(name+" DOWN", OBJPROP_STYLE, STYLE_DASH);
         ObjectSet(name+" DOWN", OBJPROP_RAY, luch);
         
         if (color_fill==true)
         {
            ObjectCreate(name+" TRIUP", OBJ_TRIANGLE, 0, x2,(y2+Point*Kanals[i][7]),x1,(y1+Point*Kanals[i][7]),x2,(y2+Point*Kanals[i][8]));
            ObjectSet(name+" TRIUP", OBJPROP_COLOR, color_i2[i]);
            ObjectCreate(name+" TRIDown", OBJ_TRIANGLE, 0, x1,(y1+Point*Kanals[i][7]),x1,(y1+Point*Kanals[i][8]),x2,(y2+Point*Kanals[i][8]));
            ObjectSet(name+" TRIDown", OBJPROP_COLOR, color_i2[i]);
         } 
         
         if (!ObjectCreate(IndicatorObjPrefix + "Vertical_9_"+DoubleToStr(i,0), OBJ_VLINE, 0, x2,8))
            Comment("Îøèáêà 0 = ",GetLastError());
         ObjectSet(IndicatorObjPrefix + "Vertical_9_"+DoubleToStr(i,0), OBJPROP_COLOR, color_i[i]);
         ObjectSet(IndicatorObjPrefix + "Vertical_9_"+DoubleToStr(i,0), OBJPROP_STYLE, STYLE_DOT);
      }
      else
      {
         if (!ObjectMove(name, 0, x2 ,y2))
            Comment("Îøèáêà 1 = ",GetLastError());
         if (!ObjectMove(name, 1, x1, y1))
            Comment("Îøèáêà 2 = ",GetLastError());
         
         if (maxmin==true)
         {
            ObjectMove(name+" UP", 0, x2, y2+Point*Kanals[i][7]);
            ObjectMove(name+" UP", 1, x1 ,y1+Point*Kanals[i][7]);
            
            ObjectMove(name+" DOWN", 0, x2, y2+Point*Kanals[i][8]);
            ObjectMove(name+" DOWN", 1, x1 ,y1+Point*Kanals[i][8]);
            
            if (color_fill==true)
            {
               ObjectMove(name+" TRIUP", 0, x2,(y2+Point*Kanals[i][7]));
               ObjectMove(name+" TRIUP", 1, x1,(y1+Point*Kanals[i][7]));
               ObjectMove(name+" TRIUP", 2, x2,(y2+Point*Kanals[i][8]));
               
               ObjectMove(name+" TRIDown", 0, x1,(y1+Point*Kanals[i][7]));
               ObjectMove(name+" TRIDown", 1, x1,(y1+Point*Kanals[i][8]));
               ObjectMove(name+" TRIDown", 2, x2,(y2+Point*Kanals[i][8]));
            }
         }
         else
         {
            ObjectMove(name+" UP", 0, x2 ,y2+k_shirina*Point*Kanals[i][0]);
            ObjectMove(name+" UP", 1, x1, y1+k_shirina*Point*Kanals[i][0]);
            
            ObjectMove(name+" DOWN", 0, x2 ,y2-k_shirina*Point*Kanals[i][0]);
            ObjectMove(name+" DOWN", 1, x1, y1-k_shirina*Point*Kanals[i][0]);
         }
      }
   }
   return(0);
}

////////////////////////////////////////////////////////
int AllCanals()
{
   int i1=0;
   int k=0;
   int i=0;
   int St,Fin;
   datetime S,F,prevS,CurStart;
   int lastmin;
   double lmin;
   double premin;
   int lastper=9;
   CurStart=iTime(NULL,Period(),Start);
   if (Start==0) 
      CurStart=iTime(NULL,1,0);
   prevS=iTime(NULL,p[0],(iBarShift(NULL,p[0],CurStart,FALSE)+BarAnaliz));
   for (int jj=0;jj<lastper;jj++)
   {
      if (jj==8) 
         S = CurStart;
      else 
         S = iTime(NULL,p[jj+1],(iBarShift(NULL,p[jj+1],CurStart,FALSE)+BarAnaliz)); 
      F = prevS;
      prevS=S;
      St= iBarShift(NULL,p[jj],CurStart,FALSE);
      Fin=iBarShift(NULL,p[jj],F,FALSE);

      if (St==0 && Fin==0)  
         return(0);
      if (jj!=8) 
         ArrShirina(St,Fin,(iBarShift(NULL,p[jj],S,FALSE))-St-7,p[jj]); 
      else
         ArrShirina(St,Fin,0,p[jj]);
      lastmin=Fin+1;
      if (jj==0)
      {
         lmin=10000000;
         premin=Shirina[Fin-St-1];  
      }
      int pjjBarsShift = iBarShift(NULL, p[jj], S, FALSE);
      if (Fin > pjjBarsShift && Fin - 1 >= St)
      { 
         for (i = Fin - 1; i > pjjBarsShift - 1 && i - St > 0; i--)
         {
            if (Shirina[i-St]<lmin)
            {
               lmin=Shirina[i-St];
               lastmin=i;
            } 
            if (Shirina[i - St] <= Shirina[i - St - 1] && Shirina[i - St] <= Shirina[i - St + 1])
            {
               if (lastmin==i && Shirina[i-St]<premin*filtr && Shirina[i-St]>MinShirina && Shirina[i-St]<MaxShirina)
               {
                  for (k=0; k<i1; k++)
                  {
                     if (Shirina[i-St]!=0 && (Kanals[k][0]/Shirina[i-St])<1.2 && (Kanals[k][0]/Shirina[i-St])>0.8) 
                        i1=k;
                  }
                  Kanals[i1][0]= Shirina[i-St];                            
                  Kanals[i1][1]= i;                                       
                  Kanals[i1][2]= p[jj];                                    
                  Kanals[i1][3]= CanalR[i-St];                             
                  Kanals[i1][4]= CanalL[i-St];                             
                  if ((i-St)*p[jj]!=0) 
                     Kanals[i1][5]= (CanalR[i-St]-CanalL[i-St])/((i-St)*p[jj]);  
                  Kanals[i1][6]= (i-St);                                   
                  Kanals[i1][7]= ShirinaU[i-St];                           
                  Kanals[i1][8]= ShirinaD[i-St];                           
                  premin=Shirina[i-St];
                  i1++;
               }
            }
         }
      }
   }
   return(i1);
}
//////////////////////////////////////////////////////////////////////
double ArrShirina(int Start1, int Finish, int Sdvig, int per)
{
   Shirina[0]=0;
   if (Sdvig<0) 
      Sdvig=0;
   yOptR=iOpen(NULL,per,Start1);

   int d,i1;
   double dC,dR,dL;
   int p=0;
   int lnz=Sdvig;
   for(int i=(1+Sdvig); i<(Finish-Start1); i++)
   {
      if (tochnost!=0) 
         p = (int)MathFloor((i-1)/tochnost);
      i=i+p;
      Shirina[i] = MinCanal2(Start1,i+Start1,per);
      if(maxmin==true)
      {
         if( k_shirina*Shirina[i]<curdeltaMax/Point) 
            ShirinaU[i]=(curdeltaMax/Point+k_shirina*Shirina[i])/2; 
         else 
            ShirinaU[i]=curdeltaMax/Point;
         if(-k_shirina*Shirina[i]>curdeltaMin/Point) 
            ShirinaD[i]=(curdeltaMin/Point-k_shirina*Shirina[i])/2; 
         else 
            ShirinaD[i]=curdeltaMin/Point;
      }
      CanalL[i]  = yOptL;
      CanalR[i]  = yOptR;
      d=i-lnz;
      if (d!=0)
      {
         dC=(Shirina[i]-Shirina[lnz])/d;
         dR=(CanalR[i]-CanalR[lnz])/d;
         dL=(CanalL[i]-CanalL[lnz])/d;
      }
      if (d>1)
      {
         for (i1=1;i1<d;i1++)
         {
            Shirina[lnz+i1] = Shirina[lnz+i1-1]+dC;
            CanalL[lnz+i1]  = CanalL[lnz+i1-1]+dL;
            CanalR[lnz+i1]  = CanalR[lnz+i1-1]+dR;
         }
         lnz=i;
      }
   }
   return(0);
}

///////////////////////////////////////////////////////
double MinCanal2(int xR,int xL,int per)
{
   double p=xL-xR;
   double j1,j2,j3,h1,h2,d;

   j1 = p + 1;
   j2 = p*(p+1)/2;
   j3 = p*(p+1)*(2*p+1)/6;
         
   if (prevxR!=xR || prevper!=per) 
   {
      prevp=0;
      sum1=0; 
      sum2=0;
   } 
   
   for(int n = prevp; n <= p; n++) 
   {
      sum2 += iOpen(NULL,per,n+xR); 
   }
    
   for(int n = prevp; n <= p; n++) 
   {
      sum1 += iOpen(NULL,per,n+xR)*n; 
   }
  
   h2 = sum2;
   h1 = sum1;
   prevxR=xR;
   prevp=p+1;
   prevper=per;
   d = (j2*h2-j1*h1)/(j2*j2-j1*j3);
   yOptR = (h1-j3*d)/j2;
   yOptL = d*p+yOptR; 

   return(SumPlus2(xL,xR,yOptR,yOptL,per)/j1);
}
///////////////////////////////////////////////////////

double SumPlus2(int xL1, int xR1, double yR1,double yL1,int per)
{
   double curLinePrice, curdelta,curdeltaH,curdeltaL,delta;
   curdeltaMax=-100000;
   curdeltaMin=100000;
   int i = xR1;
   if(xL1==xR1)
      return(0);
   if ((xL1-xR1)!=0) 
      delta = (yL1-yR1)/(xL1-xR1);
   curLinePrice = yR1;
   sumPlus=0;
   while (i<=xL1)
   {
      curdelta = iOpen(NULL,per,i) - curLinePrice;
      curdeltaH = iHigh(NULL,per,i) - curLinePrice;
      curdeltaL = iLow(NULL,per,i) - curLinePrice;
      if (curdeltaMax<curdeltaH) 
         curdeltaMax=curdeltaH;
      if (curdeltaMin>curdeltaL) 
         curdeltaMin=curdeltaL;
      if (curdelta>0) 
         sumPlus = sumPlus+curdelta;
      curLinePrice = curLinePrice + delta;
      i++;
   }
  return(sumPlus/Point);
}

////////////////////////////////////////////////////////////////////////////////////
void LoadHist()
{
   int iPeriod[9];
   iPeriod[0]=1;
   iPeriod[1]=5;
   iPeriod[2]=15;
   iPeriod[3]=30;
   iPeriod[4]=60;
   iPeriod[5]=240;
   iPeriod[6]=1440;
   iPeriod[7]=10080;
   iPeriod[8]=43200;
   for (int iii=0;iii<9;iii++)
   {
      datetime open = iTime(Symbol(), iPeriod[iii], 0);
      int error=GetLastError();
      while(error==4066)
      {
         Comment("Did not load historical data for ",iPeriod[iii]," period, the indicator needs to be rebooted or move on to another timeframe");
         Sleep(10000);
         open = iTime(Symbol(), iPeriod[iii], 0);
         error=GetLastError();
      }
   }
}
