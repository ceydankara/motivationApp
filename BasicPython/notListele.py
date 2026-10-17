#Amaç: Kullanıcıdan 5 öğrencinin notunu alıp bir listeye ekle.
# Ardından en yüksek notu, en düşük notu ve sınıf ortalamasını hesapla.

notlar=input("2 not giriniz: ")
liste=notlar.split()
notSayisi=len(liste)
'''
toplam =0
for i in liste:
  toplam+=int(i)
print(toplam/notSayisi)


en büyüğünü bulma 
'''
en_büyük=0
for i in liste:
    if int(i)>en_büyük:

      en_büyük=int(i)

print(en_büyük)


