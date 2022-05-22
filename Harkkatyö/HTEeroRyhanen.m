%% BM20A1501 Numeeriset menetelmät I 
% * Harjoitustyö 2022
% * Eero Ryhänen
% * Opiskelijanumero 0562910

%% Deadlinet
% * Suunnitelma 12.4.2021
%
% * Välipalautus: 08.05.2020
%
% * Loppupalautus: 23.05.2020
% 

%% Työn aihe
% Työn aiheena on tutkia Energiateollisuuden nettisivuilta saadun
% tunnittaisen sähkönkulutusdatan
% (https://energia.fi/uutishuone/materiaalipankki/sahkon_tuntidata.html#material-view),
% sekä Ilmatieteen laitoksen sivuilta saatavan tunnittaisen ilman
% lämpötiladatan (https://www.ilmatieteenlaitos.fi/havaintojen-lataus)
% välistä korrelaatiota. Idea tähän tuli alun perin
% C-ohjelmoinnin perusteet-kurssin harjoitustyöstä.
% Siinä analysoitiin kyseistä sähkönkulutusdataa, ja työtä tehdessä aloin
% miettimään, kuinka paljon säällä on vaikutusta sähkönkulutukseen.

%% Johdatus
% Työ toteutetaan sovittamalla datapisteisiin erilaisia funktioita.
% Kaikki funktiot kuvaavat sähkönkulutusta lämpötilan funktiona. Funktion
% sovittaminen suoritetaan pienimmän neliösumman menetelmällä, jossa
% minimoidaan funktion arvon ja datapisteiden erotuksen neliötä.
% Minimoitava funktio on siis $S(a)= \sum_{i=1}^{n}((E_i-f(a,T_i))^2)$,
% missä $f(a,T_i)$ on sähkönkulutuksen funktio muuttujina vektori a, joka
% koostuu optimoitavista parametreista, ja lämpötila $T_i$ datapisteessä i.
% $E_i$ tarkoittaa energiankulutusta vastaavassa datapisteessä.
% Parametrit optimoidaan minimoimalla funktiota $S(a)$ käyttämällä Matlabin
% omaa fminsearch-funktiota. Hypoteesina on, että paras mahdollinen sovitus
% tulisi toisen asteen polynomilla. Ulkoilman ollessa kylmä, rakennuksien
% lämmittämiseen menevän energian määrä kasvaa paljon enemmän ilman
% kylmettyessä lisää, kun taas lämpimällä säällä lämmitykseen tarvittavan
% energian määrä ei paljon muutu, oli ulkolämpötila 20 astetta Celsiusta tai
% 25. Toisaalta kovilla helteillä rakennusten ilmastointiin alkaa kulua
% energiaa. Suomessa näitä päiviä on niin vähän, että tämä tuskin vaikuttaa
% merkittävästi tulokseen. Vuosi 2021, miltä data on, on hyvä tämän
% tutkimiseen, koska vuosi sisälti erittäin kylmän alkuvuoden ja kuuman
% kesän. 

%% Matlab-ratkaisu
% Matlab-koodit.
clc
clearvars
close all
warning off %antaa varoituksen data
%saadata.csv-tiedostosta löytyy vuodelta 2021 jokaisen tunnin lämpötila.
%Tiedostossa sahkodata2021.txt on jokaista tuntia kohti kulutettu sähkö
%Suomessa

saa=readtable("saadata2021.csv");%luetaan data
saa=saa(1:end-1,:);%Säädatassa viimeinen datapiste seuraavan vuoden puolelta, otetaan se pois koska sähködatassa ei ole vastaavaa datapistettä
sahko=readtable('sahkodata2021.txt');
kulutus=sahko.KULUTUS_MWh_Consumption;
lampoCelsius=saa.IlmanL_mp_tila_degC_;
format="HH:mm";
saaAikaleima=datetime(saa.Klo,"InputFormat",format,"Format","HH:mm:ss");%Datassa aikaleimat hiukan ikävästi eri soluissa, yhdistetään nämä
pvm=datetime(saa.Vuosi,saa.Kk,saa.Pv);
pvm=pvm+timeofday(saaAikaleima);
for i=1:length(lampoCelsius)%lämpötiladatassa on muutama NaN-arvo, siistitään ne pois ottamalla lämpötilaksi kahden viereisen datapisteen keskiarvo
    if(isnan(lampoCelsius(i)))
        lampoCelsius(i)=(lampoCelsius(i-1)+lampoCelsius(i+1))/2;
    end
end
%lampo=lampoCelsius+273.15*ones(length(lampoCelsius),1);%muutetaan vuorokauden keskilämpötilat kelvineiksi

%plottaillaan ensin vuorokauden lämpötilat ja sähkönkulutukset
figure
plot(pvm,kulutus,'b.','MarkerSize',3);
hold on
ylabel("Kulutus (MWh)/h")
yyaxis right
plot(pvm,lampoCelsius,'r.','MarkerSize',3);
title("Lämpötila ja sähkönkulutus Suomessa vuonna 2021");
ylabel("Lämpötila C")
legend("Sähkönkulutus","Lämpötila");
%annotation("textbox",[0.29,0.1,0.1,0.1],"String","Selkeä korrelaatio");
%plottaillaan sitten x-akselille lämpötila, ja y-akselille
%sähkönkulutus
figure
plot(lampoCelsius,kulutus,'r.',"MarkerSize",3);
xlabel("Lämpötila C");
ylabel("Tunnittainen sähkönkulutus (MWh)/h");
title("Sähkönkulutus ja lämpötila");
%Selkeää korrelaatiota havaittavissa


%Kokeillaan ensin lineaarista mallia
f1=@(a,x)a(1).*x+a(2);
a0=[10,10];
[a1,R1]=pns(f1,lampoCelsius,kulutus,a0);
figure
plot(lampoCelsius,kulutus,'r.',"MarkerSize",3);
xlabel("Lämpötila C");
ylabel("Tunnittainen sähkönkulutus (MWh)/h");
title("Dataan sovitettu lineaarinen malli, R^{2}-luku: "+R1);
hold on 
plot(sort(lampoCelsius),f1(a1,sort(lampoCelsius)),'k')
legend("Data","Dataan sovitettu käyrä");

%Sitten toisen asteen yhtälö
f2=@(a,x)a(1).*x.^2+a(2).*x+a(3);
a0=[10,10,10];
[a2,R2]=pns(f2,lampoCelsius,kulutus,a0);
figure
plot(lampoCelsius,kulutus,'r.',"MarkerSize",3);
xlabel("Lämpötila C");
ylabel("Tunnittainen sähkönkulutus (MWh)/h");
title("Dataan sovitettu toisen asteen yhtälö, R^{2}-luku: "+R2);
hold on 
plot(sort(lampoCelsius),f2(a2,sort(lampoCelsius)),'k')
legend("Data","Dataan sovitettu käyrä");

%Entäs kolmannen asteen yhtälö
f3=@(a,x)a(1).*x.^3+a(2).*x.^2+a(3).*x+a(4);
a0=[10,10,10,10];
[a3,R3]=pns(f3,lampoCelsius,kulutus,a0);
figure
plot(lampoCelsius,kulutus,'r.',"MarkerSize",3);
xlabel("Lämpötila C");
ylabel("Tunnittainen sähkönkulutus (MWh)/h");
title("Dataan sovitettu kolmannen asteen yhtälö, R^{2}-luku: "+R3);
hold on 
plot(sort(lampoCelsius),f3(a3,sort(lampoCelsius)),'k')
legend("Data","Dataan sovitettu käyrä");

%Näistä kolmannen asteen yhtälö tuottaa tarkimman approksimaation, tosin
%käyrän ekstrapolaatio datapisteiden ulkopuolelle ei näytä järkevältä.
%Muista funktioista toisen asteen yhtälö on paras

%entäs eksponenttifunktio
f4=@(a,x)a(1).*exp(a(2).*x);
a0=[10,10];
[a3,R3]=pns(f4,lampoCelsius,kulutus,a0);%Käytetään celciusasteita, jottei eksponenttifunktion arvoista tule tuhottoman isoja
figure
plot(lampoCelsius,kulutus,'r.',"MarkerSize",3);
xlabel("Lämpötila C");
ylabel("Tunnittainen sähkönkulutus (MWh)/h");
title("Dataan sovitettu eksponenttifunktio, R^{2}-luku: "+R3);
hold on 
plot(sort(lampoCelsius),f4(a3,sort(lampoCelsius)),'k')
legend("Data","Dataan sovitettu käyrä");

%Koitetaan, pieninisikö hajonta, jos tuntikulutuksen sijaan,
%laskettaisiinkin aina yhden vuorokauden keskiarvokulutus ja -lämpötila
kulutus1=zeros(365,1);
K=reshape(kulutus,[],365);%reshape-funktiolla yhdellä sarakkeella on yhden päivän jokaisen tunnin kulutus
for i=1:width(K)
    kulutus1(i)=sum(K(:,i))/24; %tehdään uusi kulutusvektori, summataan aina jokaisen vuorokauden tuntikulutukset yhteen
end
L=reshape(lampo,[],365);%reshape-funktiolla yhdellä sarakkeella on yhden päivän jokaisen tunnin kulutus
lampo1=zeros(365,1);
for i=1:width(L)
    lampo1(i)=sum(L(:,i))/24; %tehdään uusi kulutusvektori, summataan aina yhden vuorokauden tuntikulutukset yhteen
end
lampo1Celsius=lampo1-273.15.*ones(length(lampo1),1);
%Kokeillaan ensin lineaarista mallia

L1CelsSorted=sort(lampo1Celsius);
f1=@(a,x)a(1).*x+a(2);
a0=[10,10];
[a1,R1]=pns(f1,lampo1Celsius,kulutus1,a0);
figure
plot(lampo1Celsius,kulutus1,'r.');
xlabel("Lämpötila C");
ylabel("Päivittäinen sähkönkulutus (MWh)/h");
title("Dataan sovitettu lineaarinen malli, R^{2}-luku: "+R1);
hold on 
plot(L1CelsSorted,f1(a1,L1CelsSorted),'k')
legend("Data","Dataan sovitettu käyrä");

%Sitten toisen asteen yhtälö
f2=@(a,x)a(1).*x.^2+a(2).*x+a(3);
a0=[10,10,10];
[a2,R2]=pns(f2,lampo1Celsius,kulutus1,a0);
figure
plot(lampo1Celsius,kulutus1,'r.');
xlabel("Lämpötila C");
ylabel("Päivittäinen sähkönkulutus (MWh)/h");
title("Dataan sovitettu toisen asteen yhtälö, R^{2}-luku: "+R2);
hold on 
plot(L1CelsSorted,f2(a2,L1CelsSorted),'k')
legend("Data","Dataan sovitettu käyrä");

%Ja kolmannen
f3=@(a,x)a(1).*x.^3+a(2).*x.^2+a(3).*x+a(4);
a0=[10,10,10,10];
[a3,R3]=pns(f3,lampo1Celsius,kulutus1,a0);
figure
plot(lampo1Celsius,kulutus1,'r.');
xlabel("Lämpötila C");
ylabel("Päivittäinen sähkönkulutus (MWh)/h");
title("Dataan sovitettu kolmannen asteen yhtälö, R^{2}-luku: "+R3);
hold on 
plot(L1CelsSorted,f3(a3,L1CelsSorted),'k')
legend("Data","Dataan sovitettu käyrä");

%entäs eksponenttifunktio
f3=@(a,x)a(1).*exp(a(2).*x);
a0=[10,10];
[a4,R4]=pns(f3,lampo1Celsius,kulutus1,a0);
figure
plot(lampo1Celsius,kulutus1,'r.');
xlabel("Lämpötila C");
ylabel("Päivittäinen sähkönkulutus (MWh)/h");
title("Dataan sovitettu eksponenttifunktio, R^{2}-luku: "+R4);
hold on 
plot(L1CelsSorted,f3(a4,L1CelsSorted),'k')
legend("Data","Dataan sovitettu käyrä");

%taas kolmannen asteen yhtälö antaa tarkimman vastauksen, mutta ei
%ekstrapoloidu oikein datapisteiden ulkopuolelle
%% Mielenkiintoinen havainto
%
% <havainto.jpg>
% Datassa on selkeästi nähtävissä päivän ja viikon sisäiset syklit.
% Aamuyöstä sähkönkulutus on huomattavasti pienempi kuin päivisin, ja
% viikonloppuisin pienempi kuin arkisin. Viikonloppuöisin kulutus ei
% kuitenkaan ole paljon pienempi kuin arkiöisin. 
%% Tulokset
% Puhtaasti sovitusten $R^{2}$-lukuja katsomalla kolmannen asteen yhtälön
% sovitus dataan vaikutti parhaalta. Kuitenkin, jos katsotaan, miten käyrät
% alkavat käyttäytymään datan ulkopuolella, kolmannen asteen yhtälö ei
% ekstrapoloidu hyvin, kun lämpötila menee vielä kylmemmäksi kuin data
% näyttää. Tähän parhaiten näyttäisi toimivan eksponenttifunktio. Tosin muut yhtälöt eivät ekstrapoloidu kovin hyvin lämpötilan
% kasvaessa paljon lämpimämmäksi kuin 20 astetta Celsiusta, vaan jatkavat
% nopeasti laskuaan. 

%% Johtopäätös
% Jos näitä tuloksia tulisi käyttää sähkönkulutuksen ennustamiseen, kun
% tiedetään lämpötila esimerkiksi säätiedotteesta, käyttäisin kolmannen
% asteen yhtälön sovitusta, kun T>-10 astetta Celsiusta, ja tätä
% kylmemmällä säällä käyttäisin eksponenttifunktiota. 

%% Funktiot
function [a_opt,R2]=pns(f,xdata,ydata,a0)
    %funktio laskee parhaat parametrit dataan sovitetulle annetulle
    %funktiolle. Funktio ottaa parametrinä funktion, muuttujan x datan, y
    %datan ja alkuarvaukset parametreille. Funktio palauttaa optimaaliset
    %parametrien arvot ja sovituksen R^{2}-luvun
    
    options = optimset('MaxFunEvals',50000);%lisätään suurimpien mahdollisten laskutoimitusten määrää, jotta iso data saadaan käsiteltyä
    S=@(a)(sum((ydata-f(a,xdata)).^2));
    a_opt=fminsearch(S,a0,options);
    R2=1-(sum((ydata-f(a_opt,xdata)).^2))/(sum((ydata-mean(ydata)).^2));
end
