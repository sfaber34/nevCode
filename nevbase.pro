;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;CALCULATES NEVZOROV LIQUID WATER CONTENT, TOTAL WATER CONTENT
;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function nevbase, flightDay, level

common t,t
common inds,inds

if inds.starti eq 0 then startsec=0
if inds.starti gt 0 then startsec=inds.starti


calcTrans=0 ;calculate cdp vars from raw files
cipmod=0 ;include Jason's cip calculations
noNev1=0 ; incude Korolev's second set of Nev calculations

;---------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------FILEPATHS---------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------
  cope=99
  
  ;COPE
  if flightDay eq '0709' then nclPath='../data/20130709.c25.nc'
  if flightDay eq '0710' then nclPath='../data/20130710.c25.nc'
  if flightDay eq '0725' then nclPath='../data/20130725.c25.nc'
  if flightDay eq '0727' then nclPath='../data/20130727.c25.nc'
  if flightDay eq '0728' then nclPath='../data/20130728.c25.nc'
  if flightDay eq '0729' then nclPath='../data/20130729.c25.nc'
  if flightDay eq '0807' then nclPath='../data/20130807.c25.nc'
  if flightDay eq '0814' then nclPath='../data/20130814.c25.nc'
  if flightDay eq '0815' then nclPath='../data/20130815.c25.nc'
  if flightDay eq '0802' then nclPath='../data/20130802.c25.nc'
  if flightDay eq '0803' then nclPath='../data/20130803.c25.nc'
  if flightDay eq '0806' then nclPath='../data/20130806.c25.nc'  
  if flightDay eq '0813' then nclPath='../data/20130813.c25.nc'
  if flightDay eq '0817' then nclPath='../data/20130817.c25.nc'
  if flightDay eq '0722' then nclPath='../data/20130722.c25.nc'
  if flightDay eq '0718' then nclPath='../data/20130718.c25.nc'
  if flightDay eq '0817a' then nclPath='../data/20130817a.c25.nc'
  if flightDay eq '0817b' then nclPath='../data/20130817b.c25.nc'
  
  ;LARAMIE
  if flightDay eq '1124' then nclPath='../data/20151124.c25.nc'
  if flightDay eq '1217' then nclPath='../data/20151217.c25.nc'
  if flightDay eq '1112' then nclPath='../data/20151112.c25.nc'
  if flightDay eq '0120' then nclPath='../data/20160120.c25.nc'
  if flightDay eq '0125' then nclPath='../data/20160125.c25.nc'
  if flightDay eq '0304' then nclPath='../data/20160304.c25.nc'
  if flightDay eq '0307' then nclPath='../data/20160307.c25.nc'
  
  ;PACMICE
  if flightDay eq '081816' then nclPath='../data/20160818.c25.nc'
  if flightDay eq '082516' then nclPath='../data/20160825.c25.nc'


if strmatch(nclpath,'*2013*') eq 1 then cope=1
if strmatch(nclpath,'*2015*') eq 1 then cope=0
if strmatch(nclpath,'*2016*') eq 1 then cope=2


;--------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------LOAD VARIABLES---------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------


;liquid reference voltage [V]
vlwcref=loadvar('vlwcref', filename=nclPath)

;liquid collector voltage [V]
vlwccol=loadvar('vlwccol', filename=nclPath)

;total reference voltage [V]
vtwcref=loadvar('vtwcref', filename=nclPath)

;total collector voltage [V]
vtwccol=loadvar('vtwccol', filename=nclPath)

;liquid reference current [A]
ilwcref=loadvar('ilwcref', filename=nclPath)

;liquid collector current [A]
ilwccol=loadvar('ilwccol', filename=nclPath)

;total reference current [A]
itwcref=loadvar('itwcref', filename=nclPath)

;total collector current [A]
itwccol=loadvar('itwccol', filename=nclPath)


;------------LWC COL/REF SIGNALS ARE BACKWARDS FOR A FEW LAR FLIGHTS---------------------

      if mean(vlwccol) lt mean(vlwcref) then begin
        vlwccolB=vlwccol
        vlwcrefB=vlwcref
        vlwccol=vlwcrefB
        vlwcref=vlwccolB
      endif
      
      if mean(ilwccol) lt mean(ilwcref) then begin
        ilwccolB=ilwccol
        ilwcrefB=ilwcref
        ilwccol=ilwcrefB
        ilwcref=ilwccolB
      endif
      
      if mean(vtwccol) gt mean(vtwcref) then begin
        vtwccolB=vtwccol
        vtwcrefB=vtwcref
        vtwccol=vtwcrefB
        vtwcref=vtwccolB
      endif
      
      if mean(itwccol) gt mean(itwcref) then begin
        itwccolB=itwccol
        itwcrefB=itwcref
        itwccol=itwcrefB
        itwcref=itwccolB
      endif

;------------------------------------------------------------------------


;reverse flow static temperature [C]
trf=loadvar('trf', filename=nclPath)

;true airspeed [m/s]
tas=loadvar('tas', filename=nclPath)

;indicated airspeed [knot]
aias=loadvar('aias', filename=nclPath)

;time seconds since 2015-01-01 00:00:00 +0000
time=loadvar('time', filename=nclPath)

;pressure from rosemount sensor [mb]
pmb=loadvar('ps_hads_a', filename=nclPath)

nPoints=n(pmb[0,*])
nPoints1=nPoints+1
nPoints5=nPoints1*5.-1.

;temperature from rosemount sensor [C]
trose=loadvar('trose', filename=nclPath)

;pressure derived altitude [m]
z=loadvar('z', filename=nclPath)

;liquid water content from Gerber probe [g/m^3]
pvmlwc=loadvar('pvmlwc', filename=nclPath)

;liquid water content from Gerber probe [g/m^3]
pvmDEff=loadvar('pvmre_c', filename=nclPath)

;liquid water content from lwc100 probe [g/m^3]
lwc100=loadvar('lwc100', filename=nclPath)

;CDP concentration [cm-3]
cdpconc_1_NRB=loadvar('cdpconc_1_NRB', filename=nclPath)

