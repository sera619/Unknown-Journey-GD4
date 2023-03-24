from pydub import AudioSegment
import os


def format_audio(source_format):
    current_dir = os.path.abspath(__file__)
    current_dir = current_dir[:-17]
    if source_format == "mp3":
        directory = current_dir+"\..\\assets\\Music and Sounds\\"
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
    print("AudioConverter\nSelect filetype to convert in .wav!\n\n\tOptions:\n\t1) MP3\n\t0) Exit\n")
    option = int(input("[?] Choose a option: "))
    if option == 1:
        format_audio('mp3')
    else:
        exit(0)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[X] Keyboard Exit!")
    finally:
        print("[!] End Converter.")
        exit(0)
        