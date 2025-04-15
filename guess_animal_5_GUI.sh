#!/usr/bin/env python3

import tkinter as tk
from tkinter import simpledialog, messagebox
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

def get_text(prompt, title="Vstup", allow_empty=False):
    """
    Zobrazí dialog pro zadání textu a opakuje výzvu, dokud uživatel nezadá neprázdný vstup,
    je-li to vyžadováno.
    """
    while True:
        result = simpledialog.askstring(title, prompt)
        if result is None:
            # Pokud uživatel zavře okno, upozorníme jej a výzvu zopakujeme.
            messagebox.showwarning("Upozornění", "Vstup je povinný.")
            continue
        result = result.strip()
        if not result and not allow_empty:
            messagebox.showwarning("Upozornění", "Vstup nesmí být prázdný.")
        else:
            return result

def get_yes_no(prompt, title="Otázka"):
    """
    Zobrazí dialog s otázkou a tlačítky Ano/Ne.
    Vrací True pro Ano a False pro Ne.
    """
    return messagebox.askyesno(title, prompt)

def backup_tree_file(filename="animal_tree.pkl"):
    """
    Pokud existuje soubor se stromem, vytvoří jeho záložní kopii.
    Záložní soubor bude pojmenován podle původního názvu s připojenou časovou značkou.
    """
    if os.path.exists(filename):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base, ext = os.path.splitext(filename)
        backup_filename = f"{base}_backup_{timestamp}{ext}"
        shutil.copy2(filename, backup_filename)
        # Zobrazení informace o vytvořené záloze:
        messagebox.showinfo("Záloha", f"Záloha byla vytvořena:\n{backup_filename}")
    else:
        # Informace, že soubor ke záloze neexistuje.
        messagebox.showinfo("Záloha", "Soubor ke záloze nebyl nalezen.")

def save_tree(node, filename="animal_tree.pkl"):
    """
    Nejprve vytvoří záložní kopii stávajícího souboru,
    poté uloží aktuální strom pomocí modulu pickle.
    """
    backup_tree_file(filename)
    with open(filename, "wb") as file:
        pickle.dump(node, file)
    messagebox.showinfo("Uložení", "Strom byl uložen.")

def load_tree(filename="animal_tree.pkl"):
    """
    Načte uložený strom, pokud soubor existuje, jinak vrátí výchozí strom.
    """
    if os.path.exists(filename):
        with open(filename, "rb") as file:
            tree = pickle.load(file)
        messagebox.showinfo("Načtení", "Načten uložený strom.")
        return tree
    else:
        messagebox.showinfo("Načtení", "Nebyl nalezen uložený strom, bude vytvořen výchozí strom.")
        return Node(animal="lev")

def play(node):
    """
    Rekurzivní funkce, která prochází stromem pomocí GUI dialogů.
    
    Pokud je uzel list, pokusí se uhodnout zvíře.  
    V případě chybného tipu je hráč vyzván zadat nové zvíře a otázku,
    která pomůže odlišit nové zvíře od původního tipu.
    """
    if node.question is None:
        answer = get_yes_no(f"Je to {node.animal}?", "Hádej zvíře")
        if answer:
            messagebox.showinfo("Výsledek", "Vyhrál jsem!")
        else:
            messagebox.showinfo("Výsledek", "Nevyhrál jsem!")
            new_animal = get_text("Myslel jste na jaké zvíře?", "Nové zvíře")
            new_question = get_text(f"Zadejte otázku, která odlišuje {new_animal} od {node.animal}:", "Nová otázka")
            answer_for_new = get_yes_no(f"Má být pro {new_animal} odpověď \"ano\"?", "Nová volba")
            if answer_for_new:
                node.question = new_question
                node.yes = Node(animal=new_animal)
                node.no = Node(animal=node.animal)
            else:
                node.question = new_question
                node.yes = Node(animal=node.animal)
                node.no = Node(animal=new_animal)
            # Vymazání původního tipu, protože nyní máme otázku
            node.animal = None
    else:
        answer = get_yes_no(node.question, "Otázka")
        if answer:
            play(node.yes)
        else:
            play(node.no)

def main():
    # Vytvoření hlavního okna Tkinter a jeho skrytí, neboť budeme pracovat pouze s dialógovými okny.
    root = tk.Tk()
    root.withdraw()  # Skryjeme hlavní okno

    messagebox.showinfo("Hádej zvíře", "Pojďme si zahrát hru 'Hádej zvíře'!")
    # Načtení uloženého stromu nebo vytvoření výchozího stromu
    root_tree = load_tree()

    while True:
        messagebox.showinfo("Hra začíná", "Myslete na nějaké zvíře a já se pokusím uhodnout...")
        play(root_tree)
        # Po každé hře uložíme aktuální podobu stromu
        save_tree(root_tree)
        if not get_yes_no("Chcete hrát znovu?", "Pokračování"):
            break

    messagebox.showinfo("Konec", "Díky za hru!")
    root.destroy()

if __name__ == "__main__":
    main()