;liquid water content from CDP [g/m^3]
cdplwc_1_NRB=loadvar('cdplwc_1_NRB', filename=nclPath)

;CDP accepted particles
cdpacc=loadvar('cdpacc_1_NRB', filename=nclPath)

;CDP droplet mean diamter [um]
cdpdbar_1_NRB=loadvar('cdpdbar_1_NRB', filename=nclPath)

;CDP diameter per bin
cdpdbins=loadvar('ACDP_1_NRB', filename=nclPath)

;CDP diameter per bin
cdpdbinsTest=loadvar('ACDP_1_NRB', filename=nclPath)

;Pitch [degrees]
avpitch=loadvar('avpitch', filename=nclPath)

;roll [degrees]
avroll=loadvar('avroll', filename=nclPath)

;2DP concentration [liter-1]
twodp=loadvar('twodp', filename=nclPath)
;twodp=dindgen(n1(pmb))*!values.d_nan

if cope eq 1 then begin
  ;FSSP total concentration
  fsspConc=loadvar('CONCF_IBL', filename=nclPath)

  ;FSSP LWC
  fsspLwc=loadvar('PLWCF_IBL', filename=nclPath)
endif else begin
  fsspConc=replicate(!values.d_nan,n1(vlwcref))
  fsspLwc=replicate(!values.d_nan,n1(vlwcref))
endelse


;Vertical Speed [m/s]
if cope eq 1 then hivs=loadvar('hivs', filename=nclPath)
if cope ne 1 then hivs=!VALUES.F_NAN


if flightday eq '0814' eq 1 then cipmod=0


;CIP MOD0 CONC [/liter]
if cope eq 1 and cipmod eq 1 then begin
  cipmodconc0=loadvar('CONC0_mod_cip_IBR', filename=nclPath)
endif else begin
  cipmodconc0=replicate(!VALUES.F_NAN,nPoints1)
endelse
print,'-----------', flightDay, '-----------'

;CIP MOD1 CONC [/liter]
if cope eq 1 and cipmod eq 1 then begin
  cipmodconc1=loadvar('CONC1_mod_cip_IBR', filename=nclPath)
endif else begin
  cipmodconc1=replicate(!VALUES.F_NAN,nPoints1)
endelse

;CIP MOD2 CONC [/liter]
if cope eq 1 and cipmod eq 1 then begin
  cipmodconc2=loadvar('CONC2_mod_cip_IBR', filename=nclPath)
endif else begin
  cipmodconc2=replicate(!VALUES.F_NAN,nPoints1)
endelse

;nevzorov sensor temperature [C]
nevTemp=double(loadvar('VLWCCOL_RAW', filename=nclPath, attr='temperature'))

;nevzorov sensor area [cm2]
if cope eq 1 then begin
  aLiq=.317
  aTot=.502
endif else begin
  aLiq=loadvar('VLWCCOL_RAW', filename=nclPath, attr='SampleArea')
  aTot=loadvar('VTWCCOL_RAW', filename=nclPath, attr='SampleArea')
endelse




;liquid water content from Nevzorov probe [g/m^3]
if cope eq 1 and nonev1 eq 1 then begin
  lwcNev1=loadvar('nevlwc1', filename=nclPath)
endif else begin
  lwcNev1=replicate(!VALUES.F_NAN,nPoints1)
endelse  

;liquid water content from Nevzorov probe [g/m^3]
if cope eq 1 and nonev1 eq 1 then begin
   lwcNev2=loadvar('nevlwc2', filename=nclPath)
endif else begin   
  lwcNev2=replicate(!VALUES.F_NAN,nPoints1)
endelse

;Total water content from Nevzorov probe [g/m^3]
if cope eq 1 and nonev1 eq 1 then begin
  twcNev=loadvar('nevtwc', filename=nclPath)
endif else begin  
  twcNev=replicate(!VALUES.F_NAN,nPoints1)
endelse

;Sideslip Angle [deg]
betaB=loadvar('beta', filename=nclPath)

;Yaw [deg]
avyawr=loadvar('avyawr', filename=nclPath)*!RADEG

;Attack Angle [rad]
alpha=loadvar('alpha', filename=nclPath)

;Flight Time [sec]
timeFlight=dindgen(nPoints1,start=0,increment=1)
hour=loadvar('HOUR', filename=nclPath)
min=loadvar('MINUTE', filename=nclPath)
sec=loadvar('SECOND', filename=nclPath)

;CDP average transit times [us]
if calcTrans eq 1 then begin
  cdpTransB=cdpTransTime(flightDay)
  
  cdpTrans=cdpTransB[*,0]*25d-3
  cdpDofRej=cdpTransB[*,1] 
  cdpTransRej=cdpTransB[*,2]
  cdpAdcOver=cdpTransB[*,3]
endif else begin
  cdpTrans=replicate(!VALUES.F_NAN,nPoints1)
  cdpDofRej=replicate(!VALUES.F_NAN,nPoints1)
  cdpTransRej=replicate(!VALUES.F_NAN,nPoints1)
  cdpAdcOver=replicate(!VALUES.F_NAN,nPoints1)
endelse


;--------------------SET TIMES FOR AXIS--------------------

hourst=string(hour)
hourstsp=strsplit(hourst,'.',/extract)
minst=string(min)
minstsp=strsplit(minst,'.',/extract)
secst=string(sec)
secstsp=strsplit(secst,'.',/extract)

hourstspb=SINDGEN(n_elements(hourst))
minstspb=SINDGEN(n_elements(hourst))
secstspb=SINDGEN(n_elements(hourst))

for i=0,n_elements(hourst)-1 do begin
  hourstspb[i]=hourstsp[i,0]
  minstspb[i]=minstsp[i,0]
  secstspb[i]=secstsp[i,0]
endfor
hourstspb=strtrim(hourstspb,1)
minstspb=strtrim(minstspb,1)
secstspb=strtrim(secstspb,1)

timePretty=hourstspb+':'+minstspb+':'+secstspb



