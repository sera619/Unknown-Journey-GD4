from pydub import AudioSegment
import os


def format(source_format):
    if source_format == "mp3":
        directory = "..\\assets\\Music and Sounds\\"
        count = 0
        for root, dirs, files in os.walk(directory):
            for filename in files:
                if not filename.endswith(f'.{source_format}'):
                    continue
                newname = filename[:-4]
                file = os.path.join(root, filename)
                sound = AudioSegment.from_mp3(file)
                sound.export(root+newname + ".wav", format="wav")
                count += 1
        print(f"[!] {count}x {source_format.upper()} Files converted!")


def main():
    print("AudioConverter\nSelect filetype to convert in .wav!\n\n\tOptions:\n\t1) MP3\n\t2) WAV\n\t3) OOG\n\t0) Exit\n")
    option = int(input("[?] Choose a option: "))
    if option == 1:
        format('mp3')
    else:
        print("[X] Exit!")
        exit(0)



if __name__ == "__main__":
    main()