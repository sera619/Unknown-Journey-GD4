from src.AudioConverter import Converter
from src.CodelineCounter import countlines
from src.Updater import Updater
import os, sys, shutil, pathlib
from colorama import init, Fore

def ChangelogUpdater():
    print(Fore.CYAN +"\n+++ Changelog Updater +++\n" + Fore.RESET)
    old_version = input(Fore.YELLOW + "[?] Please enter the old version: " + Fore.RESET)
    version = input(Fore.YELLOW + "[?] Please enter a new version: "+ Fore.RESET)
    if version == "" or old_version == "":
        sys.exit(0)
    changelogtext = f"""# Installation #

Download the zip > Extract to a directory > open directory> run "UnknownJourney-TechAlpha.exe"

__IMPORTANT:__ If you already played the game please click the "Reset" Button on the Loadmenu to Reset Savefiles and prevent Gamecrashs!

__Quick Overview:__

- Patch v{version}:
"""

    old_path = "changelog.md"
    log_dir_path = "./changelogs/"
    # rename old file
    os.rename('changelog.md', f"changelog-v{old_version}.md")
    # move file to directory
    shutil.move(f'changelog-v{old_version}.md', log_dir_path)

    # create new file
    with open(old_path, 'w') as f:
        f.write(changelogtext)
    print(Fore.GREEN + "\n[!] Changelog successfully updated!\n" + Fore.RESET)

    config_path = "./conf/base.cfg"
    config_text = f'''[common]

name="Unknown Journey"
version="TechAlpha-v{version}"
platform="Windows Desktop"
author="S3R3o3"'''
    with open(config_path, "w") as d:
        d.write(config_text)
    print(Fore.GREEN + "[!] Configfile successfully updated!"+ Fore.RESET)


    sys.exit(0)


def menu():
    #os.system("cls")
    options = ["1) Codelinecounter", "2) Makefile Updater", "3) Audioconverter", "4) Changelog Update", "0) Exit"]
    menu_text = Fore.CYAN+f"\n\t++++ Unknown Journey ++++\n\t   +++ Developtools +++   \n\n\tPlease select an option!\n\t{options[0]}\n\t{options[1]}\n\t{options[2]}\n\t{options[3]}\n\t{options[4]}\n" + Fore.RESET
    print(menu_text)
    selection = int(input(Fore.YELLOW + "[?] Option: " + Fore.RESET))
    if selection == 1:
        show_verbos = input(Fore.YELLOW + "[?] List all files? (y/n): " + Fore.RESET)
        if show_verbos.upper() == "Y":
            print( Fore.GREEN+"[!] Your total lines of code: " + str(countlines(directory="./",ext="gd", skip_blank=True, verbose=True))+ "\n" +Fore.RESET)
        elif show_verbos.upper() == "N":
            print( Fore.GREEN+"[!] Your total lines of code: " + str(countlines(directory="./",ext="gd", skip_blank=True, verbose=False))+ "\n" +Fore.RESET)
        else:
            print(Fore.RED + "[X] Your input is not valid, exit!\n" + Fore.RESET)
            sys.exit(0)
    elif selection == 2:
        Updater()
    elif selection == 3:
        Converter()
    elif selection == 4:
        ChangelogUpdater()
    elif selection == 0:
        sys.exit(0)
    else:
        print(Fore.RED +"[X] Your input was not valid, exit!" + Fore.RESET)
        sys.exit(0)


if __name__ == "__main__":
    try:
        init()
        menu()
    except KeyboardInterrupt:
        print(Fore.RED + "\n[!] User exit programm!" +  Fore.RESET)
    except ValueError as ve:
        print(Fore.RED + "[X] Your input is not valid, exit!\nErrorcode: "+ str(ve) + Fore.RESET)
    except TypeError as te:
        print(Fore.RED + "[X] Your input is not valid, exit!\nErrorcode: "+ str(te) + Fore.RESET)
    finally:
        print(Fore.RED + "[!] Quit programm, bye!\n" + Fore.RESET)
    
    