;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------FILTER 25 HZ DATA------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vlwcref=filter25(vlwcref)
vlwccol=filter25(vlwccol)
vtwcref=filter25(vtwcref)
vtwccol=filter25(vtwccol)
ilwcref=filter25(ilwcref)
itwccol=filter25(itwccol)
itwcref=filter25(itwcref)
ilwccol=filter25(ilwccol)
trf=filter25(trf)
aias=filter25(aias)
pmb=filter25(pmb)
trose=filter25(trose)
z=filter25(z)
pvmlwc=filter25(pvmlwc)
pvmDEff=filter25(pvmDEff)
lwc100=filter25(lwc100)
avpitch=filter25(avpitch)
avroll=filter25(avroll)
betaB=filter25(betaB)
avyawr=filter25(avyawr)
alpha=filter25(alpha)
tas=filter25(tas)



;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------FILTER 10 HZ DATA------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


twodp=filter10(twodp)




i=double(0)
j=double(0)
int=double(5)

cdpdbinsB=make_array(n1(cdpdbins[*,0,0]),n1(cdpdbins[0,*,0])*n1(cdpdbins[0,0,*]))*0
for j=0, n(cdpdbins[0,0,*]) do begin
  cdpdbinsB[*,i]=cdpdbins[*,0,j]
  cdpdbinsB[*,i+1]=cdpdbins[*,1,j]
  cdpdbinsB[*,i+2]=cdpdbins[*,2,j]
  cdpdbinsB[*,i+3]=cdpdbins[*,3,j]
  cdpdbinsB[*,i+4]=cdpdbins[*,4,j]

  i=i+int
endfor

cdplwc_1_NRBB=[]
for i=0,n(cdplwc_1_NRB[0,*]) do begin
  cdplwc_1_NRBB=[temporary(cdplwc_1_NRBB),cdplwc_1_NRB[*,i]]
endfor




vsig=where(vlwccol gt 2.5)
vsig=vsig[30:n_elements(vsig)-30]
aStart=min(vsig)
aEnd=max(vsig)
ind5=vsig[0:*:5]
aStart5=aStart
aEnd5=aEnd/5

;--------------------FILTER VARIABLES TO FLIGHT TIME BOUNDS (BASED ON NEVZOROV POWER UP/DOWN)--------------------
vlwcref=vlwcref[aStart:aEnd]
vlwccol=vlwccol[aStart:aEnd]
vtwcref=vtwcref[aStart:aEnd]
vtwccol=vtwccol[aStart:aEnd]
ilwcref=ilwcref[aStart:aEnd]
itwccol=itwccol[aStart:aEnd]
itwcref=itwcref[aStart:aEnd]
ilwccol=ilwccol[aStart:aEnd]
trf=trf[aStart:aEnd]
tas=tas[aStart:aEnd]
aias=aias[aStart:aEnd]
pmb=pmb[aStart:aEnd]
trose=trose[aStart:aEnd]
z=z[aStart:aEnd]
pvmlwc=pvmlwc[aStart:aEnd]
pvmDEff=pvmDEff[aStart:aEnd]
lwc100=lwc100[aStart:aEnd]
cdpconc_1_NRB=cdpconc_1_NRB[aStart:aEnd]
cdpacc=cdpacc[aStart:aEnd]
cdpdbar_1_NRB=cdpdbar_1_NRB[aStart:aEnd]
avpitch=avpitch[aStart:aEnd]
avroll=avroll[aStart:aEnd]
avyawr=avyawr[aStart:aEnd]
alpha=alpha[aStart:aEnd]
betaB=betaB[aStart:aEnd]
twodp=twodp[aStart:aEnd]
cdplwc_1_NRB=cdplwc_1_NRBB[aStart:aEnd]
fsspConc=fsspConc[aStart:aEnd]
fsspLwc=fsspLwc[aStart:aEnd]
cdpdbins=cdpdbinsB[*,aStart:aEnd]

;time=time[ind5]
;timeFlight=timeFlight[aStart5:aEnd5]








;cdpTrans=cdpTrans[aStart:aEnd]
;cdpDofRej=cdpDofRejB[aStart:aEnd]
;cdpTransRej=cdpTransRejB[aStart:aEnd]
;cdpAdcOver=cdpAdcOverB[aStart:aEnd]
;cdpdbinsC=make_array(28,aEnd-aStart+1.)
;cdpdbinsC[*,*]=cdpdbinsB[*,aStart:aEnd]



;SET COPE ONLY VARIABLES
if cope eq 1 then begin
  lwcNev1=lwcNev1[aStart:aEnd]
  lwcNev2=lwcNev2[aStart:aEnd]
  twcNev=twcNev[aStart:aEnd]
  hivs=hivs[aStart:aEnd]
  vtwcref=vlwcref 
  itwcref=ilwcref
endif

;CONVERT INDICATED AIRSPEED TO M/S
aiasMs=aias*.514444

;SCALE CDP TRANSITS TO MEAN TAS
cdpTransEst=.0002/tas



;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------K AIRSPEED DEPENDANCE PARAMETERIZATION---------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if cope eq 1 then begin
  kLiq=(1.03672)*(0.965516)^aiasms+(1.11339)
  
  
;  kLiq=(0.860351)*(0.969536)^aiasms+(1.10449)
  kTot=(1.13654)*(0.989413)^aiasms+(0.309623)
endif



if cope eq 2 or cope eq 0 then begin

  case level of
    '700':begin
      ;kLiq=(0.75332308)*(0.99547708)^aiasms+(1.2198560) ;1hz
      kLiq=(0.841483)*(0.996200)^aiasms+(1.12379) ;5hz
      kTot=(1.13654)*(0.989413)^aiasms+(0.309623)
     end
     '600':begin
      ;kLiq=(0.989776)*(0.996765)^aiasms+(0.977116) ;1hz
      kLiq=(0.982622)*(0.996785)^aiasms+(0.981679) ;5hz
      kTot=(1.35180)*(0.974671)^aiasms+(0.651032)
     end
     '500':begin
      ;kLiq=(0.989940)*(0.974684)^aiasms+(1.60661) ;1hz
      kLiq=(1.00388)*(0.974276)^aiasms+(1.60898) ;5hz
      kTot=(1.04426)*(0.990708)^aiasms+(0.366638)
     end
     '400':begin
      ;kLiq=(2.33354)*(0.954685)^aiasms+(1.67697) ;1hz
      kLiq=(2.21180)*(0.955577)^aiasms+(1.67575) ;5hz
      kTot=(0.981726)*(0.981146)^aiasms+(0.683709)
     end 
  endcase

