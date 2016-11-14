StrEncrypt(Str,Pass="",Quality=1)
{
Strarr:=[]
PWARR:=[]
Loop,Parse,str
    Strarr.Insert(asc(A_LoopField))
Loop,Parse,Pass
    PWARR.Insert(asc(A_LoopField))
StrArr:=FilterAlgid(StrArr,PwArr,Quality)
s:=""
For each,val in StrArr
    s.=UShortToHex(val)
return s
}
 
StrDecrypt(Str,Pass="")
{
Strarr:=[]
PWARR:=[]
Loop, % strlen(str)//4
    Strarr.Insert(HexToUShort(SubStr(Str,(A_Index-1)*4+1,4)))
Loop,Parse,Pass
    PWARR.Insert(asc(A_LoopField))
StrArr:=FilterRemoveAlgid(StrArr,PwArr)
s:=""
For each,val in StrArr
   s.=chr(val)
return s
}
 
 
FilterAlgid(StrArr,PwArr,Quality=1,modvar=0x10000)
{
Strarr:=strarr.Clone()
PwArr:=Pwarr.Clone()
Strarr:=Filter3(StrArr,modvar)
Loop, % Quality+1
{
PWArr:=Filter1(PWArr,0,modvar)
PWArr:=Filter2(PWarr,0)
buf:=Calcbuf(PWarr,modvar)
strarr:=Filter1(strarr,buf,modvar)
strarr:=Filter2(strarr,buf)
}
strarr.insert(Quality)
return strarr
}
 
FilterRemoveAlgid(StrArr,PwArr,modvar=0x10000)
{
bufarr:=[]
Strarr:=strarr.Clone()
PwArr:=Pwarr.Clone()
Quality:=strarr[strarr.maxindex()]
strarr.remove()
Loop % Quality+1
{
PWArr:=Filter1(PWArr,0,modvar)
PWArr:=Filter2(PWarr,0)
bufarr.insert(Calcbuf(PWarr,modvar))
}
Loop, % Quality+1
{
strarr:=Filter2Remove(strarr,bufarr[Quality+2-A_Index])
strarr:=Filter1Remove(strarr,bufarr[Quality+2-A_Index],modvar)
}
Strarr:=Filter3Remove(StrArr,modvar)
return strarr
}
 
Calcbuf(arr,modvar=0x100000000)
{
    buf:=0
    lastnum:=0
    Loop, % arr.Maxindex()
    {
      For each,val in arr
        buf:=mod((val*(buf+1))+val,modvar)
    }
return buf
}
 
Filter1(arr,buf,modvar=0x100000000)
{
    lastnum:=0
    arr:=arr.Clone()
    Loop, % arr.Maxindex()
    {
      buf:=mod(mod(buf+lastnum+A_Index,modvar)*(buf+1)*(lastnum+1)*mod(A_Index,modvar)*255,modvar)
	  arr[A_Index]:=mod(buf+(lastnum:=arr[A_Index]),modvar)
    }
return arr
}
 
Filter1Remove(arr,buf,modvar=0x100000000)
{
    lastnum:=0
    arr:=arr.Clone()
    Loop, % arr.MaxIndex()
    {
      buf:=mod(mod(buf+lastnum+A_Index,modvar)*(buf+1)*(lastnum+1)*mod(A_Index,modvar)*255,modvar)
       arr[A_Index]:=lastnum:=min(mod(arr[A_Index]-buf,modvar),modvar)
    }
return arr
} 
 
Filter2(arr,PWVar=0)
{
v2:=[],s:=[],buf:=0
x:=arr.Maxindex()
Loop, % x
    s[A_Index]:=A_Index
Loop, % x
    n:=Floor(mod(buf+PWVar,s.Maxindex())+1),w:=s[n],buf:=(v2[w]:=arr[x-A_Index+1]),s.Remove(n,n)
return v2
}
 
Filter2Remove(arr,PWVar=0)
{
v2:=[],s:=[],buf:=0
x:=arr.Maxindex()
Loop, % x
    s[A_Index]:=A_Index
Loop, % x
    n:=Floor(mod(buf+PWVar,s.Maxindex())+1),w:=s[n],buf:=(v2[x-A_Index+1]:=arr[w]),s.Remove(n,n)
return v2
}
 
