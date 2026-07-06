//+------------------------------------------------------------------+
//|                                                      Storage.mqh |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define FileName "storage"

string DBname;
string DBvalues[][3], Ovalues[][3];

void openDB(string _DBname)
{
 int AS;
 string Arr[3];
 DBname=_DBname;
 ArrayResize(DBvalues,0);
 ArrayResize(Ovalues,0);
 int FF=FileOpen(FileName, FILE_BIN|FILE_READ);
 if (FF==-1) return;
 int V;
 while (!(FileIsEnding(FF)))
 {
  V=FileReadArray(FF, Arr, 0, 3);
  if (V==0) break;
  if (Arr[0]==DBname) 
  {
   AS=ArraySize(DBvalues)/3;
   ArrayResize(DBvalues,AS+1);
   DBvalues[AS][0]=Arr[0];
   DBvalues[AS][1]=Arr[1];
   DBvalues[AS][2]=Arr[2];
  }
  else
  {
   AS=ArraySize(Ovalues)/3;
   ArrayResize(Ovalues,AS+1);
   Ovalues[AS][0]=Arr[0];
   Ovalues[AS][1]=Arr[1];
   Ovalues[AS][2]=Arr[2];
  }
 }
 FileClose(FF);
 return;
}

void put(string name, string value)
{
 int i;
 int AS=ArraySize(DBvalues)/3;
 string _name=StringTrimLeft(StringTrimRight(name));
 bool NewFl=true;
 for (i=0;i<AS;i++)
 {
  if (DBvalues[i][1]==_name)
  {
   DBvalues[i][2]=value;
   NewFl=false;
   break;
  }
 }
 if (NewFl)
 {
  ArrayResize(DBvalues,AS+1);
  DBvalues[AS][0]=DBname;
  DBvalues[AS][1]=name;
  DBvalues[AS][2]=value;
 }
 return;
}

void closeDB()
{
 string Arr[3];
 int i;
 int FF=FileOpen(FileName, FILE_BIN|FILE_WRITE);
 
 int AS=ArraySize(DBvalues)/3;
 for (i=0;i<AS;i++)
 {
  Arr[0]=DBvalues[i][0];
  Arr[1]=DBvalues[i][1];
  Arr[2]=DBvalues[i][2];
  FileWriteArray(FF, Arr, 0, 3);
 }
 AS=ArraySize(Ovalues)/3;
 for (i=0;i<AS;i++)
 {
  Arr[0]=Ovalues[i][0];
  Arr[1]=Ovalues[i][1];
  Arr[2]=Ovalues[i][2];
  FileWriteArray(FF, Arr, 0, 3);
 }
 FileFlush(FF);
 FileClose(FF);
}

string get(string name, string default_value)
{
 int i;
 int AS=ArraySize(DBvalues)/3;
 string _name=StringTrimLeft(StringTrimRight(name));
 for (i=0;i<AS;i++)
 {
  if (DBvalues[i][1]==_name)
  {
   return (DBvalues[i][2]);
  }
 }
 return (default_value);
}