;  if (level eq '700') then kLiq=(-0.013967617)*aiasms^(0.68162048)+(2.0206156)
;  if (level eq '600') then kLiq=(-0.00956550)*tas^(0.753178)+(2.00092)
;  if (level eq '500') then kLiq=(-0.135222)*tas^(0.375551)+(2.43805)
;  if (level eq '400') then kLiq=(-0.0810470)*tas^(0.436789)+(2.28769)
;  
;  if (level eq '700') then kTot=(-0.0258749)*aiasms^(0.711242)+(1.37937)
;  if (level eq '600') then kTot=(-0.104706)*aiasms^(0.468563)+(1.64276)
;  if (level eq '500') then kTot=(-0.0249307)*aiasms^(0.698422)+(1.39464)
;  if (level eq '400') then kTot=(-0.0700741)*aiasms^(0.512351)+(1.56121)
endif



;------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------CLEARAIR POINT DETECTION---------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------------------------

nPointsFilt=n(vlwccol)
nPointsFilt1=n(vlwccol)+1d

correctionLiq=dindgen(nPointsFilt1,increment=0)
smoothSignalLiq=dindgen(nPointsFilt1,increment=0)

correctionTot=dindgen(nPointsFilt1,increment=0)
smoothSignalTot=dindgen(nPointsFilt1,increment=0)

rawSignalLiq=(vlwccol/vlwcref)
rawSignalTot=(vtwccol)


correctionLiqB=[]
correctionLiqBX=[]
int=50
for i=0,nPointsFilt do begin
  if nPointsFilt-i gt 50 then begin
    correctionLiqB=[correctionLiqB,min(rawSignalLiq[i:i+int])]
    correctionLiqBX=[correctionLiqBX,where(rawSignalLiq[i:i+int] eq min(rawSignalLiq[i:i+int]))+i]
  endif else begin
    correctionLiqB=[correctionLiqB,min(rawSignalLiq[i:n(correctionLiq)])]
    correctionLiqBX=[correctionLiqBX,where(rawSignalLiq[i:n(correctionLiq)] eq min(rawSignalLiq[i:n(correctionLiq)]))+i]
  endelse
  i=i+int
endfor

smLiq=ts_smooth(correctionLiqB,5)

for i=0,n(correctionLiqB)-1 do begin
  smoothfit=linfit([correctionLiqBX[i],correctionLiqBX[i+1]],[smLiq[i],smLiq[i+1]]) 
  for j=correctionLiqBX[i],correctionLiqBX[i+1] do begin
    smoothSignalLiq[j]=rawSignalLiq[j]-(smoothfit[0]+smoothfit[1]*(j))
  endfor
endfor



correctionTotB=[]
correctionTotBX=[]
int=50
for i=0,nPointsFilt do begin
  if nPointsFilt-i gt 50 then begin
    correctionTotB=[correctionTotB,min(rawSignalTot[i:i+int])]
    correctionTotBX=[correctionTotBX,where(rawSignalTot[i:i+int] eq min(rawSignalTot[i:i+int]))+i]
  endif else begin
    correctionTotB=[correctionTotB,min(rawSignalTot[i:n(correctionTot)])]
    correctionTotBX=[correctionTotBX,where(rawSignalTot[i:n(correctionTot)] eq min(rawSignalTot[i:n(correctionTot)]))+i]
  endelse
  i=i+int
endfor

smTot=ts_smooth(correctionTotB,5)

for i=0,n(correctionTotBX)-1 do begin
  smoothfit=linfit([correctionTotBX[i],correctionTotBX[i+1]],[smTot[i],smTot[i+1]])
  for j=correctionTotBX[i],correctionTotBX[i+1] do begin
    smoothSignalTot[j]=rawSignalTot[j]-(smoothfit[0]+smoothfit[1]*(j))
  endfor
endfor

threshLiq=q1(smoothSignalLiq[where(smoothSignalLiq gt 0)])
threshTot=q1(smoothSignalTot[where(smoothSignalTot gt 0)])



clearairLiq=where(smoothSignalLiq lt threshliq)
clearairTot=where(smoothSignalTot lt threshTot)

selSig=rawSignalLiq[clearairLiq]
clearairLiqSort=clearairLiq[sort(selSig)]
clearairLiq=clearairLiqSort[0:n1(clearairLiq)*.95]




;signalLiq=where(clearairLiqi eq 0)
;signalTot=where(clearairToti eq 0)


;clearairTotsort=sort(vtwccol[clearairTot])
;clearairTotsortsorted=clearairTot[clearairTotsort]
;clearairTotsortsorted=clearairTotsortsorted[n_elements(clearairTotsortsorted)*.01:n_elements(clearairTotsortsorted)*.99]



;---------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------MISC. POINT DETECTION---------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------

aSpan = nPoints
BetaI=dindgen(nPoints1,start=0,increment=0)
baselineIB=dindgen(nPoints1,start=0,increment=0)
baselineRollI=dindgen(nPoints1,start=0,increment=0)
baselineYawI=dindgen(nPoints1,start=0,increment=0)
baselinePitchI=dindgen(nPoints1,start=0,increment=0)
baselineI=dindgen(nPoints1,start=0,increment=0)

for i=0, aSpan do begin
  if (abs(avRoll[i]) lt 5) then begin
    baselineRollI[i]=1
  endif
  if (avpitch[i] lt (mean(avpitch) + 2) and avpitch[i] gt (mean(avpitch) - 2)) then begin ;0871013
    baselinePitchI[i]=1
  endif
  if (betaB[i] lt -.014 and betaB[i] gt -.026) then begin
    BetaI[i]=1
  endif
  if (abs(avyawr[i]) lt .003) then begin
    baselineYawI[i]=1
  endif
  if (baselineI[i] eq 1) and (baselineRollI[i] eq 1) and (baselinePitchI[i] eq 1) and (baselineYawI[i]=1) then begin
    baselineIB[i]=1
  endif
