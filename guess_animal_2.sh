#!/usr/bin/env python3
import json
import os

def nacist_strom(filename):
    """
    Funkce načte znalostní strom ze souboru,
    pokud soubor existuje, jinak vrátí výchozí strom se základním zvířetem (např. lev).
    """
    if os.path.exists(filename):
        try:
            with open(filename, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print("Chyba při načítání znalostního stromu:", e)
    return {"animal": "lev"}

def ulozit_strom(filename, tree):
    """
    Funkce uloží znalostní strom do souboru.
    """
    try:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(tree, f, ensure_ascii=False, indent=4)
    except Exception as e:
        print("Chyba při ukládání znalostního stromu:", e)

def guess(tree):
    """
    Rekurzivní funkce pro průchod rozhodovacím stromem.
    Pokud narazí na list (klíč "animal"), pokusí se uhodnout zvíře.
    Pokud uhodne, vyhlásí úspěch, jinak požádá o zadání nového zvířete a otázky pro odlišení.
    """
    if "animal" in tree:
        answer = input(f"Je to {tree['animal']}? (ano/ne): ").strip().lower()
        if answer.startswith("a"):
            print("Hurá! Uhodl jsem!")
        else:
            new_animal = input("Nevadí, já se ještě učím. Na jaké zvíře jste mysleli? ")
            new_question = input(f"Zadejte otázku, která odliší {new_animal} od {tree['animal']}: ")
            answer_for_new = input(f"Pro {new_animal} by měla odpověď na tuto otázku být 'ano'? (ano/ne): ").strip().lower()
            if answer_for_new.startswith("a"):
                tree["question"] = new_question
                tree["yes"] = {"animal": new_animal}
                tree["no"] = {"animal": tree["animal"]}
            else:
                tree["question"] = new_question
                tree["yes"] = {"animal": tree["animal"]}
                tree["no"] = {"animal": new_animal}
            del tree["animal"]  # tento uzel se již stává vnitřním uzlem
    else:
        answer = input(tree["question"] + " (ano/ne): ").strip().lower()
        if answer.startswith("a"):
            guess(tree["yes"])
        else:
            guess(tree["no"])

def main():
    filename = "znalostni_strom.json"
    tree = nacist_strom(filename)
    while True:
        print("\nMyslete na zvíře a já se ho pokusím uhodnout.")
        guess(tree)
        ulozit_strom(filename, tree)  # Uložíme aktuální stav "učení" po každé hře
        play_again = input("Chcete hrát znovu? (ano/ne): ").strip().lower()
        if not play_again.startswith("a"):
            break
    print("Díky za hru!")

if __name__ == "__main__":
    main()

