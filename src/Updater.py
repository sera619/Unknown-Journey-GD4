import os
import shutil
import sys
from colorama import init, Fore

def main():
    path = 'Makefile'
    os.system('cls')
    print(Fore.CYAN + "\n+++ Makefile Updater +++\n"+ Fore.RESET)
    new = input(Fore.YELLOW +"Enter Version (CTRL+C to exit): " + Fore.RESET)

    if new == "":
        exit()
    new_version = f'version = \"TechAlpha-v{new}\"\n'

    old_file = open(path, "r")
    new_file = open("Makefile2", "w")

    old_file.readline()
    new_file.write(new_version)
    shutil.copyfileobj(old_file, new_file)
    old_file.close()
    new_file.close()
    os.remove(path)
    os.rename("Makefile2", path)


if __name__ == "__main__":
    try:
        init()
        main()
    except KeyboardInterrupt:
        print(Fore.RED +"\n[!] User exit programm!\n" + Fore.RESET)
    finally:
        sys.exit()




