#!/usr/bin/env python3

import tkinter as tk
from tkinter import ttk, simpledialog, messagebox
import json
import os
import shutil
from datetime import datetime
import logging

# --- Konfigurace logování ---
logging.basicConfig(
    level=logging.INFO,
    filename="animal_game.log",
    format="%(asctime)s - %(levelname)s - %(message)s"
)

# =============================================================================
# MODEl – Datová struktura a správa uložených dat (pomocí JSON)
# =============================================================================

class Node:
    def __init__(self, question=None, animal=None, yes=None, no=None):
        self.question = question  # Text otázky (pokud není None, jde o vnitřní uzel)
        self.animal = animal      # Název zvířete (pouze pokud je list, tj. není otázka)
        self.yes = yes            # Podstrom pro odpověď Ano
        self.no = no              # Podstrom pro odpověď Ne

    def is_leaf(self):
        return self.question is None

    def to_dict(self):
        """Rekurzivně převede uzel i jeho podstrom do slovníkové podoby."""
        return {
            "question": self.question,
            "animal": self.animal,
            "yes": self.yes.to_dict() if self.yes else None,
            "no": self.no.to_dict() if self.no else None
        }

    @staticmethod
    def from_dict(data):
        """Rekurzivně obnoví strukturu uzlů ze slovníkové podoby."""
        if data is None:
            return None
        node = Node(data.get("question"), data.get("animal"))
        node.yes = Node.from_dict(data.get("yes"))
        node.no = Node.from_dict(data.get("no"))
        return node

class AnimalTree:
    def __init__(self, root=None):
        # Pokud není strom načten, použije se výchozí zvíře (např. "lev")
        self.root = root if root is not None else Node(animal="lev")

    def to_dict(self):
        return self.root.to_dict()

    def save(self, filename="animal_tree.json"):
        """Uloží strom do souboru ve formátu JSON s vytvořením zálohy před zápisem."""
        try:
            if os.path.exists(filename):
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                base, ext = os.path.splitext(filename)
                backup_filename = f"{base}_backup_{timestamp}{ext}"
                shutil.copy2(filename, backup_filename)
                logging.info(f"Backup vytvořen: {backup_filename}")
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(self.to_dict(), f, ensure_ascii=False, indent=4)
            logging.info("Strom byl úspěšně uložen.")
        except Exception as e:
            logging.error(f"Chyba při ukládání stromu: {e}")
            messagebox.showerror("Chyba", f"Chyba při ukládání stromu: {e}")

    @staticmethod
    def load(filename="animal_tree.json"):
        """Načte strom ze souboru. Pokud soubor neexistuje, vytvoří nový výchozí strom."""
        try:
            if os.path.exists(filename):
                with open(filename, "r", encoding="utf-8") as f:
                    data = json.load(f)
                logging.info("Strom byl úspěšně načten.")
                return AnimalTree(Node.from_dict(data))
            else:
                logging.info("Uložený strom nebyl nalezen, bude vytvořen výchozí strom.")
                return AnimalTree(Node(animal="lev"))
        except Exception as e:
            logging.error(f"Chyba při načítání stromu: {e}")
            messagebox.showerror("Chyba", f"Chyba při načítání stromu: {e}")
            return AnimalTree(Node(animal="lev"))

# =============================================================================
# VIEW – Grafické uživatelské rozhraní pomocí Tkinter/ttk
# =============================================================================

class GuessAnimalGUI(tk.Tk):
    def __init__(self, controller):
        super().__init__()
        self.title("Hádej zvíře")
        self.geometry("400x300")
        self.controller = controller

        self.create_menu()

        # Hlavní rámec aplikace
        self.main_frame = ttk.Frame(self)
        self.main_frame.pack(expand=True, fill="both", padx=10, pady=10)

        # Label pro zobrazení otázky nebo tipu
        self.question_label = ttk.Label(
            self.main_frame, text="", wraplength=380, font=("Arial", 14)
        )
        self.question_label.pack(pady=20)

        # Rámec pro tlačítka
        self.button_frame = ttk.Frame(self.main_frame)
        self.button_frame.pack(pady=10)

        self.yes_button = ttk.Button(
            self.button_frame, text="Ano", command=lambda: self.controller.on_answer(True)
        )
        self.yes_button.grid(row=0, column=0, padx=10)

        self.no_button = ttk.Button(
            self.button_frame, text="Ne", command=lambda: self.controller.on_answer(False)
        )
        self.no_button.grid(row=0, column=1, padx=10)

    def create_menu(self):
        """Vytvoří horní menu s nápovědou a nastavením."""
        menubar = tk.Menu(self)
        # Menu s nápovědou
        helpmenu = tk.Menu(menubar, tearoff=0)
        helpmenu.add_command(label="Nápověda", command=self.show_help)
        menubar.add_cascade(label="Nápověda", menu=helpmenu)

        # Menu s nastavením
        settingsmenu = tk.Menu(menubar, tearoff=0)
        settingsmenu.add_command(label="Nastavení", command=self.show_settings)
        settingsmenu.add_command(label="Resetovat strom", command=self.controller.reset_tree)
        menubar.add_cascade(label="Nastavení", menu=settingsmenu)

        self.config(menu=menubar)

    def show_help(self):
        help_text = (
            "Hra 'Hádej zvíře'\n\n"
            "Program se pokouší uhodnout zvíře, na které myslíte, kladením otázek.\n"
            "Odpovídejte tlačítky 'Ano' nebo 'Ne'.\n"
            "Pokud program neuhodne, zadáte správné zvíře a otázku, která toto zvíře odlišuje\n"
            "od uhodnutého tipu. Strom se tak učí z vašich odpovědí.\n\n"
            "Příjemnou zábavu!"
        )
        messagebox.showinfo("Nápověda", help_text, parent=self)

    def show_settings(self):
        """Zobrazí dialog pro nastavení výchozího zvířete, které se použije při vytvoření nového stromu."""
        new_default = simpledialog.askstring(
            "Nastavení", "Zadejte výchozí zvíře pro nový strom:", parent=self
        )
        if new_default:
            self.controller.default_animal = new_default.strip()
            messagebox.showinfo(
                "Nastavení", f"Výchozí zvíře změněno na: {self.controller.default_animal}",
                parent=self
            )

    def update_question(self, text):
        self.question_label.config(text=text)

    def prompt_text(self, prompt, title="Input"):
        """Vrátí text zadaný uživatelem – pomocí jednoduchého dialogu."""
        return simpledialog.askstring(title, prompt, parent=self)

    def prompt_yes_no(self, prompt, title="Otázka"):
        """Zobrazí dialog s možností Ano/Ne a vrátí boolean."""
        return messagebox.askyesno(title, prompt, parent=self)

    def prompt_play_again(self):
        return messagebox.askyesno("Hra", "Chcete hrát znovu?", parent=self)

    def show_info(self, message, title="Info"):
        messagebox.showinfo(title, message, parent=self)

    def show_error(self, message, title="Chyba"):
        messagebox.showerror(title, message, parent=self)