endfor

levelclearairLiq=where(baselineIB eq 1)



;-------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------MOMENT CALCULATIONS---------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------------------------------------------------------------

dEff=make_array(nPoints1)
vvd=make_array(nPoints1)
vmd=make_array(nPoints1)
diff=make_array(nPoints1)
if n_elements(cdpdbins[*,0]) eq 28 then diam=[1.5,2.5,3.5,4.5,5.5,6.5,7.5,9.,11.,13.,15.,17.,19.,21.,23.,25.,27.,29.,31.,33.,35.,37.,39.,41.,43.,45.,47.,49.]
if n_elements(cdpdbins[*,0]) eq 27 then diam=[1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,10.5,14.,17.,19.,21.,23.,25.,27.,29.,31.,33.,35.,37.,39.,41.,43.,45.,47.,49.]


dEff=[]
vmd=[]
vvd=[]
dBarB=[]
cdpBinVar=[]
cdpBinSkew=[]
cdpBinKert=[]
cdpBinBimod=[]
cdpBinMAD=[]
cdpBinSD=[]
s=0


for m=double(0), n(cdpdbins[0,*]) do begin
  xa=[]
  xb=[]
  xc=[]
  xe=[]
  meanDiff=[]
  for j=double(0),n(cdpdbins[*,0]) do begin
    xe=[xe,(diam[j])*(cdpdbins[j,m])]
    xa=[xa,(diam[j])^2.*(cdpdbins[j,m])]
    xb=[xb,(diam[j])^3.*(cdpdbins[j,m])]
    xc=[xc,(diam[j])^4.*(cdpdbins[j,m])]
  endfor  
  
  dEffB=total(xb)/total(xa)
  dEff=[dEff,dEffB]
  ;if finite(dEffB) eq 1 then dEff=[dEff,dEffB] else dEff=[dEff,0]
  
  dBarBB=total(xe)/total(cdpdbins[*,m])
  ;dBarB=[dBarB,dBarBB]
  if finite(dBarBB) eq 1 then dBarB=[dBarB,dBarBB] else dBarB=[dBarB,0]
  
  vvdB=(total(xb)/total(cdpdbins[*,m]))^(1./3.)
  vvd=[vvd,vvdB]
  ;if finite(vvdB) eq 1 then vvd=[vvd,vvdB] else vvd=[vvd,0]
  
  vmdB=total(xc)/total(xb)
  vmd=[vmd,vmdB]
  ;if finite(vmdB) eq 1 then vmd=[vmd,vmdB] else vmd=[vmd,0]
  

  gtZInd=where(cdpdbins[*,m] gt 0)
  binRedist=[]
  for y=0,n_elements(gtZInd)-1 do begin
    if min(gtZInd) gt 0d then begin
      binRedist=[binRedist,replicate(diam[gtZInd[y]],cdpdbins[gtZInd[y],m])]
    endif else begin
      binRedist=!values.d_nan
    endelse
    
  endfor
  
  diffs=binRedist-dBarB[m]
  
  varianceB=total((diffs)^2d)/(n_elements(binRedist)-1d)
  meanAbsDeviation=total(abs(diffs))/(n_elements(binRedist))
  skewnessB=total((diffs/sqrt(varianceB))^3d)/(n_elements(binRedist))
  kurtosisB=total((diffs/sqrt(varianceB))^4d)/(n_elements(binRedist))-3d
  cdpBinVar=[cdpBinVar,varianceB]
  cdpBinSD=[cdpBinSD,sqrt(varianceB)]
  cdpBinSkew=[cdpBinSkew,skewnessB]
  cdpBinKert=[cdpBinKert,kurtosisB]
  cdpBinBimod=[cdpBinBimod,((skewnessB)^(2d)+1d)/kurtosisB]
  cdpBinMAD=[cdpBinMAD,meanAbsDeviation]  
endfor




;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------COLLECTION EFFECIENCY PARAMETERIZATION---------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;--------------------LIQUID COLLECTION EFFECIENCY--------------------
colEliq=dindgen(nPoints1,start=1,increment=0)
for d=0,nPoints do begin
  if vmd[d] ge 0.884495 and vmd[d] lt 4.78668056 then begin
    colEliq[d]=0.76534878613892943-1.9525313756894320*vmd[d]+2.3079791209893301*vmd[d]^2.-1.1748496234649792*vmd[d]^3.+0.31405602625454776*vmd[d]^4.-0.042947818677930627*vmd[d]^5.+0.0023657753736188170*vmd[d]^6.
  endif
  if vmd[d] ge 4.78668056 and vmd[d] lt 17.0 then begin
    colEliq[d]=0.053872488439083099+0.38012190535664558*vmd[d]-0.073273373767733574*vmd[d]^2.+0.0082262509968131781*vmd[d]^3.-0.00056395785577478819*vmd[d]^4.+2.3254772713698912e-05*vmd[d]^5.-5.2972488973068721e-07*vmd[d]^6.+5.1198482675651746e-09*vmd[d]^7.
  endif
  if vmd[d] ge 17.0 and vmd[d] lt 25. then begin
    colEliq[d]=0.91221589+0.0087850597*vmd[d]-0.00025973702*vmd[d]^2.
  endif
  if vmd[d] ge 25. then begin
    x1=((vmd[d]-20.)/90)^2.
    x2=2.^(1./.26)-1.
    colEliq[d]=.98/(1.+x1*x2)^.26
  endif
endfor


colEliq3=dindgen(nPoints1,start=1,increment=0)
for d=0,nPoints do begin
  if vmd[d] le 15 then colEliq3[d]=(-0.236989)+0.503008*vmd[d]-0.0878596*$
    vmd[d]^2.+0.00801374*vmd[d]^3.-0.000397548*vmd[d]^4.+1.01460e-05*vmd[d]^5.-1.04243e-07*vmd[d]^6.
  if vmd[d] gt 13 and vmd[d] le 25 then colEliq3[d]=.9697
  if vmd[d] gt 25 then begin
    x1=((vmd[d]-20.)/90)^2.
    x2=2.^(1./.26)-1.
    colEliq3[d]=.98/(1.+x1*x2)^.26
  endif
