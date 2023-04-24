# code written with help by chatgpt my beloved

import os

# function to duplicate and modify translation files
def modify_translation_files(dir_path, target_lang_code):
    for root, dirs, files in os.walk(dir_path):
        for filename in files:
            if filename.endswith("es.tr"):
                textdomain, lang_code, ext = filename.split(".")
                if lang_code != target_lang_code:
                    new_filename = f"{textdomain}.{target_lang_code}.tr"
                    src_path = os.path.join(root, filename)
                    dst_path = os.path.join(root, new_filename)
                    with open(src_path, "r", encoding="utf-8") as src_file:
                        with open(dst_path, "w", encoding="utf-8") as dst_file:
                            for line in src_file:
                                if "=" in line:
                                    dst_file.write(line.split("=")[0] + "=\n")
                                else:
                                    dst_file.write(line)

# example usage
modify_translation_files(os.getcwd(), "de") # change target language code as desired
