#!/usr/bin/env python3

import pickle
import os
import shutil
from datetime import datetime

class Node:
    def __init__(self, question=None, animal=None):
        # Pokud je 'question' None, jde o list (konkrétní tip) se zvířetem.
        self.question = question  
        self.animal = animal      
        self.yes = None          # Podstrom pro odpověď "ano"
        self.no = None           # Podstrom pro odpověď "ne"

def get_validated_input(prompt, valid_options=None, allow_empty=False):
    """
    Funkce opakovaně vyzývá uživatele k zadání vstupu, dokud nezadá platnou hodnotu.
    
    - Pokud je valid_options zadáno (seznam povolených hodnot), funkce akceptuje jen odpovědi,
      které se v seznamu vyskytují (porovnává se malými písmeny).
    - Pokud valid_options není zadáno, očekává se libovolný text. Pokud allow_empty je False,
      funkce znovu vyzve uživatele, pokud nedá nic.
    """
    while True:
        user_input = input(prompt).strip().lower()
        if valid_options:
            if user_input in valid_options:
                return user_input
            else:
                print(f"Prosím zadejte jednu z následujících hodnot: {', '.join(valid_options)}")
        else:
            if user_input or allow_empty:
                return user_input
            else:
                print("Vstup nesmí být prázdný. Zkuste to prosím znovu.")

def backup_tree_file(filename="animal_tree.pkl"):
    """
    Pokud existuje soubor se stromem, vytvoří jeho záložní kopii.
    Jméno zálohy obsahuje původní název a časovou značku.
    """
    if os.path.exists(filename):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_filename = f"{os.path.splitext(filename)[0]}_backup_{timestamp}{os.path.splitext(filename)[1]}"
        shutil.copy2(filename, backup_filename)
        print(f"Záloha byla vytvořena: {backup_filename}")
    else:
        print("Soubor ke záloze nebyl nalezen.")

def save_tree(node, filename="animal_tree.pkl"):
    """
    Před uložením stromu zavolá zálohování existujícího souboru.
    Poté uloží aktuální strom pomocí modulu pickle.
    """
    backup_tree_file(filename)
    with open(filename, "wb") as file:
        pickle.dump(node, file)
    print("Strom byl uložen.")

def load_tree(filename="animal_tree.pkl"):
    """
    Načte uložený strom, pokud soubor existuje. V opačném případě vrátí výchozí strom.
    """
    if os.path.exists(filename):
        with open(filename, "rb") as file:
            tree = pickle.load(file)
        print("Načten uložený strom.")
        return tree
    else:
        print("Nebyl nalezen uložený strom, bude vytvořen výchozí strom.")
        return Node(animal="lev")

def play(node):
    if node.question is None:
        answer = get_validated_input(f"Je to {node.animal}? (ano/ne): ", valid_options=["ano", "ne"])
        if answer == "ano":
            print("Vyhrál jsem!")
        else:
            print("Nevyhrál jsem!")
            new_animal = get_validated_input("Myslel jste na jaké zvíře? ", allow_empty=False)
            new_question = get_validated_input(
                f"Zadejte otázku, která odlišuje {new_animal} od {node.animal}: ", 
                allow_empty=False
            )
            answer_for_new = get_validated_input(
                f"Má být pro {new_animal} odpověď \"ano\"? (ano/ne): ", 
                valid_options=["ano", "ne"]
            )
            if answer_for_new == "ano":
                node.question = new_question
                node.yes = Node(animal=new_animal)
                node.no = Node(animal=node.animal)
            else:
                node.question = new_question
                node.yes = Node(animal=node.animal)
                node.no = Node(animal=new_animal)
            node.animal = None  # Vymazání původního tipu
    else:
        answer = get_validated_input(f"{node.question} (ano/ne): ", valid_options=["ano", "ne"])
        if answer == "ano":
            play(node.yes)
        else:
            play(node.no)

def main():
    print("Pojďme si zahrát hru 'Hádej zvíře'!")
    # Načtení uloženého stromu nebo vytvoření výchozího stromu
    root = load_tree()

    while True:
        print("\nMyslete na nějaké zvíře a já se pokusím uhodnout...")
        play(root)
        # Uložení aktuální podoby stromu se zálohováním předchozí verze
        save_tree(root)
        if get_validated_input("Chcete hrát znovu? (ano/ne): ", valid_options=["ano", "ne"]) != "ano":
            break
    print("Díky za hru!")

if __name__ == "__main__":
    main()
