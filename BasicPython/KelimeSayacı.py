'''
kullanıcıdan metin verisi al onnun kac kelimeden olustugunu bul
'''
from os.path import split

metin = input("metin: ")
kelimeler= metin.split()

kelime_sayisi=len(kelimeler)

harfler=0
for kelime in kelimeler:
    harfler+=len(kelime)

print("cümledeki kelime sayısı",kelime_sayisi)
print("cümledeki harf sayısı",harfler)