Filter3(arr,modvar)
{
cmin:=modvar
cmax:=0
spclmodvar:=1
vmod:=0
strl:=arr.Maxindex()
For each, val in arr
	cmin:=val<cmin?val:cmin,cmax:=val>cmax?val:cmax
while ((cmax-cmin)>spclmodvar-1)
	spclmodvar*=2,vmod:=A_Index
cmin-=(cmin+spclmodvar-1)>(modvar-1)?(cmin+spclmodvar-1)-(modvar-1):0
if (cmax-cmin)<(spclmodvar-1)
	Random,var,0,% (spclmodvar-1)-(cmax-cmin)
cmin-=var
cmin:=cmin<0?cmin:=0:cmin
If (vmod=0)
	return [strl>>16,strl-((strl>>16)<<16),cmin,0]
For each, val in arr
	arr[each]-=cmin
spclmodvar:=1
cmax:=""
vmod2:=""
while ((modvar-1)>spclmodvar-1)
	spclmodvar*=2,vmod2:=A_Index
arr2:=[]
rest:=0
For each, val in arr
{
    w:=ceil((A_Index*vmod)/vmod2)
	rest:=rest+vmod
	If (rest<=vmod2)
	{
		arr2[w]:=(arr2[w]?arr2[w]:0)+(val<<(vmod2-rest))
	}
	else
	{	
		rest:=(rest-vmod2)
		arr2[w-1]:=arr2[w-1]+(val>>rest)
		v:=val-((val>>rest)<<rest)
		arr2[w]:=(v<<(vmod2-rest))
	}
}
arr2.Insert(strl>>16)
arr2.Insert(strl-((strl>>16)<<16))
arr2.Insert(cmin)
arr2.Insert(vmod)
return arr2
}
 
 
Filter3Remove(arr,modvar)
{
arr2:=[]
cmin:=arr[arr.maxindex()-1]
vmod:=arr[arr.maxindex()]
strl:=arr[arr.maxindex()-2]+(arr[arr.maxindex()-3]<<16)
arr.remove()
arr.remove()
arr.remove()
arr.remove()
if !vmod
{
	if strl<0x5FFFFF
	Loop, % StrL
		arr2.Insert(cmin)
	return arr2
}
spclmodvar:=1
while ((modvar-1)>spclmodvar-1)
	spclmodvar*=2,vmod2:=A_Index
rest:=0
Loop % strl
{
    w:=ceil((A_Index*vmod)/vmod2)
	rest:=rest+vmod
	if ((rest)<=vmod2)
	{
		arr2[A_Index]:=arr[w]>>(vmod2-rest)
		arr[w]-=arr2[A_Index]<<(vmod2-rest)
	}
	else
	{
		rest:=(rest-vmod2)
		arr2[A_Index]:=arr[w-1]<<(rest)
		arr2[A_index]+=arr[w]>>(vmod2-rest)
		arr[w]-=((arr[w]>>(vmod2-rest))<<(vmod2-rest))
	}
}
For each, v in arr2
	arr2[each]+=cmin
return arr2
}
 
min(val,modvar=0xFFFFFFFF)
{
while val<0
    val+=modvar
return val
}
 
showarr(arr)
{
str2:="["
For each,key in	arr
	str2.=key "`,"
StringTrimright,str2,str2,1
str2.="]"
return str2
}
 
HexToUShort(str)
{
static d:={0:"0",1:"1",2:"2",3:"3",4:"4",5:"5",6:"6",7:"7",8:"8",9:"9","A":10,"B":11,"C":12,"D":13,"E":14,"F":15}
val:=0
Loop,Parse,str
	val:=(val<<4)+d[A_Loopfield]
return val
}
 
UShortToHex(val)
{
static d:={0:"0",1:"1",2:"2",3:"3",4:"4",5:"5",6:"6",7:"7",8:"8",9:"9",10:"A",11:"B",12:"C",13:"D",14:"E",15:"F"}
s:=""
var:=val
Loop, % 4
	val:=var>>(4*(4-A_index)),s.=d[val],var-=val<<(4*(4-A_index))
return s
}