endfor

;--------------------TOTAL COLLECTION EFFECIENCY--------------------
colETot=dindgen(nPoints1,start=1,increment=0)
for c=0,nPoints do begin
  if vmd[c] le 10.41 then begin
    colETot[c]=0.0089810744193528080-0.0095860685032675974*vmd[c]+0.018453599910571938*vmd[c]^2.-0.00080000274192570942*vmd[c]^3.-0.00019379821253551199*vmd[c]^4.+2.3409862748735577e-05*vmd[c]^5.-7.7800221198742747e-07*vmd[c]^6.
  endif
  if vmd[c] gt 10.41 and vmd[c] le 26.014 then begin
    colETot[c]=-0.31618167337728664+0.14578708937187912*vmd[c]-0.0070996433610162057*vmd[c]^2.+0.00016759853006931280*vmd[c]^3.-1.5651587643716880e-06*vmd[c]^4.
  endif
  if vmd[c] gt 26.014 and vmd[c] le 100.000 then begin
    colETot[c]=0.37017905572429299+0.045383498189039528*vmd[c]-0.0014994405482866568*vmd[c]^2.+2.7550006166165986e-05*vmd[c]^3.-2.8942966512346402e-07*vmd[c]^4.+1.6276378647650525e-09*vmd[c]^5.-3.8021012390993675e-12*vmd[c]^6.
  endif
  if vmd[c] gt 100.000 and vmd[c] le 150. then begin
    colETot[c]=0.76903533935546875+0.0065395329147577286*vmd[c]-7.0993726694723591e-05*vmd[c]^2.+3.4560855510790134e-07*vmd[c]^3.-6.3046545761835660e-10*vmd[c]^4.
  endif
  if vmd[c] gt 150. then begin
    colETot[c]=1.
  endif
endfor

colETot2=dindgen(nPoints1,start=1,increment=0)
for r=0,nPoints do begin
  if vmd[r] le 10.05 then colETot2[r]=(-0.0187892454)+0.2023209*vmd[r]-0.01937650*$
    vmd[r]^2.+0.00090900815025*vmd[r]^3.-2.0036900614417430e-05*vmd[r]^4.+1.6638675680649695e-07*vmd[r]^5.
  if vmd[r] gt 10.05 and vmd[r] le 33 then colETot2[r]=0.43729845*vmd[r]^(0.19240421)+0.11114933
  if vmd[r] gt 33 then colETot2[r]=0.0010409079*vmd[r]+0.93375003
endfor

colETot3=dindgen(nPoints1,start=1,increment=0)
for c=0,nPoints do begin
  if vmd[c] le 50. then begin
    colETot3[c]=-0.0576565+0.0324626*vmd[c]+0.0105399*vmd[c]^2.-0.00118195*vmd[c]^3.+5.50338e-05*vmd[c]^4.$
      -1.32812e-06*vmd[c]^5.+1.63224e-08*vmd[c]^6.-8.08554e-11*vmd[c]^7.
  endif    
  if vmd[c] gt 50. and vmd[c] le 150. then begin
     colETot3[c]=0.907000+0.00164001*vmd[c]-9.20008e-06*vmd[c]^2.+1.60003e-08*vmd[c]^3.  
  endif
  if vmd[c] gt 150. then colETot3[c]=1.
endfor




;------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------LWC/TWC/IWC CALCULATIONS---------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------------------------

;--------------------CONSTANTS--------------------
;sensor surface area conversion [cm^2] -> [m^2]
aLiq=aLiq*1d-4
aTot=aTot*1d-4

;EXPENDED HEAT

;latent heat of vaporization, liquid water at nev sensor temperature [J/Kg]
lw=2.5008d6-(4218.0d - 1870.4d)*(nevTemp)


expHeatLiq=(nevTemp-trf)*4.218+lw*1d-3
expHeatIce=expHeatLiq


;--------------------POWER CALCULATIONS--------------------
pLiq=vlwccol*ilwccol-kLiq*vlwcref*ilwcref
pLiqNpc=pLiq
lwcNpc=pLiq/(1d*tas*aLiq*expHeatLiq)

pTot=vtwccol*itwccol-kTot*vtwcref*itwcref
pTotNpc=pTot
twcNpc=pTot/(1d*tas*aTot*expHeatIce)



;--------------------POWER PRESSURE CORRECTION--------------------

linPresCorLiq=ladfit(pmb[clearairLiq],pLiqNpc[clearairLiq])
pLiq=pLiqNpc - ( linPresCorLiq[1]*pmb + linPresCorLiq[0] )

linPresCorTot=ladfit(pmb[clearairTot],pTotNpc[clearairTot])
pTot=pTotNpc - ( linPresCorTot[1]*pmb + linPresCorTot[0] )


;--------------------FINAL CALCULATIONS--------------------

;LWC
lwc=pLiq/(1.*tas*aLiq*expHeatLiq)
lwcFixedLv=pLiq/(1.*tas*aLiq*2589.)
lwcVarE=pLiq/(colELiq*tas*aLiq*expHeatLiq)

;TWC
twc=pTot/(1.*tas*aTot*expHeatIce)
twcFixedLv=pTot/(1.*tas*aTot*2589.)
twcVarE=pTot/(colETot*tas*aTot*expHeatIce)



lwcErrColE=lwcVarE-lwc
twcErrColE=twcVarE-twc

iwc=twc-lwc


;--------------------ERROR CALCULATIONS--------------------

;-----------------LWC-----------------

;----------CONTRIBUTIONS---------
lwcColEUnc=(1./colEliq)
lwcRandFluct=2d-3

;----------CALCULATIONS---------



;--------------------FINAL BASELINE FILTERING--------------------

lwcBL=lwc[clearairLiq]
lwcBL=lwcBL[where(lwcBL gt 0.)]
lwcBLThresh=mean(lwcBL)*1.2

lwcClearAir=lwc[clearairLiq]
lwcNpcClearAir=lwcNpc[clearairLiq]

