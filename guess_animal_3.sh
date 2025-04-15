#!/usr/bin/env python3
import json
import os
import shutil
import datetime

def nacist_strom(filename):
    """
    Načte znalostní strom ze souboru.
    Pokud soubor neexistuje nebo dojde k chybě, vrátí výchozí strom se zvířetem "lev".
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
    Uloží znalostní strom do souboru.
    """
    try:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(tree, f, ensure_ascii=False, indent=4)
    except Exception as e:
        print("Chyba při ukládání znalostního stromu:", e)

def backup_strom(filename, backup_folder="backup"):
    """
    Vytvoří zálohu existujícího souboru se znalostním stromem.
    Zálohovací soubory jsou ukládány do složky backup s časovým razítkem.
    """
    if os.path.exists(filename):
        if not os.path.exists(backup_folder):
            os.makedirs(backup_folder, exist_ok=True)
        timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        backup_filename = os.path.join(backup_folder, f"znalostni_strom_{timestamp}.json")
        try:
            shutil.copy(filename, backup_filename)
            print(f"Záloha uložená do souboru: {backup_filename}")
        except Exception as e:
            print("Chyba při zálohování znalostního stromu:", e)

def guess(tree):
    """
    Rekurzivně prochází rozhodovací strom.
    V listových uzlech (obsahující klíč "animal") se pokusí uhodnout zvíře.
    Pokud se odpověď ukáže jako nesprávná, program se zeptá na nové zvíře a otázku pro jeho odlišení.
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
            del tree["animal"]  # Uzel se nyní stává vnitřním uzlem
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
        # Vytvoření zálohy před uložením nové verze znalostního stromu
        backup_strom(filename)
        ulozit_strom(filename, tree)
        play_again = input("Chcete hrát znovu? (ano/ne): ").strip().lower()
        if not play_again.startswith("a"):
            break
    print("Díky za hru!")

if __name__ == "__main__":
    main()