# =============================================================================
# CONTROLLER – Řídí logiku hry, propojuje model a view
# =============================================================================

class GameController:
    def __init__(self):
        self.default_animal = "lev"  # Výchozí zvíře, které se použije při resetu stromu
        self.tree = AnimalTree.load()
        self.current_node = self.tree.root
        self.view = GuessAnimalGUI(self)
        self.start_game()

    def start_game(self):
        self.show_current_node()

    def show_current_node(self):
        """Aktualizuje zobrazení podle aktuálního uzlu."""
        if self.current_node.is_leaf():
            self.view.update_question(f"Je to {self.current_node.animal}?")
        else:
            self.view.update_question(self.current_node.question)

    def on_answer(self, answer):
        """
        Callback pro zpracování odpovědi uživatele.
        Pokud jsme na listu, vyhodnotíme tip a v případě neúspěchu požádáme o doplnění stromu.
        Pokud jsme na vnitřním uzlu, pokračujeme podle volby.
        """
        if self.current_node.is_leaf():
            if answer:
                self.view.show_info("Vyhrál jsem!")
                self.end_round()
            else:
                self.view.show_info("Nevyhrál jsem!")
                self.handle_incorrect_guess()
        else:
            # Procházení stromu podle odpovědi
            self.current_node = self.current_node.yes if answer else self.current_node.no
            self.show_current_node()

    def handle_incorrect_guess(self):
        """Pokud tip nebyl správný, nabídne zadání nového zvířete a rozdělovací otázky."""
        new_animal = self.view.prompt_text("Myslel jste na jaké zvíře?", "Nové zvíře")
        if not new_animal:
            return
        new_question = self.view.prompt_text(
            f"Zadejte otázku, která odlišuje {new_animal} od {self.current_node.animal}:",
            "Nová otázka"
        )
        if not new_question:
            return
        answer_for_new = self.view.prompt_yes_no(
            f"Má být pro {new_animal} odpověď 'Ano'?", "Nová volba"
        )
        guessed_animal = self.current_node.animal

        # Aktualizace aktuálního uzlu tak, aby se již nepředstavoval jako list, ale obsahoval otázku
        if answer_for_new:
            self.current_node.question = new_question
            self.current_node.yes = Node(animal=new_animal)
            self.current_node.no = Node(animal=guessed_animal)
        else:
            self.current_node.question = new_question
            self.current_node.yes = Node(animal=guessed_animal)
            self.current_node.no = Node(animal=new_animal)
        self.current_node.animal = None
        self.tree.save()
        self.end_round()

    def end_round(self):
        """Po skončení kola se ptáme, zda hrát znovu. Při zvolení opět hrajeme od kořene."""
        if self.view.prompt_play_again():
            self.current_node = self.tree.root
            self.show_current_node()
        else:
            self.tree.save()
            self.view.show_info("Díky za hru!")
            self.view.destroy()

    def reset_tree(self):
        """Resetuje strom – nabídne možnost smazání naučených dat."""
        if messagebox.askyesno(
            "Reset stromu",
            "Opravdu chcete resetovat strom? Tím se ztratí naučená zvířata.",
            parent=self.view
        ):
            self.tree = AnimalTree(Node(animal=self.default_animal))
            self.current_node = self.tree.root
            self.tree.save()
            self.show_current_node()
            self.view.show_info("Strom byl resetován.")

    def run(self):
        self.view.mainloop()

# =============================================================================
# Spuštění celé aplikace
# =============================================================================

if __name__ == "__main__":
    GameController().run()