lwcClearAirI=clearairLiq+startsec
twcClearAirI=clearairTot+startsec

;lwcBaseline=where(lwc lt lwcBLThresh)+inds.starti


flightSec=dindgen(n1(lwc),start=startsec,increment=1)


;--------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------PASS VARIABLES---------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------

color=['black','firebrick','navy','dark green','magenta','coral','indian red','dodger blue','orange','olive drab','medium violet red']

d={pmb:pmb, time:time, avroll:avroll, avpitch:avpitch, twodp:twodp,$
  pLiq:pLiq, lwcVarE:lwcVarE, lwcNev1:lwcNev1, twcNev:twcNev, lwcNpc:lwcNpc, twcVarE:twcVarE,$
  clearairLiq:clearairLiq, levelclearairLiq:levelclearairLiq,timeFlight:timeFlight,$
  kLiq:kLiq,threshLiq:threshLiq, clearairTot:clearairTot,betaAng:betaB,$
  aias:aiasMs, tas:tas,vlwcref:vlwcref, ilwcref:ilwcref, twcNpc:twcNpc,$
  vlwccol:vlwccol, ilwccol:ilwccol, cdpconc:cdpconc_1_NRB, trf:trf,trose:trose, threshTot:threshTot,$
  lwc100:lwc100, cdpdbar:cdpdbar_1_NRB,lwcnev2:lwcnev2, timePretty:timePretty,cdpDofRej:cdpDofRej,$
  avyaw:avyawr,pvmlwc:pvmlwc,cdplwc:cdplwc_1_NRB,pLiqNpc:pLiqNpc,twcClearAirI:twcClearAirI,$
  rawSignalLiq:rawSignalLiq, smoothSignalLiq:smoothSignalLiq, cdpacc:cdpacc,flightSec:flightSec,$
  rawSignalTot:rawSignalTot, smoothSignalTot:smoothSignalTot, pTot:pTot,pTotNpc:pTotNpc,$
  vtwccol:vtwccol,itwccol:itwccol,vtwcref:vtwcref,itwcref:itwcref,aTot:aTot,expHeatIce:expHeatIce,$
  cdpdbins:cdpdbins,lwc:lwc,expHeatLiq:expHeatLiq,smLiq:smLiq,smLiqX:correctionLiqBX,$
  dEff:dEff,vvd:vvd,vmd:vmd,coleliq:coleliq,lwcFixedLv:lwcFixedLv,twcFixedLv:twcFixedLv,$
  twc:twc,colETot:colETot,dBarB:dBarB,colEtot2:colEtot2,coletot3:coletot3,$
  cipmodconc0:cipmodconc0,cipmodconc1:cipmodconc1,fsspConc:fsspConc,cdpTrans:cdpTrans,$
  cipmodconc2:cipmodconc2,color:color,lwcErrColE:lwcErrColE,fsspLwc:fsspLwc,$
  pvmDEff:pvmDEff,cdpBinVar:cdpBinVar,cdpBinSkew:cdpBinSkew,cdpBinKert:cdpBinKert,$
  cdpBinBimod:cdpBinBimod,cdpBinMAD:cdpBinMAD,cdpBinSD:cdpBinSD,$
  cdpTransEst:cdpTransEst,iwc:iwc,lwcClearAir:lwcClearAir,$
  cdpTransRej:cdpTransRej,cdpAdcOver:cdpAdcOver,lwcNpcClearAir:lwcNpcClearAir,$
  lwcClearAirI:lwcClearAirI,alpha:alpha,correctionLiq:correctionLiq}

return,d

end





;---------------------------------------------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------FILTER 25HZ DATA -> 5HZ------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------

function filter25, varC
  varLin=[]
  for i=0,n(varC[0,*]) do begin
    varLin=[varLin,varc[*,i]]
  endfor

  varB=smooth(varLin,5)

  varFilt=varb[0:*:5]

  return,varFilt
end





;---------------------------------------------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------FILTER 10HZ DATA -> 5HZ------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------

function filter10, varC
  varLin=[]
  for i=0,n(varC[0,*]) do begin
    varLin=[varLin,varc[*,i]]
  endfor
  
  varB=smooth(varLin,2)

  varFilt=varb[0:*:2]

  return,varFilt
end





;---------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------MISC. FUNCTIONS---------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------

function convertTime,hh,mm,ss
  common t,t
  timeindex=where(t.hour eq hh and t.min eq mm and t.sec eq ss)
  return,timeindex
end



pro info
  print,''
  print,''
  print,'-------------COPE-----------------'
  print,'LEVELS COPE = 400, 600, 900'
  print,'DAYS COPE = 0710, 0725, 0727, 0728, 0729, 0803, 0807, 0814, 0815, ||0709||'
  print,''
  print,''
  print,'-----------LARAMIE----------------'
  print,'LEVELS LARAMIE = 400, 500, 600, 700'
  print,'DAYS LARAMIE = 0307, ||0304||'
  print,''
  print,'-------------COMMANDS-----------------'
  print,'SUPERSCRIPT = !U *** !N'
  print,''
  print,''
  print,'fu = min((VAR[*] - 450), i, /absolute)'
  print,''
  print,''
  print,'endif else begin'
  print,'.............'
  print,'endelse'
  print,''
  print,''
  print,',margin=[110,70,30,20],/device'
end




