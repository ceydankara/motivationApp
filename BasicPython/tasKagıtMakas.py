'''
Durumlar
1)Tas
tas+tas= beraber
tas+kagit= kagit win
tas+makas= tas win

2)Kagit
kagit+makas= makas win
kagit+tas= kagit win
kagit+kagit= beraber

3)Makas
makas+makas= beraber
makas+kagit= makas win
makas+tas= tas win


 pythonda random kütüphanesinden choice u import edicez
'''

import random
choice_list=["tas","kagit","makas"]
user_choice= input("Enter yoour choice: ")
comp_choice =random.choice(choice_list)



if user_choice==comp_choice:
    print("bilgisayarın secimi",comp_choice,"beraber")

elif user_choice=="tas":
    if comp_choice=="makas":
        print("bilgisayarın secimi",comp_choice,"kazandın")
    elif comp_choice=="kagit":
        print("bilgisayarın secimi",comp_choice,"kaybettin")

elif user_choice=="makas":
    if comp_choice=="tas":
        print("bilgisayarın secimi",comp_choice,"kaybettin")
    elif comp_choice=="kagit":
        print("bilgisayarın secimi",comp_choice,"kazandın")

elif user_choice=="kagit":
    if comp_choice=="makas":
        print("bilgisayarın secimi",comp_choice,"kaybettin")
    elif comp_choice=="tas":
        print("bilgisayarın secimi",comp_choice,"kazandın")
