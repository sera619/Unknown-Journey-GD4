import os
 
def countlines(directory = "./", lines=0, ext=".py", skip_blank=False):
    # initialize lines to 0 at the start
    # loop through all subfolders and files on the directory
    for root, dirs, files in os.walk(directory):

        # loop through the files
        for filename in files:
            # if file does not end with ext skip it and start
            # the loop to check the next file
            if not filename.endswith(ext):
                continue
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
            print(file,"------>",new_lines)
    return lines
 
# call the function
#print(countlines(directory="./",ext="gd", skip_blank=True))