import os
from colorama import init, Fore 
 
def countlines(directory = "./", lines=0, ext=".py", skip_blank=False, verbose=True):
    # initialize lines to 0 at the start
    # loop through all subfolders and files on the directory
    file_count = 0
    for root, dirs, files in os.walk(directory):

        # loop through the files
        for filename in files:
            # if file does not end with ext skip it and start
            # the loop to check the next file
            if not filename.endswith(ext):
                continue
            # counting files
            # relative path to the file
            file = os.path.join(root, filename)
            # Open the file in read mode (r)
            with open(file, "r", encoding="utf-8") as f:
                if skip_blank:
                    # skip blank spaces. i.strip() captures non-blank.
                    new_lines = len([i for i in f.readlines() if i.strip()])
                else:
                    # count all the lines including blank ones
                    new_lines = len(f.readlines())
                # add the new_lines found on the current file to the total (lines)
                lines = lines + new_lines
            if verbose:
                print(file,"------>",new_lines)
            file_count += 1
    print(Fore.GREEN + "\n[!] Total Scriptfiles scanned: " + str(file_count)+ Fore.RESET)
    return lines
 
# call the function
#print(countlines(directory="./",ext="gd", skip_blank=True))