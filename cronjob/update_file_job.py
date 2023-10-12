import os
import update_file_pb2
import google.protobuf.text_format as text_format

# Process all protos in PROTOS_DIRECTORY according to their contents
PROTOS_DIRECTORY = "/protos"

def read_textproto(file_path):
    with open(file_path, "r") as f:
        textproto = f.read()
    textproto_file = text_format.Parse(textproto, update_file_pb2.UpdateFile())

    return textproto_file

def do_update_file(content, dest_file):
    with open(dest_file, "a") as f:
        f.write(content)

def main():
    for filename in os.listdir(PROTOS_DIRECTORY):
        if filename.endswith(".textproto"):
            file_path = os.path.join(PROTOS_DIRECTORY, filename)

            update_file = read_textproto(file_path)
            
            src_file = update_file.src_file
            dest_file = update_file.dest_file

            content = None
            # if src_file is set, read the content from there
            # otherwise, read content from the "content" variable in the protobuf
            if src_file:
                with open(src_file, "r") as f:
                    content = f.read()
            else:
                content = update_file.content

            do_update_file(content, dest_file)

if __name__ == "__main__":
    main()
