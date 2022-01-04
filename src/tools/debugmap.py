#!/usr/bin/python3
import sys

def convert_maps(labels_filename):
    labels_file = open(labels_filename, "r+")
    #read all lines after the first two
    label_lines = labels_file.readlines()[2:]
    # now that we've read the labels file, we can delete its contents
    labels_file.seek(0)
    labels_file.truncate()



    # now sort the label lines by the hexadecimal address that they start with
    label_lines.sort(key=lambda line: int((line.split()[0])[3:], 16))
    
    for line in label_lines:
        # remove the newline character
        line = line.rstrip('\n')
        # switch around the address and label, which are separated by a space
        # we want the label to be the first thing in the line
        line = line.split(" ")
        
        # remove the '00:' prefix from the address
        line[0] = line[0][3:]



        labels_file.write(line[1] + " " + line[0] + "\n")
        
if __name__ == "__main__":
    convert_maps(sys.argv[1])