function cdpTransTime, flightDay

  ;COPE
  if flightDay eq '0709' then nclPath='/Volumes/externalHD/copeRaw/20130709_raw.nc'
  if flightDay eq '0710' then nclPath='/Volumes/externalHD/copeRaw/20130710_raw.nc'
  if flightDay eq '0725' then nclPath='/Volumes/externalHD/copeRaw/20130725_raw.nc'
  if flightDay eq '0727' then nclPath='/Volumes/externalHD/copeRaw/20130727_raw.nc'
  if flightDay eq '0728' then nclPath='/Volumes/externalHD/copeRaw/20130728_raw.nc'
  if flightDay eq '0729' then nclPath='/Volumes/externalHD/copeRaw/20130729_raw.nc'
  if flightDay eq '0807' then nclPath='/Volumes/externalHD/copeRaw/20130807_raw.nc'
  if flightDay eq '0814' then nclPath='/Volumes/externalHD/copeRaw/20130814_raw.nc'
  if flightDay eq '0815' then nclPath='/Volumes/externalHD/copeRaw/20130815_raw.nc'
  if flightDay eq '0802' then nclPath='/Volumes/externalHD/copeRaw/20130802_raw.nc'
  if flightDay eq '0803' then nclPath='/Volumes/externalHD/copeRaw/20130803_raw.nc'
  if flightDay eq '0304' then nclPath='/Volumes/externalHD/copeRaw/20160304_raw.nc'
  if flightDay eq '0307' then nclPath='/Volumes/externalHD/copeRaw/20160307_raw.nc'
  if flightDay eq '1217' then nclPath='/Volumes/externalHD/copeRaw/20151217_raw.nc'
  if flightDay eq '1112' then nclPath='/Volumes/externalHD/copeRaw/20151112_raw.nc'
  if flightDay eq '1124' then nclPath='/Volumes/externalHD/copeRaw/20151124_raw.nc'
  if flightDay eq '0806' then nclPath='/Volumes/externalHD/copeRaw/20130806_raw.nc'
  if flightDay eq '0813' then nclPath='/Volumes/externalHD/copeRaw/20130813_raw.nc'
  if flightDay eq '0817' then nclPath='/Volumes/externalHD/copeRaw/20130817_raw.nc'
  if flightDay eq '0722' then nclPath='/Volumes/externalHD/copeRaw/20130722_raw.nc'
  if flightDay eq '0718' then nclPath='/Volumes/externalHD/copeRaw/20130718_raw.nc'
  if flightDay eq '0120' then nclPath='/Volumes/externalHD/copeRaw/20160120_raw.nc'
  if flightDay eq '0125' then nclPath='/Volumes/externalHD/copeRaw/20160125_raw.nc'
  if flightDay eq '0817a' then nclPath='/Volumes/externalHD/copeRaw/20130817a_raw.nc'
  if flightDay eq '0817b' then nclPath='/Volumes/externalHD/copeRaw/20130817b_raw.nc'

  ;LARAMIE
  if flightDay eq '0120' then nclPath='/Volumes/externalHD/copeRaw/20160120_raw.nc'
  if flightDay eq '0125' then nclPath='/Volumes/externalHD/copeRaw/20160125_raw.nc'
  if flightDay eq '0304' then nclPath='/Volumes/externalHD/copeRaw/20160304_raw.nc'
  if flightDay eq '0307' then nclPath='/Volumes/externalHD/copeRaw/20160307_raw.nc'
  if flightDay eq '1217' then nclPath='/Volumes/externalHD/copeRaw/20151217_raw.nc'
  if flightDay eq '1112' then nclPath='/Volumes/externalHD/copeRaw/20151112_raw.nc'
  if flightDay eq '1124' then nclPath='/Volumes/externalHD/copeRaw/20151124_raw.nc'
  
  ;PACMICE
  if flightDay eq '081816' then nclPath='/Volumes/externalHD/copeRaw/20160818_raw.nc'
  if flightDay eq '082516' then nclPath='/Volumes/externalHD/copeRaw/20160825_raw.nc'
  
  cdpAveTransSps=loadvar('AVGTRNS_NRB', filename=nclPath)
  ;cdpTransRejSps=loadvar('REJAT_NRB', filename=nclPath)
  cdpDofRejSps=loadvar('REJDOF_NRB', filename=nclPath) 
  cdpAdcOver=loadvar('OVFLW_NRB', filename=nclPath) 
  cdpAveTransSpsAve=dindgen(n_elements(cdpAveTransSps[0,*]))*!Values.d_NAN
  cdpTransRejSpsAve=dindgen(n_elements(cdpAveTransSps[0,*]))*!Values.d_NAN
  cdpDofRejSpsAve=dindgen(n_elements(cdpAveTransSps[0,*]))*!Values.d_NAN
  cdpAdcOverAve=dindgen(n_elements(cdpAveTransSps[0,*]))*!Values.d_NAN


  for i=0,n_elements(cdpAveTransSps[0,*])-1 do begin
    cdpAveTransSpsFilt=cdpAveTransSps[*,i]
    nonNull=where(cdpAveTransSpsFilt gt 0.)
    if nonNull[0] ge 0 then begin
      cdpAveTransSpsFiltB=cdpAveTransSpsFilt[nonNull]
      cdpAveTransSpsAve[i]=mean(cdpAveTransSpsFiltB)
    endif
    


    cdpDofRejSpsFilt=cdpDofRejSps[*,i]
    nonNull=where(cdpDofRejSpsFilt gt 0.)
    if nonNull[0] ge 0 then begin
      cdpDofRejSpsFiltB=cdpDofRejSpsFilt[nonNull]
      cdpDofRejSpsAve[i]=mean(cdpDofRejSpsFiltB)
    endif
    
    cdptransRejSpsFilt=cdptransRejSps[*,i]
    nonNull=where(cdptransRejSpsFilt gt 0.)
    if nonNull[0] ge 0 then begin
      cdptransRejSpsFiltB=cdptransRejSpsFilt[nonNull]
      cdptransRejSpsAve[i]=mean(cdptransRejSpsFiltB)
    endif

    cdpAdcOverFilt=cdpAdcOver[*,i]
    nonNull=where(cdpAdcOverFilt gt 0.)
    if nonNull[0] ge 0 then begin
      cdpAdcOverFiltB=cdpAdcOverFilt[nonNull]
      cdpAdcOverAve[i]=mean(cdpAdcOverFiltB)
    endif
  endfor

  cdpAveTrans=cdpAveTransSpsAve
  cdpDofRej=cdpDofRejSpsAve
  ;cdpTransRej=cdptransRejSpsAve
  cdpAdcOver=cdpAdcOverAve

  ;return, [[cdpAveTrans],[cdpDofRej],[cdpTransRej],[cdpAdcOver]]
  return, [[cdpAveTrans],[cdpDofRej],[dindgen(n1(cdpDofRej))*0],[cdpAdcOver]]
end





