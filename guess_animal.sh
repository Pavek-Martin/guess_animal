#!/usr/bin/env python3

def guess(tree):
    """
    Rekurzivní funkce, která se pohybuje rozhodovacím stromem.
    Pokud se dostaneme k listu (obsahujícím klíč "animal"), pokusí se uhodnout zvíře.
    Pokud uhodne, vyhlásí úspěch, jinak se zeptá uživatele, jaké zvíře bylo myšleno,
    a jakou otázku lze použít k odlišení nového zvířete od původního.
    """
    if "animal" in tree:
        answer = input(f"Je to {tree['animal']}? (ano/ne): ").strip().lower()
        if answer.startswith("a"):
            print("Hurá! Uhodl jsem!")
        else:
            new_animal = input("Nevadí, já se ještě učím. Na jaké zvíře jste mysleli? ")
            new_question = input(f"Zadejte otázku, která odliší {new_animal} od {tree['animal']}: ")
            answer_for_new = input(f"Pro {new_animal} by mi odpověď na tuto otázku měla být 'ano'? (ano/ne): ").strip().lower()
            if answer_for_new.startswith("a"):
                tree["question"] = new_question
                tree["yes"] = {"animal": new_animal}
                tree["no"] = {"animal": tree["animal"]}
            else:
                tree["question"] = new_question
                tree["yes"] = {"animal": tree["animal"]}
                tree["no"] = {"animal": new_animal}
            # Tento uzel již není list, takže smažeme klíč "animal"
            del tree["animal"]
    else:
        answer = input(tree["question"] + " (ano/ne): ").strip().lower()
        if answer.startswith("a"):
            guess(tree["yes"])
        else:
            guess(tree["no"])

def main():
    """
    Hlavní funkce hry. Inicializuje rozhodovací strom se základním zvířetem a provádí opakující se kola,
    kde hráč přemýšlí o zvířeti a program se snaží uhodnout.
    """
    # Startovní strom se základním zvířetem (např. lev)
    tree = {"animal": "lev"}
    while True:
        print("\nMyslete na zvíře a já se ho pokusím uhodnout.")
        guess(tree)
        play_again = input("Chcete hrát znovu? (ano/ne): ").strip().lower()
        if not play_again.startswith("a"):
            break
    print("Díky za hru!")

if __name__ == "__main__":
    main()

