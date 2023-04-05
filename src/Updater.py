import os
import pathlib
import shutil
import sys




def main():
    path = 'Makefile'
    print("+++Makefile Updater+++\n")
    new = input("Enter Version: ")

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
        main()
    except KeyboardInterrupt:
        print("[!] User exit programm")
    finally:
        sys.exit()




